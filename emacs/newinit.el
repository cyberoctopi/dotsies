;;; Init.el GC values (undone at end).
(setq gc-cons-threshold (* 384 1024 1024)
      gc-cons-percentage 0.6)

;;; Temprarily avoid loading modes during init (undone at end).
(defvar ar/init--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Match theme color early on, so loading experience is smoother.
(set-background-color "#1b181b")

;; Transparent titlebar on
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)) ; nil for dark text
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

;; Hide UI (early on).

;; Don't want a mode line while loading init.
(setq mode-line-format nil)

;; No scrollbar by default.
(when (fboundp 'toggle-scroll-bar) (toggle-scroll-bar -1))
;; No nenubar by default.
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
;; No toolbar by default.
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;; No Alarms.
(setq ring-bell-function 'ignore)

;; Additional load paths.
(add-to-list 'load-path "~/.emacs.d/ar")
(add-to-list 'load-path "~/.emacs.d/local")
(add-to-list 'load-path "~/.emacs.d/external")

;; Ask shell for PATH, MANPATH, and exec-path and update Emacs environment.
;; We do this early on as we assert binaries are installed throughout
;; init.
(load-file (expand-file-name "~/.emacs.d/downloads/exec-path-from-shell/exec-path-from-shell.el"))
(require 'exec-path-from-shell)
(exec-path-from-shell-initialize)

;; macOS basics.
(when (string-equal system-type "darwin")
  (menu-bar-mode 1)
  ;; Fixes mode line separator issues on macOS.
  (setq ns-use-srgb-colorspace nil)
  (setq mac-command-modifier 'meta)
  (setq exec-path (append exec-path '("~/homebrew/bin"
                                      "~/homebrew/Cellar/llvm/HEAD/bin"
                                      "/usr/local/bin"))))

;;;; Set up package tls START

(require 'cl)
(require 'package)

;; Don't auto-initialize!
(setq package-enable-at-startup nil)

;; Don't add that `custom-set-variables' block to initl.
(setq package--init-file-ensured t)

(require 'tls)

(assert (executable-find "gnutls-cli") nil
        "Need brew install gnutls or apt-get install gnutls-bin")
(assert (eq 0 (call-process-shell-command "python -c \"import certifi\"")) nil
        "Need python -m pip install --user certifi")

(let ((trustfile
       (replace-regexp-in-string
        "\\\\" "/"
        (replace-regexp-in-string
         "\n" ""
         (shell-command-to-string "python -m certifi")))))
  (setq tls-program
        (list
         (format "gnutls-cli --x509cafile %s -p %%p %%h" trustfile)))
  (setq gnutls-trustfiles (list trustfile)))

(setq tls-checktrust t)
(setq package-archives `(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;;;; Set up package tls END

;;;; Set up use-package START

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; use-package-enable-imenu-support must be
;; set before requiring use-package.
(setq use-package-enable-imenu-support t)
(require 'use-package)
(setq use-package-verbose t)

(use-package async
  :ensure t
  :config
  (async-bytecomp-package-mode +1))

(use-package use-package-ensure-system-package
  :ensure t)

;;;; Set up use-package END

;;;; Init helpers START

(use-package validate
  :ensure t
  :config
  (defalias 'vsetq 'validate-setq))

;; https://oremacs.com/2015/01/17/setting-up-ediff
;; Macro for setting custom variables.
;; Similar to custom-set-variables, but more like setq.
(defmacro csetq (variable value)
  `(funcall (or (get ',variable 'custom-set)
                'set-default)
            ',variable ,value))

;;;; Init helpers END

;;;; Appearance START

;; Get rid of splash screens.
;; From http://www.emacswiki.org/emacs/EmacsNiftyTricks
(vsetq inhibit-splash-screen t)
(vsetq initial-scratch-message nil)

(when (display-graphic-p)
  ;; Enable if you'd like to start as fullscreen.
  ;; (set-frame-parameter nil 'fullscreen 'fullboth)
  ;; Don't want titles in frames.
  (vsetq frame-title-format '("Ⓔ ⓜ ⓐ ⓒ ⓢ")))

(use-package base16-theme
  :ensure t
  :config
  (load-theme 'base16-atelier-heath t)
  (let ((line (face-attribute 'mode-line :underline)))
    (set-face-attribute 'mode-line          nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :underline  line)
    (set-face-attribute 'mode-line          nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :background "#695d69")))

;; No color for fringe, blends with the rest of the window.
(set-face-attribute 'fringe nil :background nil)

;; Ensure window is maximized after window setup.
(use-package maxframe
  :ensure t
  :hook (window-setup . maximize-frame))

(use-package moody
  :ensure t
  :config
  (vsetq x-underline-at-descent-line t)
  (setq-default mode-line-format
                '(" "
                  mode-line-front-space
                  mode-line-client
                  mode-line-frame-identification
                  mode-line-buffer-identification " " mode-line-position
                  (vc-mode vc-mode)
                  (multiple-cursors-mode mc/mode-line)
                  " " mode-line-modes
                  mode-line-end-spaces))
  (use-package minions
    :ensure t
    :config
    (minions-mode +1))
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

(use-package fullframe
  :ensure t
  :commands fullframe)

;;;; Appearance END

;;; Base libraries START

(use-package s
  :ensure t)

;;; Base libraries END

;;;; Init maintenance START

;; Find errors in init.el by bisecting the file.
(use-package bug-hunter
  :ensure t
  :commands bug-hunter-init-file)

;; Restart Emacs from Emacs.
(use-package restart-emacs
  :ensure t
  :commands restart-emacs)

(use-package esup
  :ensure t
  :commands esup)

;; Peak into macros by expanding them inline.
(use-package macrostep
  :ensure t
  :commands macrostep-expand)

(defun ar/edit-init ()
  (interactive)
  (find-file "~/stuff/active/code/dots/emacs/newinit.el"))
;;;; Init maintenance END

;;;; Editing START

;; Prevent Extraneous Tabs.
;; From http://www.gnu.org/software/emacs/manual/html_node/eintr/Indent-Tabs-Mode.html
(setq-default indent-tabs-mode nil)

(use-package expand-region
  :ensure t
  :bind ("C-c w" . er/expand-region))

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

(use-package whitespace
  :defer 5
  ;; Automatically remove whitespace on saving.
  :hook ((before-save . whitespace-cleanup)
         (prog-mode . whitespace-mode))
  :config
  ;; When nil, fill-column is used instead.
  (vsetq whitespace-line-column nil)
  ;; Highlight empty lines, TABs, blanks at beginning/end, lines
  ;; longer than fill-column, and trailing blanks.
  (vsetq whitespace-style '(face empty tabs lines-tail trailing))
  (vsetq show-trailing-whitespace t)
  (set-face-attribute 'whitespace-line nil
                      :foreground "DarkOrange1"
                      :background "default"))

(use-package smartparens
  :ensure t
  :defer 0.01
  ;; Add to minibuffer also.
  :hook ((minibuffer-setup . smartparens-mode)
         (prog-mode . smartparens-strict-mode)
         (eshell-mode . smartparens-strict-mode))
  :config
  (require 'smartparens-config)
  (require 'smartparens-html)
  (require 'smartparens-python)

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
              'ar/kill-region-advice-fun)

  ;; I prefer keeping C-w to DWIM kill, provided by
  ;; `ar/kill-region-advice-fun'. Removing remap.
  ;;   (define-key smartparens-strict-mode-map [remap kill-region] nil)

  (defun ar/smartparens-wrap-square-bracket (arg)
    "[] equivalent of `paredit-wrap-round'."
    (interactive "P")
    (save-excursion
      (unless (sp-point-in-symbol)
        (backward-char))
      (sp-wrap-with-pair "["))
    (insert " "))

  :bind (:map smartparens-strict-mode-map
              ([remap kill-region] . kill-region)
              ("C-c <right>" . sp-forward-slurp-sexp)
              ("C-c <left>" . sp-forward-barf-sexp)
              ("M-[" . sp-rewrap-sexp)
              :map smartparens-mode-map
              ("M-]" . ar/smartparens-wrap-square-bracket)))


(use-package region-bindings-mode
  :ensure t
  :defer 2
  :config
  (region-bindings-mode-enable))

(use-package multiple-cursors :ensure t
  :after region-bindings-mode
  :init
  (global-unset-key (kbd "M-<down-mouse-1>"))
  :bind (("C-c a" . mc/mark-all-like-this)
         ("C-c n" . mc/mark-more-like-this-extended)
         ("M-1" . mc/mark-next-like-this)
         ("M-!" . mc/unmark-next-like-this)
         ("M-2" . mc/mark-previous-like-this)
         ("M-@" . mc/unmark-previous-like-this)
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

(defun ar/duplicate-line ()
  "Duplicate current line and paste below."
  (interactive)
  (let ((line-text (buffer-substring (line-beginning-position)
                                     (line-end-position))))
    (end-of-line)
    (newline)
    (insert line-text)))

(bind-key "C-x C-d" #'ar/duplicate-line)

(use-package hungry-delete
  :defer 5
  :ensure t
  :config (global-hungry-delete-mode))

(use-package delsel
  :defer 5
  :config
  ;; Override selection with new text.
  (delete-selection-mode +1))

(use-package ar-text
  :bind (("C-c c" . ar/text-capitalize-word-toggle)
         ("C-c r" . set-rectangular-region-anchor)))

;;;; Editing END

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  :config
  (add-to-list 'magit-no-confirm 'stage-all-changes)
  (message "magit")
  (fullframe magit-status magit-mode-quit-window))

(use-package with-editor :ensure t
  :hook ((eshell-mode . with-editor-export-editor)
         (term-exec . with-editor-export-editor)
         (shell-mode . with-editor-export-editor)))

;; Ivy equivalents to Emacs commands.
(use-package counsel
  :ensure t
  :defer 0.1
  :config
  ;; Smex handles M-x command sorting. Bringing recent commands to the top.
  (use-package smex
    :ensure t)
  (counsel-mode +1))

(use-package ivy
  :ensure t
  :defer 0.1
  :config
  (vsetq ivy-height 40)
  (vsetq ivy-count-format "")
  (vsetq ivy-use-virtual-buffers t)
  (vsetq enable-recursive-minibuffers t)
  (ivy-mode +1))

;;;; Navigation START
(use-package isearch
  :commands (isearch-forward isearch-backward)
  :defer 5
  :preface
  (provide 'isearch)
  :config
  (use-package char-fold)

  (vsetq search-default-mode #'char-fold-to-regexp)

  ;; Prepopulate isearch with selectionn.
  ;; From http://www.reddit.com/r/emacs/comments/2amn1v/isearch_selected_text
  (defadvice isearch-mode (around isearch-mode-default-string
                                  (forward &optional regexp op-fun recursive-edit word-p) activate)
    "Enable isearch to start with current selection."
    (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
        (progn
          (isearch-update-ring (buffer-substring-no-properties (mark) (point)))
          (deactivate-mark)
          ad-do-it
          (if (not forward)
              (isearch-repeat-backward)
            (goto-char (mark))
            (isearch-repeat-forward)))
      ad-do-it)))

;; From http://endlessparentheses.com/emacs-narrow-or-widen-dwim.html
(defun ar/narrow-or-widen-dwim (p)
  "Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or defun,
whichever applies first. Narrowing to org-src-block actually
calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is
already narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((derived-mode-p 'org-mode)
         ;; `org-edit-src-code' is not a real narrowing
         ;; command. Remove this first conditional if you
         ;; don't want it.
         (cond ((ignore-errors (org-edit-src-code))
                (delete-other-windows))
               ((ignore-errors (org-narrow-to-block) t))
               (t (org-narrow-to-subtree))))
        ((derived-mode-p 'latex-mode)
         (LaTeX-narrow-to-environment))
        (t (narrow-to-defun))))

(bind-key "C-x n n" #'ar/narrow-or-widen-dwim)

(use-package swiper
  :ensure t
  :bind ("M-i" . swiper))

;; Smarter move to beginning/end of line.
(use-package mwim
  :ensure t
  :bind (("C-a" . mwim-beginning-of-code-or-line)
         ("C-e" . mwim-end-of-code-or-line)))

(use-package centered-cursor-mode
  :defer 0.1
  :ensure t
  :pin melpa
  :init
  ;; Workaround to use centered-cursor-mode in --nw.
  (defvar mouse-wheel-mode nil)
  :config
  (global-centered-cursor-mode +1))

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :ensure t
  :bind (("C-c <up>" . git-gutter:previous-hunk)
         ("C-c <down>" . git-gutter:next-hunk)))

;; In addition to highlighting, we get navigation between
(use-package highlight-symbol
  :hook ((prog-mode . highlight-symbol-mode)
         (prog-mode . highlight-symbol-nav-mode))
  :ensure t
  :bind (:map highlight-symbol-nav-mode-map
              (("M-n" . highlight-symbol-next)
               ("M-p" . highlight-symbol-prev)))
  :config
  (set-face-attribute 'highlight-symbol-face nil
                      :background "default"
                      :foreground "yellow")
  (vsetq highlight-symbol-idle-delay 0.2)
  (vsetq highlight-symbol-on-navigation-p t))

;;;; Navigation END

;;;; Helm START

(use-package helm
  ;; Save current position to mark ring when jumping to a different place
  :hook  (helm-goto-line-before . helm-save-current-pos-to-mark-ring)
  :ensure t
  :config
  (use-package helm-utils)
  (use-package helm-elisp)

  ;; Helm now defaults to 'helm-display-buffer-in-own-frame. Override this behavior.
  (vsetq helm-show-completion-display-function #'helm-default-display-buffer)
  (vsetq helm-scroll-amount 4) ; scroll 4 lines other window using M-<next>/M-<prior>
  (vsetq helm-input-idle-delay 0.01) ; be idle for this many seconds, before updating candidate buffer
  (vsetq helm-split-window-default-side 'below) ;; open helm buffer below.
  (vsetq helm-split-window-in-side-p t)
  (vsetq helm-candidate-number-limit 200)

  (use-package helm-config)

  (use-package helm-imenu
    :defer t
    :config
    (use-package imenu
      :config
      ;; Automatically rescan for imenu changes.
      (set-default 'imenu-auto-rescan t))
    (use-package imenu-anywhere
      :ensure t))

  ;; Best way (so far) to search for files in repo.
  (use-package helm-projectile
    :ensure t
    :bind ("C-x f" . helm-projectile))

  (defun ar/helm-keyboard-quit-dwim (&optional arg)
    "First time clear miniuffer. Quit thereafter."
    (interactive "P")
    (if (> (length (minibuffer-contents)) 0)
        (call-interactively 'helm-delete-minibuffer-contents)
      (helm-keyboard-quit)))

  :bind (("C-c i" . helm-semantic-or-imenu)
         :map helm-map
         ("C-i" . helm-execute-persistent-action) ; make TAB works in terminal
         ("C-z" . helm-select-action) ; list actions using C-z
         ("M-p" . helm-previous-source)
         ("M-n" . helm-next-source)
         ("C-g" . ar/helm-keyboard-quit-dwim)))

(use-package helm-ag
  :ensure t
  :commands (ar/helm-ag
             ar/find-dired-current-dir
             ar/find-all-dired-current-dir
             ar/helm-ag-insert)
  :config
  (defun ar/helm-ag-insert (arg)
    ;; Helm-ag and insert match.
    (interactive "P")
    (defun ar/insert-candidate (candidate)
      (move-beginning-of-line 1)
      (unless (eolp)
        (kill-line))
      ;; Drop file:line:column. For example:
      ;; arc_hostlink.c:13:2:#include <linux/fs.h>
      ;; => #include <linux/fs.h>
      (insert (replace-regexp-in-string "^[^ ]*:" "" candidate))
      (indent-for-tab-command))
    (let ((helm-source-do-ag (helm-build-async-source "Silver Searcher inserter"
                                                      :init 'helm-ag--do-ag-set-command
                                                      :candidates-process 'helm-ag--do-ag-candidate-process
                                                      :action 'ar/insert-candidate
                                                      :nohighlight t
                                                      :requires-pattern 3
                                                      :candidate-number-limit 9999
                                                      :keymap helm-do-ag-map)))
      (call-interactively #'ar/helm-ag)))

  (defun ar/helm-ag (arg)
    "Helm-ag search remembering last location.  With ARG, forget the last location."
    (interactive "P")
    (defvar ar/helm-ag--default-locaction nil)
    (when (or arg (not ar/helm-ag--default-locaction))
      (vsetq ar/helm-ag--default-locaction
             (read-directory-name "search in: " default-directory nil t)))
    (helm-do-ag ar/helm-ag--default-locaction))

  (defun ar/find-dired-current-dir ()
    "Find files from current location."
    (interactive)
    (helm-find t))

  (defun ar/find-all-dired-current-dir ()
    "Invokes `find-dired' for current dir."
    (interactive)
    (let ((dir (if buffer-file-name
                   (file-name-directory buffer-file-name)
                 ".")))
      (find-dired dir "'(' -name .svn -o -name .git ')' -prune -o -type f")))


  (cond ((executable-find "rg")
         (vsetq helm-ag-base-command "rg --vimgrep --no-heading --ignore-case"))
        ((executable-find "pt")
         (vsetq helm-ag-base-command "pt -e --nocolor --nogroup"))
        ((executable-find "ag")
         (vsetq helm-ag-base-command "ag --nocolor --nogroup"))
        (t
         (vsetq helm-ag-base-command "ack --nocolor --nogroup"))))

(use-package ar-helm-org
  :commands (ar/helm-org-add-bookmark
             ar/helm-org-add-backlog-link))

;;;; Helm END

;;;; Less important START

(use-package ar-platform
  :commands (ar/platform-open-in-external-app
             ar/platform-new-browser-tab
             ar/platform-open-file-at-point))

(use-package ar-file
  :commands (ar/file-open-closest-build-file))

;;;; Less important END

;;;; Hydra START
(use-package hydra
  :ensure t
  :defer 5
  :config
  (vsetq hydra-is-helpful t)
  (defhydra hydra-search (:color blue)
    "search"
    ("d" ar/helm-ag "search directory")
    ("f" ar/find-dired-current-dir "find file")
    ("a" ar/find-all-dired-current-dir "find all files")
    ("i" ar/helm-ag-insert "insert match")
    ("q" nil "quit"))
  (defhydra hydra-quick-insert (:color blue)
    "
Quick insert: _w_eb bookmark _b_acklog bookmark
              _t_odo _d_one
"
    ("w" ar/helm-org-add-bookmark nil)
    ("b" ar/helm-org-add-backlog-link nil)
    ("t" ar/org-add-todo nil)
    ("d" ar/org-add-done nil)
    ("q" nil nil :color blue))

  (defun ar/hydra-open-dwim ()
    "Choose \"open\" hydra based on current mode."
    (interactive)
    (cond ((derived-mode-p 'c-mode) (hydra-open-c-mode/body))
          ((derived-mode-p 'prog-mode) (hydra-open-prog-mode/body))
          (t (hydra-open/body))))

  (defhydra hydra-open-c-mode (:color blue)
    "open"
    ("o" ff-find-other-file "other")
    ("e" ar/platform-open-in-external-app "externally")
    ("u" ar/platform-open-file-at-point "url at point")
    ("b" ar/file-open-closest-build-file "build file")
    ("q" nil "cancel"))

  (defhydra hydra-open (:color blue)
    "
Open: _p_oint _e_xternally
"
    ("e" ar/platform-open-in-external-app nil)
    ("p" ar/platform-open-file-at-point nil)
    ("q" nil "cancel"))

  (defhydra hydra-open-prog-mode (:color blue)
    "open"
    ("o" ff-find-other-file "other")
    ("e" ar/platform-open-in-external-app "externally")
    ("u" ar/platform-open-file-at-point "url at point")
    ("b" ar/file-open-closest-build-file "build file")
    ("q" nil "cancel"))

  (defhydra hydra-git-gutter (:pre (git-gutter-mode +1))
    "
Git: _n_ext     _s_tage  _d_iff
     _p_revious _k_ill _q_uit
"
    ("n" git-gutter:next-hunk nil)
    ("p" git-gutter:previous-hunk nil)
    ("s" git-gutter:stage-hunk nil)
    ("k" (lambda ()
           (interactive)
           (git-gutter:revert-hunk)
           (call-interactively #'git-gutter:next-hunk)) nil)
    ("d" git-gutter:popup-hunk nil)
    ("q" nil nil :color blue))
  :bind (("C-c s" . hydra-search/body)
         ("C-c x" . hydra-quick-insert/body)
         ("C-c o" . ar/hydra-open-dwim)
         ("C-c g" . hydra-git-gutter/body)))
;;;; Hydra END

;;;; Buffers START

(use-package menu-bar
  ;; No need to confirm killing buffers.
  :bind ("C-x k" . kill-this-buffer))

;;;; Buffers END

;;;; Org START

(use-package org
  :ensure t
  :hook ((org-mode . ar/org-mode-hook-function)
         (org-mode . visual-line-mode))
  :bind (:map org-mode-map
              ("C-c C-l" . ar/org-insert-link-dwim))
  :config
  (setq org-todo-keywords
        '((sequence
           "TODO"
           "STARTED"
           "DONE"
           "OBSOLETE"
           "CANCELLED")))

  (use-package org-faces
    :config
    (vsetq org-todo-keyword-faces
           '(("TODO" . (:foreground "red" :weight bold))
             ("STARTED" . (:foreground "yellow" :weight bold))
             ("DONE" . (:foreground "green" :weight bold))
             ("OBSOLETE" . (:foreground "blue" :weight bold))
             ("CANCELLED" . (:foreground "gray" :weight bold)))))

  (defun ar/org-insert-link-dwim ()
    "Convert selected region into a link with clipboard http link (if one is found). Default to `org-insert-link' otherwise."
    (interactive)
    (if (and (string-match-p "^http" (current-kill 0))
             (region-active-p))
        (let ((region-content (buffer-substring-no-properties (region-beginning)
                                                              (region-end))))
          (delete-region (region-beginning)
                         (region-end))
          (insert (format "[[%s][%s]]"
                          (current-kill 0)
                          region-content)))
      (call-interactively 'org-insert-link)))

  (defun ar/org-mode-hook-function ()
    (toggle-truncate-lines 0)
    (org-display-inline-images)
    (vsetq show-trailing-whitespace t)
    (set-fill-column 1000))

  ;; Look into font-locking email addresses.
  ;; http://kitchingroup.cheme.cmu.edu/blog/category/email/
  ;; (use-package button-lock :ensure t)

  (setq org-refile-targets '((nil . (:regexp . "Week of"))
                             (nil . (:regexp . "RESOLVED"))))

  (vsetq org-ellipsis "…")
  (vsetq org-fontify-emphasized-text t)

  ;; Fontify code in code blocks.
  (vsetq org-src-fontify-natively t)

  ;; When exporting anything, do not insert in kill ring.
  (setq org-export-copy-to-kill-ring nil)

  ;; Display images inline when running in GUI.
  (vsetq org-startup-with-inline-images (display-graphic-p))
  (vsetq org-src-tab-acts-natively t)

  ;; Prevent inadvertently editing invisible areas in Org.
  (vsetq org-catch-invisible-edits 'error)
  (vsetq org-cycle-separator-lines 2)
  (vsetq org-image-actual-width nil)
  (vsetq org-hide-emphasis-markers t)

  ;; All Org leading stars become invisible.
  (vsetq org-hide-leading-stars t)

  ;; Skip Org's odd indentation levels (1, 3, ...).
  (vsetq org-odd-levels-only t)

  ;; Disable auto isearch within org-goto.
  (vsetq org-goto-auto-isearch nil)

  ;; Enable RET to follow Org links.
  (vsetq org-return-follows-link t))

(use-package ar-org
  :commands (ar/org-add-todo
             ar/org-add-done))

(use-package ob
  :after org
  :bind (:map org-mode-map
              ("C-c C-c" . org-ctrl-c-ctrl-c))
  :config
  (vsetq org-export-babel-evaluate nil)

  (use-package ob-objc)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((R . t)
     (ditaa . t)
     (dot . t)
     (emacs-lisp . t)
     (gnuplot . t)
     (haskell . nil)
     (ocaml . nil)
     (python . t)
     (ruby . t)
     (screen . nil)
     (objc . t)
     (shell . t)
     (js . t)
     (sql . nil)
     (sqlite . t))))

;;;; Org END

;;;; Eshell START

(use-package shell-pop
  :ensure t
  :config

  (use-package eshell
    :hook (eshell-mode . ar/eshell-mode-hook-function)
    :init
    (defun ar/eshell-mode-hook-function ()
      ;; Turn off semantic-mode in eshell buffers.
      (semantic-mode -1)

      (eshell-smart-initialize)

      (setq-local global-hl-line-mode nil)

      (add-to-list 'eshell-visual-commands "ssh")
      (add-to-list 'eshell-visual-commands "tail")
      (add-to-list 'eshell-visual-commands "top")

      ;; TODO: Enable company.
      ;; (setq-local company-backends '((company-projectile-cd company-escaped-files)))

      ;; comint-magic-space needs to be whitelisted to ensure we receive company-begin events in eshell.
      (when (boundp 'company-begin-commands)
       (setq-local company-begin-commands
                  (append company-begin-commands (list 'comint-magic-space))))

      (bind-key "C-l" #'ar/eshell-cd-to-parent eshell-mode-map))
    :config
    (use-package em-hist)
    (use-package em-glob)

    (use-package esh-mode
      :config
      ;; Why is validate-setq not finding it?
      (setq eshell-scroll-to-bottom-on-input 'all))

    (use-package em-dirs)
    (use-package em-smart)

    ;; Avoid "WARNING: terminal is not fully functional."
    ;; http://mbork.pl/2018-06-10_Git_diff_in_Eshell
    (setenv "PAGER" "cat")

    (vsetq eshell-where-to-jump 'begin)
    (vsetq eshell-review-quick-commands nil)
    (vsetq eshell-smart-space-goes-to-end t)

    (vsetq eshell-history-size (* 10 1024))
    (vsetq eshell-hist-ignoredups t)
    (vsetq eshell-error-if-no-glob t)
    (vsetq eshell-glob-case-insensitive t)
    (vsetq eshell-list-files-after-cd nil)

    (defun ar/eshell-cd-to-parent ()
      (interactive)
      (goto-char (point-max))
      (insert "cd ..")
      (eshell-send-input nil t))

    (use-package ar-eshell-config))

  ;; Must use custom set for these.
  (csetq shell-pop-window-position "full")
  (csetq shell-pop-shell-type '("eshell" "*eshell*" (lambda ()
                                                      (eshell))))
  (csetq shell-pop-term-shell "eshell")

  (defun ar/shell-pop (shell-pop-autocd-to-working-dir)
    "Shell pop with arg to cd to working dir. Else use existing location."
    (interactive "P")
    ;; shell-pop-autocd-to-working-dir is defined in shell-pop.el.
    ;; Using lexical binding to override.
    (if (string= (buffer-name) shell-pop-last-shell-buffer-name)
        (shell-pop-out)
      (shell-pop-up shell-pop-last-shell-buffer-index)))

  ;; (csetq shell-pop-term-shell "/bin/bash")

  ;; (csetq shell-pop-shell-type '("ansi-term"
  ;;                              "terminal"
  ;;                              (lambda
  ;;                                nil (ansi-term shell-pop-term-shell))))

  :bind (([f5] . ar/shell-pop)))

;;;; Eshell END

;;;; Hammerspoon START

;; Add TODOs modally.
(use-package ar-hammerspoon-org-modal
  :defer 5)

;; Search for index.org bookmarks modally.
(use-package modal-ivy
  :defer 5)

;;;; Hammerspoon END


;;;; Mail START

(use-package ar-mu4e
  :if (locate-library "ar-mu4e")
  :bind (:map global-map
              ("M-m" . ar/mu4e--view-unread-messages)))
;;;; Mail END

(use-package server
  :defer 10
  :config
  (unless (server-running-p)
    (server-start)))

(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Undo GC values post init.el.
            (vsetq gc-cons-threshold 16777216
                   gc-cons-percentage 0.1)
            (run-with-idle-timer 5 t #'garbage-collect)
            (vsetq garbage-collection-messages t)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist ar/init--file-name-handler-alist)))

;; Use a hook so the message doesn't get clobbered by other messages.
;; From https://zzamboni.org/post/my-emacs-configuration-with-commentary
(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Now set GC values post init.el.
            (vsetq gc-cons-threshold 16777216
                   gc-cons-percentage 0.1)
            (run-with-idle-timer 5 t #'garbage-collect)
            (vsetq garbage-collection-messages t)

            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; compile-command: "make newinit"
;; End:
