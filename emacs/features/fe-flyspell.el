;;; -*- lexical-binding: t; -*-
(require 'ar-csetq)

(use-package flyspell
  :bind (:map
         flyspell-mode-map
         ("C-M-i" . ar/auto-correct-word-then-abbrev))
  :init
  ;; TODO: Figure out why it's not defined.
  (ar/csetq flyspell-delayed-commands nil)
  ;; From http://endlessparentheses.com/ispell-and-abbrev-the-perfect-auto-correct.html
  (defun ar/auto-correct-word-then-abbrev (p)
    "Call `ispell-word', then create an abbrev for it.
With prefix P, create local abbrev.  Otherwise it will
be global."
    (interactive "P")
    (let (bef aft)
      (save-excursion
        (while (if (setq bef (thing-at-point 'word))
                   ;; Word was corrected or used quit.
                   (if (ispell-word nil 'quiet)
                       nil ; End the loop.
                     ;; Also end if we reach `bob'.
                     (not (bobp)))
                 ;; If there's no word at point, keep looking
                 ;; until `bob'.
                 (not (bobp)))
          (backward-word))
        (setq aft (thing-at-point 'word)))
      (if (and aft bef (not (equal aft bef)))
          (let ((aft (downcase aft))
                (bef (downcase bef)))
            (define-abbrev
              (if p local-abbrev-table global-abbrev-table)
              bef aft)
            (message "\"%s\" now expands to \"%s\" %sally"
                     bef aft (if p "loc" "glob")))
        (user-error "No typo at or before point"))))
  :config
  (use-package abbrev)
  (use-package ispell
    :ensure-system-package aspell
    :config
    ;; http://blog.binchen.org/posts/what-s-the-best-spell-check-set-up-in-emacs.html
    (cond
     ;; if hunspell does NOT exist, use aspell
     ((executable-find "hunspell")
      (setq ispell-program-name "hunspell")
      (setq ispell-local-dictionary "en_GB")
      (setq ispell-local-dictionary-alist
            '(("en_GB" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_GB") nil utf-8))))
     ((executable-find "aspell")
      (setq ispell-program-name "aspell")
      (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_GB"))))))

(use-package mw-thesaurus
  :ensure t
  :commands mw-thesaurus-lookup-at-point)

(use-package auto-dictionary
  :commands adict-change-dictionary
  :ensure t
  :hook (message-mode . auto-dictionary-mode))
