;;; ivy.el -*- lexical-binding: t; -*-
(require 'ar-vsetq)
(require 'ar-csetq)

(use-package counsel
  :ensure t
  :defer 0.1
  :commands (ar/counsel-ag
             ar/ivy-occur)
  :bind (:map
         global-map
         ("C-c i" . counsel-semantic-or-imenu)
         :map counsel-ag-map
         ("C-c C-e" . ar/ivy-occur)
         :map wgrep-mode-map
         ("C-c C-c" . ar/wgrep-finish-edit)
         ("C-c C-k" . ar/wgrep-abort-changes))
  :config
  ;; `ar/ivy-occur',`ar/counsel-ag', `ar/wgrep-abort-changes' and `ar/wgrep-finish-edit' replicate a more
  ;; streamlined result-editing workflow I was used to in helm-ag.
  (defun ar/ivy-occur ()
    "Stop completion and put the current candidates into a new buffer.

The new buffer remembers current action(s).

While in the *ivy-occur* buffer, selecting a candidate with RET or
a mouse click will call the appropriate action for that candidate.

There is no limit on the number of *ivy-occur* buffers."
    (interactive)
    (if (not (window-minibuffer-p))
        (user-error "No completion session is active")
      ;; ar addition start.
      (defvar ar/ivy-occur--win-config)
      (setq ar/ivy-occur--win-config
            (current-window-configuration))
      ;; ar addition end.
      (let* ((caller (ivy-state-caller ivy-last))
             (occur-fn (plist-get ivy--occurs-list caller))
             (buffer
              (generate-new-buffer
               (format "*ivy-occur%s \"%s\"*"
                       (if caller
                           (concat " " (prin1-to-string caller))
                         "")
                       ivy-text))))
        (with-current-buffer buffer
          (let ((inhibit-read-only t))
            (erase-buffer)
            (if occur-fn
                (funcall occur-fn)
              (ivy-occur-mode)
              (insert (format "%d candidates:\n" (length ivy--old-cands)))
              (read-only-mode)
              (ivy--occur-insert-lines
               ivy--old-cands)))
          (setf (ivy-state-text ivy-last) ivy-text)
          (setq ivy-occur-last ivy-last)
          (setq-local ivy--directory ivy--directory)
          ;; ar addition.
          (ivy-wgrep-change-to-wgrep-mode))
        (ivy-exit-with-action
         (lambda (_)
           (pop-to-buffer buffer)
           ;; ar addition.
           (delete-other-windows))))))

  (defun ar/counsel-ag--strip-insert-item (item)
    "Strip ITEM of file info.
For example:

\"some-file.el:43:  gimme this text only\"
=> \"  gimme this text only\"
"
    (let ((line (if (stringp item)
                    item
                  (car x))))
      (if (string-match ":[0-9]*:\\(.*\\)" line)
          (insert (match-string 1 line))
        (insert line))))

  (defun ar/counsel-ag (arg)
    (interactive "P")
    (ivy-set-actions
     'counsel-rg
     `(("i" ,'ar/counsel-ag--strip-insert-item
        "insert")))
    (ivy-set-actions
     'counsel-ag
     `(("i" ,'ar/counsel-ag--strip-insert-item
        "insert")))
    (ivy-set-actions
     'counsel-pt
     `(("i" ,'ar/counsel-ag--strip-insert-item
        "insert")))
    (ivy-set-actions
     'counsel-ack
     `(("i" ,'ar/counsel-ag--strip-insert-item
        "insert")))

    (defvar ar/counsel-ag--default-locaction nil)
    (when (or arg (not ar/counsel-ag--default-locaction))
      ;; Prefix consumed by ar/counsel-ag. Avoid counsel-ag from using.
      (setq current-prefix-arg nil)
      (ar/vsetq ar/counsel-ag--default-locaction
                (read-directory-name "search in: " default-directory nil t)))

    (let ((kmap counsel-ag-map))
      (define-key kmap (kbd "C-x C-f") (lambda ()
                                         (interactive)
                                         (ivy-quit-and-run
                                           (ar/counsel-ag t))))

      (define-key kmap (kbd "<tab>") (lambda ()
                                       (interactive)
                                       ;; First invocation calls ivy-call.
                                       ;; Second invocation calls ivy-alt-done.
                                       (if (eq this-command last-command)
                                           (ivy-alt-done)
                                         (ivy-call))))
      (cond ((executable-find "rg")
             (counsel-rg nil ar/counsel-ag--default-locaction))
            ((executable-find "pt")
             (counsel-pt nil ar/counsel-ag--default-locaction))
            ((executable-find "ag")
             (counsel-ag nil ar/counsel-ag--default-locaction))
            (t
             (counsel-ack nil ar/counsel-ag--default-locaction)))))

  (defun ar/wgrep-finish-edit ()
    (interactive)
    (let ((wgrep-auto-save-buffer t))
      (wgrep-finish-edit))
    (quit-window)
    (set-window-configuration ar/ivy-occur--win-config)
    (select-window (nth 0 (window-list))))

  (defun ar/wgrep-abort-changes ()
    (interactive)
    (wgrep-abort-changes)
    (quit-window)
    (set-window-configuration ar/ivy-occur--win-config)
    (select-window (nth 0 (window-list))))

  ;; Smex handles M-x command sorting. Bringing recent commands to the top.
  (use-package smex
    :ensure t)

  ;; Wgrep is used by counsel-ag (to make writeable).
  (use-package wgrep
    :ensure t)

  ;; https://oremacs.com/2017/08/04/ripgrep/
  (when (executable-find "rg")
    (ar/csetq counsel-grep-base-command
              "rg -i -M 120 --no-heading --line-number --color never '%s' %s"))

  (counsel-mode +1))

(use-package swiper
  :ensure t
  :bind (("C-s" . ar/swiper-isearch-dwim)
         ("C-r" . ar/swiper-isearch-backward-dwim)
         :map swiper-isearch-map
         ("C-r" . ivy-previous-line))
  :config
  (defun ar/swiper-isearch-backward-dwim ()
    (interactive)
    (let ((ivy-wrap t))
      (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
          (let ((region (buffer-substring-no-properties (mark) (point))))
            (deactivate-mark)
            (swiper-isearch-backward region))
        (swiper-isearch-backward))))

  (defun ar/swiper-isearch-dwim ()
    (interactive)
    (let ((ivy-wrap t))
      (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
          (let ((region (buffer-substring-no-properties (mark) (point))))
            (deactivate-mark)
            (swiper-isearch region))
        (swiper-isearch)))))

(use-package counsel-projectile
  :ensure t
  :bind ("C-x f" . counsel-projectile-find-file))

(use-package ivy
  :ensure t
  :defer 0.1
  :init
  (global-unset-key (kbd "M-o"))
  :bind (("C-x C-b" . ivy-switch-buffer)
         ("C-c C-r" . ivy-resume)
         ("M-o" . ar/insert-current-file-name-at-point)
         :map ivy-minibuffer-map
         ("C-g" . ar/ivy-keyboard-quit-dwim)
         ("C--" . ivy-minibuffer-shrink)
         ("C-+" . ivy-minibuffer-grow))
  :config
  (ar/vsetq ivy-height 15)
  (ar/vsetq ivy-count-format "")
  (ar/vsetq ivy-use-virtual-buffers t)
  (ar/vsetq ivy-display-style 'fancy)
  (ar/vsetq ivy-wrap nil)
  (ar/vsetq enable-recursive-minibuffers t)

  (add-hook 'minibuffer-setup-hook
            (lambda ()
              (setq truncate-lines nil)))

  ;; From http://mbork.pl/2019-02-17_Inserting_the_current_file_name_at_point
  (defun ar/insert-current-file-name-at-point (&optional full-path)
    "Insert the current filename at point.
With prefix argument, use full path."
    (interactive "P")
    (let* ((buffer
	    (if (minibufferp)
	        (window-buffer
	         (minibuffer-selected-window))
	      (current-buffer)))
	   (filename (buffer-file-name buffer)))
      (if filename
	  (insert (if full-path filename (file-name-nondirectory filename)))
        (error (format "Buffer %s is not visiting a file" (buffer-name buffer))))))

  (defun ar/ivy-keyboard-quit-dwim ()
    "If region active, deactivate. If there's content, minibuffer. Otherwise quit."
    (interactive)
    (cond ((and delete-selection-mode (region-active-p))
           (setq deactivate-mark t))
          ((> (length ivy-text) 0)
           (delete-minibuffer-contents))
          (t
           (minibuffer-keyboard-quit))))

  (ar/vsetq ivy-initial-inputs-alist
            '((org-refile . "^")
              (org-agenda-refile . "^")
              (org-capture-refile . "^")
              (counsel-describe-function . "^")
              (counsel-describe-variable . "^")
              (counsel-org-capture . "^")
              (Man-completion-table . "^")
              (woman . "^")))

  (ivy-mode +1)

  (use-package ivy-rich
    :ensure t
    :config
    (setq ivy-rich--display-transformers-list
          '(counsel-M-x
            (:columns
             ((counsel-M-x-transformer (:width 80))  ; the original transfomer
              (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))))
    (ivy-rich-mode +1))

  ;; Unsure about this one.
  ;; (use-package ivy-posframe
  ;;   :ensure t
  ;;   :config
  ;;   ;; (push '(counsel-M-x . ivy-posframe-display-at-frame-center) ivy-display-functions-alist)
  ;;   ;; (push '(ivy-switch-buffer . ivy-posframe-display-at-frame-center) ivy-display-functions-alist)
  ;;   ;; (push '(t . ivy-posframe-display) ivy-display-functions-alist)
  ;;   (setq ivy-display-function #'ivy-posframe-display)
  ;;   (ivy-posframe-enable))
  )

;; Displays yasnippet previous inline when cycling through results.
(use-package ivy-yasnippet
  :ensure t
  :commands ivy-yasnippet)

(use-package ar-counsel-find
  :commands ar/counsel-find)

(use-package ar-ivy-org
  :commands (ar/ivy-org-add-bookmark
             ar/ivy-org-add-backlog-link
             ar/ivy-org-my-todos))

(use-package counsel-dash
  :commands counsel-dash
  :ensure t)


(defun ar/counsel-ag (arg)
  (interactive "P")
  (defvar ar/counsel-ag--default-locaction nil)
  (when (or arg (not ar/counsel-ag--default-locaction))
    ;; Prefix consumed by ar/counsel-ag. Avoid counsel-ag from using.
    (setq current-prefix-arg nil)
    (ar/vsetq ar/counsel-ag--default-locaction
              (read-directory-name "search in: " default-directory nil t)))

  (let ((kmap counsel-ag-map))
    (define-key kmap (kbd "C-x C-f") (lambda ()
                                       (interactive)
                                       (ivy-quit-and-run
                                         (ar/counsel-ag t))))
    (cond ((executable-find "rg")
           (counsel-rg nil ar/counsel-ag--default-locaction))
          ((executable-find "pt")
           (counsel-pt nil ar/counsel-ag--default-locaction))
          ((executable-find "ag")
           (counsel-ag nil ar/counsel-ag--default-locaction))
          (t
           (counsel-ack nil ar/counsel-ag--default-locaction)))))
