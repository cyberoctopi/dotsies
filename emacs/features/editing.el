(require 'ar-vsetq)
(require 'ar-csetq)

;; Prevent Extraneous Tabs.
;; From http://www.gnu.org/software/emacs/manual/html_node/eintr/Indent-Tabs-Mode.html
(setq-default indent-tabs-mode nil)

;; Show keystrokes earlier (ie. C-x)
(ar/vsetq echo-keystrokes 0.1)

;; No need to keep duplicates in prompt history.
(ar/vsetq history-delete-duplicates t)

(use-package simple
  :config
  (ar/vsetq kill-ring-max 1000))

;; Shows keyboard macros as Emacs lisp.
(use-package elmacro
  :ensure t)

(use-package change-inner
  :ensure t
  :bind (("M-+" . change-outer)
         ("M-_" . change-inner)))

(use-package expand-region
  :ensure t
  :bind ("C-c w" . er/expand-region)
  :config
  ;; (ar/csetq expand-region-smart-cursor t)
  ;; Skip marking word. Most of the time, I want symbol.
  (ar/vsetq er/try-expand-list (remq 'er/mark-word er/try-expand-list))
  (defun ar/kill-ring-save--expand-region-advice (orig-fun &rest r)
    "Remember point location prior to expanding region with an advice around `kill-ring-save' (ORIG-FUN and R)."
    (apply orig-fun r)
    (when (eq last-command 'er/expand-region)
      (pop-to-mark-command)
      (pop-to-mark-command)
      (message "Restored location prior to 'er/expand-region")))

  (advice-add 'kill-ring-save
              :around
              'ar/kill-ring-save--expand-region-advice)

  (advice-add 'indent-for-tab-command
              :around
              'ar/kill-ring-save--expand-region-advice))

(use-package dabbrev
  :config
  ;; Case-sensitive fold search search (ie. M-/ to autocomplete).
  (ar/vsetq dabbrev-case-fold-search nil))

(defun ar/yank-line-below ()
  "Yank to line below."
  (interactive)
  (save-excursion
    (move-end-of-line nil)
    (newline)
    (yank))
  (next-line))

(bind-key "M-C-y" #'ar/yank-line-below)

(use-package drag-stuff
  :ensure t
  :bind (("M-<up>" . drag-stuff-up)
         ("M-<down>" . drag-stuff-down)))

;; Remember history of things across launches (ie. kill ring).
;; From https://www.wisdomandwonder.com/wp-content/uploads/2014/03/C3F.html
(use-package savehist
  :defer 2
  :config
  (ar/vsetq savehist-file "~/.emacs.d/savehist")
  (ar/vsetq savehist-save-minibuffer-history t)
  (ar/vsetq history-length 1000)
  (ar/vsetq savehist-additional-variables
            '(kill-ring
              search-ring
              regexp-search-ring
              log-edit-comment-ring))
  (savehist-mode +1))
(use-package whitespace
  :defer 5
  ;; Automatically remove whitespace on saving.
  :hook ((before-save . whitespace-cleanup)
         (prog-mode . whitespace-mode))
  :config
  ;; When nil, fill-column is used instead.
  (ar/vsetq whitespace-line-column nil)
  ;; Highlight empty lines, TABs, blanks at beginning/end, lines
  ;; longer than fill-column, and trailing blanks.
  (ar/vsetq whitespace-style '(face empty tabs lines-tail trailing))
  (ar/vsetq show-trailing-whitespace t)
  (set-face-attribute 'whitespace-line nil
                      :foreground "DarkOrange1"
                      :background nil))

(use-package anchored-transpose
  :commands anchored-transpose
  :init
  ;; which used to be transpose-words
  (global-unset-key (kbd "M-t"))
  :bind
  (("M-t r" . anchored-transpose)
   ("M-t l" . transpose-lines)
   ("M-t w" . transpose-words)))

(use-package smartparens
  :ensure t
  :init
  (when (display-graphic-p)
    (define-key input-decode-map (kbd "C-[") [C-\[]))
  :bind
  (:map
   smartparens-strict-mode-map
   ;; I prefer keeping C-w to DWIM kill, provided by
   ;; `ar/kill-region-advice-fun'. Removing remap.
   ([remap kill-region] . kill-region)
   :map smartparens-mode-map
   ([remap kill-region] . kill-region)
   ("C-M-]" . sp-rewrap-sexp)
   ("C-M-[" . sp-rewrap-sexp)
   ("M-[" . sp-backward-unwrap-sexp)
   ("M-]" . sp-unwrap-sexp)
   ("M-k" . sp-backward-kill-sexp)
   ("C-<right>" . ar/forward-slurp-sexp)
   ("C-<left>" . ar/forward-barf-sexp)
   ("M-<right>" . ar/backward-barf-sexp)
   ("M-<left>"  . ar/backward-slurp-sexp)
   ("C-M-f" . sp-forward-sexp)
   ("C-M-b" . sp-backward-sexp)
   ("C-M-n" . sp-forward-sexp)
   ("C-M-p" . sp-backward-sexp)
   ("C-M-a" . sp-beginning-of-sexp)
   ("C-M-e" . sp-end-of-sexp)
   ("C-M-u" . sp-backward-up-sexp)
   ("C-M-d" . sp-down-sexp)
   ("C-M-t" . sp-transpose-sexp)
   ("M-t t" . sp-transpose-sexp)
   ("C-M-k" . sp-kill-sexp)
   ("C-M-w" . sp-copy-sexp))
  ;; Add to minibuffer also.
  :hook ((minibuffer-setup . smartparens-mode)
         (prog-mode . smartparens-strict-mode)
         (protobuf-mode . smartparens-strict-mode)
         (ielm-mode . smartparens-strict-mode)
         (eshell-mode . smartparens-strict-mode))
  :config
  (defun ar/backward-barf-sexp (&optional arg)
    (interactive "P")
    (if (eq major-mode 'org-mode)
        (org-metaright)
      (sp-backward-barf-sexp)))

  (defun ar/backward-slurp-sexp (&optional arg)
    (interactive "P")
    (if (eq major-mode 'org-mode)
        (org-metaleft)
      (sp-backward-slurp-sexp)))

  (defun ar/forward-barf-sexp (&optional arg)
    (interactive "P")
    (if (eq major-mode 'org-mode)
        (left-word)
      (sp-forward-barf-sexp)))

  (defun ar/forward-slurp-sexp (&optional arg)
    (interactive "P")
    (if (eq major-mode 'org-mode)
        (right-word)
      (sp-forward-slurp-sexp)))

  (require 'smartparens-config)
  (require 'smartparens-html)
  (require 'smartparens-python)

  ;; Removes \\(
  (sp-local-pair 'swift-mode "\\\\(" nil :actions nil)
  (sp-local-pair 'swift-mode "\\(" ")")

  (defun ar/create-newline-and-enter-sexp (&rest _ignored)
    "Open a new brace or bracket expression, with relevant newlines and indent. "
    (newline)
    (indent-according-to-mode)
    (forward-line -1)
    (indent-according-to-mode))

  (sp-local-pair 'prog-mode "{" nil :post-handlers '((ar/create-newline-and-enter-sexp "RET")))
  (sp-local-pair 'prog-mode "[" nil :post-handlers '((ar/create-newline-and-enter-sexp "RET")))
  (sp-local-pair 'prog-mode "(" nil :post-handlers '((ar/create-newline-and-enter-sexp "RET")))

  (defun ar/sp-prog-skip-match-angle-bracket (_ms _mb me)
    "Non-nil if we should ignore the bracket as valid delimiter."
    (save-excursion
      (goto-char me)
      (let ((on-fn-return-type
             (sp--looking-back-p (rx "->") nil))
            (on-match-branch
             (sp--looking-back-p (rx "=>") nil))
            (on-comparison
             (sp--looking-back-p (rx (or
                                      (seq space "<")
                                      (seq space ">")
                                      (seq space "<<")
                                      (seq space ">>")))
                                 nil)))
        (or on-comparison on-fn-return-type on-match-branch))))

  (defun ar/sp-prog-filter-angle-brackets (_id action context)
    "Non-nil if we should allow ID's ACTION in CONTEXT for angle brackets."
    ;; See the docstring for `sp-pair' for the possible values of ID,
    ;; ACTION and CONTEXT.
    (cond
     ;; Inside strings, don't do anything with < or >.
     ((eq context 'string)
      nil)
     ;; Don't do any smart pairing inside comments either.
     ((eq context 'comment)
      nil)
     ;; Otherwise, we're in code.
     ((eq context 'code)
      (let ((on-fn-return-type
             (looking-back (rx "->") nil))
            (on-match-branch
             (looking-back (rx "=>") nil))
            (on-comparison
             (looking-back (rx (or
                                (seq space "<")
                                (seq space ">")
                                (seq space "<<")
                                (seq space ">>")))
                           nil)))
        (cond
         ;; Only insert a matching > if we're not looking at a
         ;; comparison.
         ((eq action 'insert)
          (and (not on-comparison) (not on-fn-return-type) (not on-match-branch)))
         ;; Always allow wrapping in a pair if the region is active.
         ((eq action 'wrap)
          (not on-match-branch))
         ;; When pressing >, autoskip if we're not looking at a
         ;; comparison.
         ((eq action 'autoskip)
          (and (not on-comparison) (not on-fn-return-type) (not on-match-branch)))
         ;; Allow navigation, highlighting and strictness checks if it's
         ;; not a comparison.
         ((eq action 'navigate)
          (and (not on-comparison) (not on-fn-return-type) (not on-match-branch))))))))

  (sp-local-pair 'protobuf-mode "'" "'")
  (sp-local-pair 'prog-mode "/*" "*/")

  (sp-local-pair 'prog-mode "<" ">"
                 :when '(ar/sp-prog-filter-angle-brackets)
                 :skip-match 'ar/sp-prog-skip-match-angle-bracket)

  (defun ar/kill-region-advice-fun (orig-fun &rest r)
    "Advice function around `kill-region' (ORIG-FUN and R)."
    (if (or (null (nth 2 r)) ;; Consider kill-line (C-k).
            mark-active)
        (apply orig-fun r)
      ;; Kill entire line.
      (let ((last-command (lambda ())) ;; Override last command to avoid appending to kill ring.
            (offset (- (point)
                       (line-beginning-position))))
        (apply orig-fun (list (line-beginning-position)
                              (line-end-position)
                              nil))
        (delete-char 1)
        (forward-char (min offset
                           (- (line-end-position)
                              (line-beginning-position)))))))

  (advice-add 'kill-region
              :around
              'ar/kill-region-advice-fun))

(use-package region-bindings-mode
  :ensure t
  :defer 2
  :config
  (region-bindings-mode-enable))

;; Display chars/lines or row/columns in the region.
(use-package region-state
  :ensure t
  :defer 2
  :config
  (region-state-mode))

(use-package multiple-cursors :ensure t
  :after region-bindings-mode
  :init
  (global-unset-key (kbd "M-<down-mouse-1>"))
  :bind (("C-c a" . mc/mark-all-like-this)
         ("C-c n" . mc/mark-more-like-this-extended)
         ("M-<mouse-1>" . mc/add-cursor-on-click))
  :bind (:map region-bindings-mode-map
              ("a" . mc/mark-all-like-this)
              ("p" . mc/mark-previous-like-this)
              ("n" . mc/mark-next-like-this)
              ("P" . mc/unmark-previous-like-this)
              ("N" . mc/unmark-next-like-this)
              ("m" . mc/mark-more-like-this-extended)
              ("h" . mc-hide-unmatched-lines-mode)
              ("\\" . mc/vertical-align-with-space)
              ("#" . mc/insert-numbers) ; use num prefix to set the starting number
              ("^" . mc/edit-beginnings-of-lines)
              ("$" . mc/edit-ends-of-lines))
  :config
  ;; MC-friendly packages.
  (use-package phi-search :ensure t)
  (use-package phi-rectangle :ensure t)
  (use-package phi-search-mc :ensure t
    :config
    (phi-search-mc/setup-keys)))

;; From https://github.com/daschwa/emacs.d
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single
line instead."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position) (line-end-position)))))

(use-package hungry-delete
  :defer 5
  :ensure t
  :config (global-hungry-delete-mode))

(use-package delsel
  :defer 5
  :config
  ;; Override selection with new text.
  (delete-selection-mode +1))

;; Highlight matching parenthesis.
(use-package paren
  :ensure t
  :defer 5
  :config
  (show-paren-mode +1)
  ;; Without this matching parens aren't highlighted in region.
  (ar/vsetq show-paren-priority -50)
  (ar/vsetq show-paren-delay 0)
  ;; Highlight entire bracket expression.
  (ar/vsetq show-paren-style 'expression)
  (set-face-attribute 'show-paren-match nil
                      :background nil
                      :foreground "#FA009A"))

(use-package ar-text
  :bind (("C-c c" . ar/text-capitalize-word-toggle)
         ("C-c r" . set-rectangular-region-anchor)
         ("M-DEL" . ar/backward-delete-subword)
         ("<C-backspace>" . ar/backward-delete-subword)))

;; Monitor system clipboard and append kill ring.
(use-package clipmon
  :ensure t
  :config
  (clipmon-mode))


;; Make kill ring persistent across sessions.
(use-package savekill
  :ensure t)

(use-package simple
  :config
  ;; Save external clipboard before killing other text in Emacs.
  (ar/vsetq save-interprogram-paste-before-kill t)

  ;; Don't bother saving things to the kill-ring twice, remove duplicates.
  (ar/csetq kill-do-not-save-duplicates t)

  ;; Wait a bit longer than the default (0.5 seconds) before assuming Emacs is idle.
  (ar/csetq idle-update-delay 2)

  ;; Increase mark ring size.
  (ar/csetq global-mark-ring-max 500)

  (defun ar/kill-ring-save--mark-whole-buffer (orig-fun &rest r)
    "Remember point location prior to `mark-whole-buffer' with an advice around `kill-ring-save' (ORIG-FUN and R)."
    (apply orig-fun r)
    (when (eq last-command 'mark-whole-buffer)
      (pop-to-mark-command)
      (pop-to-mark-command)
      (message "Restored location prior to 'mark-whole-buffer")))

  (advice-add 'kill-ring-save
              :around
              'ar/kill-ring-save--mark-whole-buffer)

  (advice-add 'indent-for-tab-command
              :around
              'ar/kill-ring-save--mark-whole-buffer)

  (defun ar/add-keymap-to-minor-mode (toggle keymap)
    "Extracted from `add-minor-mode', adds to TOGGLE (minor mode) a KEYMAP."
    (let ((existing (assq toggle minor-mode-map-alist)))
      (if existing
	  (setcdr existing keymap)
	(let ((tail minor-mode-map-alist) found)
	  (while (and tail (not found))
	    (setq tail (cdr tail)))
	  (if found
	      (let ((rest (cdr found)))
		(setcdr found nil)
		(nconc found (list (cons toggle keymap)) rest))
	    (push (cons toggle keymap) minor-mode-map-alist))))))

  (defvar read-only-mode-map (make-sparse-keymap) "read-only-mode's missing keymap")
  (define-key read-only-mode-map (kbd "q") #'quit-window)
  (define-key read-only-mode-map (kbd "p") #'previous-line)
  (define-key read-only-mode-map (kbd "n") #'next-line)
  (define-key read-only-mode-map (kbd "f") #'forward-char)
  (define-key read-only-mode-map (kbd "b") #'backward-char)

  (ar/add-keymap-to-minor-mode 'read-only-mode read-only-mode-map))

;; Open rc files with conf-mode.
(use-package conf-mode
  :mode ("rc$" . conf-mode))

;; Handles escaping regexes from input. For example: no need for \(\)
(use-package pcre2el
  :ensure t
  :config
  (pcre-mode +1))

(use-package re-builder
  :config
  (ar/csetq reb-re-syntax 'string))
;; No double escaping needed.
