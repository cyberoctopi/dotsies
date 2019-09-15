(require 'ar-vsetq)
(require 'ar-csetq)

(use-package projectile
  :ensure t
  :defer 2
  :ensure-system-package fd
  :config
  (ar/csetq projectile-dynamic-mode-line nil)
  (ar/vsetq projectile-enable-caching t)
  (ar/vsetq projectile-completion-system 'ivy)
  ;; Use `hybrid' since `alien' ignores .projectile file, which is
  ;; handy for very large repositories.
  (ar/vsetq projectile-indexing-method 'hybrid)
  ;; fd is super fast. Use it if available.
  (ar/vsetq projectile-project-root-files-functions
            '(projectile-root-local
              projectile-root-bottom-up))
  (when (executable-find "fd")
    (let ((fd-command "fd . --print0"))
      (ar/vsetq projectile-hg-command fd-command)
      (ar/vsetq projectile-git-command fd-command)
      (ar/vsetq projectile-fossil-command fd-command)
      (ar/vsetq projectile-bzr-command fd-command)
      (ar/vsetq projectile-darcs-command fd-command)
      (ar/vsetq projectile-svn-command fd-command)
      (ar/vsetq projectile-generic-command fd-command)))
  (projectile-mode))

(use-package dired
  :hook (dired-mode . dired-hide-details-mode)
  :bind (:map global-map
              ("C-l" . dired-jump)
              :map dired-mode-map
              ("j" . dired-next-line)
              ("k" . dired-previous-line)
              ;; Go to parent directory.
              ("^" . ar/file-find-alternate-parent-dir)
              ("RET" . dired-find-file)
              ("P" . peep-dired)
              ("i" . dired-hide-details-mode)
              ("C-l". dired-jump)
              ("M" . ar/dired-mark-all))
  :commands (dired-mode
             ar/find-all-dired-current-dir
             ar/dired-mark-all
             ar/file-find-alternate-parent-dir)
  :custom (dired-recursive-copies 'always)
  :init
  (defun ar/file-find-alternate-parent-dir ()
    "Open parent dir."
    (interactive)
    (find-alternate-file ".."))

  (defun ar/dired-mark-all ()
    (interactive)
    (dired-mark-files-regexp ""))

  (defun ar/find-all-dired-current-dir ()
    "Invokes `find-dired' for current dir."
    (interactive)
    (let ((dir (if buffer-file-name
                   (file-name-directory buffer-file-name)
                 ".")))
      (find-dired dir "'(' -name .svn -o -name .git ')' -prune -o -type f")))

  ;; https://oremacs.com/2015/02/15/sudo-stuffs/
  (defun ar/sudired ()
    (interactive)
    (require 'tramp)
    (let ((dir (expand-file-name default-directory)))
      (if (string-match "^/sudo:" dir)
          (user-error "Already in sudo")
        (dired (concat "/sudo::" dir)))))

  :config
  (use-package wdired
    :config
    (ar/csetq wdired-create-parent-directories t)
    (ar/csetq dired-allow-to-change-permission t))

  ;; For dired-jump.
  (use-package dired-x)

  (use-package peep-dired
    :ensure t
    :bind (:map dired-mode-map
                ("P" . peep-dired)))

  (use-package dired-subtree :ensure t
    :bind (:map dired-mode-map
                ("<tab>" . dired-subtree-toggle)
                ("<backtab>" . dired-subtree-cycle)))

  ;; Adding human readable units and sorted by date.
  (ar/vsetq dired-listing-switches "-Alht")

  ;; Try to guess the target directory for operations.
  (ar/vsetq dired-dwim-target t)

  ;; Enable since disabled by default.
  (put 'dired-find-alternate-file 'disabled nil)

  ;; Automatically refresh dired buffers when contents changes.
  (ar/vsetq dired-auto-revert-buffer t)

  ;; Hide some files
  (setq dired-omit-files "^\\..*$\\|^\\.\\.$")
  (setq dired-omit-mode t)

  (defun ar/dired-du-size-of-selection ()
    "Print size of selected dired files or directories."
    (interactive)
    (let ((files (dired-get-marked-files)))
      (with-temp-buffer
        (apply 'call-process "du" nil t nil "-csh" files)
        (message "Size of all marked files: %s"
                 (progn
                   (re-search-backward "\\(^[0-9.,]+[A-Za-z]+\\).*total$")
                   (match-string 1))))))

  ;; Predownloaded to ~/.emacs.d/downloads
  (use-package tmtxt-dired-async
    :config
    (use-package tmtxt-async-tasks)))

(use-package openwith
  :ensure t
  :config
  (ar/csetq openwith-associations
            (cond
             ((string-equal system-type "darwin")
              '(("\\.\\(dmg\\|doc\\|docs\\|xls\\|xlsx\\)$"
                 "open" (file))
                ("\\.\\(mp4\\|mp3\\|mkv\\|webm\\|avi\\|flv\\|mov\\)$"
                 "open" ("-a" "VLC" file))))
             ((string-equal system-type "gnu/linux")
              '(("\\.\\(mp4\\|mp3\\|mkv\\|webm\\|avi\\|flv\\|mov\\)$"
                 "xdg-open" (file))))))
  (openwith-mode +1))

(use-package tramp
  :config
  ;; make sure vc stuff is not making tramp slower
  (setq vc-ignore-dir-regexp
	(format "%s\\|%s"
		vc-ignore-dir-regexp
		tramp-file-name-regexp)))
