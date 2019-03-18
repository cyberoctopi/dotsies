(use-package ielm
  :hook ((ielm-mode . company-mode)))

;; Highlight bound variables and quoted exprs.
(use-package lisp-extra-font-lock
  :ensure t
  :hook ((emacs-lisp-mode . lisp-extra-font-lock-global-mode)))

(use-package elisp-mode
  :commands emacs-lisp-mode
  :hook ((emacs-lisp-mode . pcre-mode)
         (emacs-lisp-mode . ar/emacs-lisp-mode-hook-function)
         (ielm-mode . ar/emacs-lisp-mode-hook-function))
  :init
  (defun ar/emacs-lisp-mode-hook-function ()
    "Called when entering `emacs-lisp-mode'."
    ;; Pretty print output to *Pp Eval Output*.
    (local-set-key [remap eval-last-sexp] 'pp-eval-last-sexp)
    (setq-local company-backends '((company-yasnippet
                                    company-dabbrev-code
                                    company-keywords
                                    company-files
                                    company-capf))))
  :config
  (require 'simple)
  (require 'ar-csetq)
  ;; From https://github.com/daschwa/emacs.d
  ;; Nic says eval-expression-print-level needs to be set to nil (turned off) so
  ;; that you can always see what's happening.
  (ar/csetq eval-expression-print-level nil)

  ;; make ELisp regular expressions more readable.
  (use-package easy-escape
    :ensure t
    :hook (emacs-lisp-mode . easy-escape-minor-mode)
    :config
    ;; TODO: Figure out why face foreground isn't displayed.
    (set-face-attribute 'easy-escape-face nil :foreground "red")
    (ar/vsetq easy-escape-character ?⑊))

  ;; Display ElDoc documentations in a childframe.
  (use-package eldoc-box
    :ensure t
    :config
    (eldoc-box-hover-mode)
    (eldoc-box-hover-at-point-mode))

  ;; Apply face to face symbols themselves.
  (use-package fontify-face
    :ensure t
    :commands fontify-face-mode))

(use-package auto-compile
  :ensure t
  :config
  (auto-compile-on-load-mode +1)
  (auto-compile-on-save-mode +1))
