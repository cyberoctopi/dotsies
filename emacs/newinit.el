;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Init.el GC values (faster loading) ;;;;

(setq gc-cons-threshold (* 384 1024 1024)
      gc-cons-percentage 0.6)

;;; Temporarily avoid loading any modes during init (undone at end).
(defvar ar/init--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Match theme color early on (smoother transition).
;; Theme loaded in features/ui.el.
(set-background-color "#1b181b")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Hide UI (early on) ;;;;

;; Don't want a mode line while loading init.
(setq mode-line-format nil)

;; No scrollbar by default.
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; No nenubar by default.
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; No toolbar by default.
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))

;; No tooltip by default.
(when (fboundp 'tooltip-mode) (tooltip-mode -1))

;; No Alarms by default.
(setq ring-bell-function 'ignore)

;; Get rid of splash screens.
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)

;; Set a fun frame title.
(when (display-graphic-p)
  (setq frame-title-format '("Ⓔ ⓜ ⓐ ⓒ ⓢ")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Set up package tls ;;;;

(require 'package)

;; Don't auto-initialize.
(setq package-enable-at-startup nil)

;; Don't add that `custom-set-variables' block to init.
(setq package--init-file-ensured t)

(require 'tls)

;; From https://github.com/hlissner/doom-emacs/blob/5dacbb7cb1c6ac246a9ccd15e6c4290def67757c/core/core-packages.el#L102
(setq gnutls-verify-error (not (getenv "INSECURE")) ; you shouldn't use this
      tls-checktrust gnutls-verify-error
      tls-program (list "gnutls-cli --x509cafile %t -p %p %h"
                        ;; compatibility fallbacks
                        "gnutls-cli -p %p %h"
                        "openssl s_client -connect %h:%p -no_ssl2 -no_ssl3 -ign_eof"))

(setq package-archives `(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; use-package-enable-imenu-support must be
;; set before requiring use-package.
(setq use-package-enable-imenu-support t)
(require 'use-package)
;; (setq use-package-verbose t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Now kick off non-essential loading ;;;;

(add-hook
 'emacs-startup-hook
 (lambda ()
   ;; Undo GC values post init.el.
   (setq gc-cons-threshold 16777216
         gc-cons-percentage 0.1)
   (run-with-idle-timer 5 t #'garbage-collect)
   (setq garbage-collection-messages t)
   (setq file-name-handler-alist ar/init--file-name-handler-alist)

   ;; Done loading core init.el. Announce it and let the real loading begin.
   (message "Emacs ready in %s with %d garbage collections."
            (format "%.2f seconds" (float-time
                     (time-subtract after-init-time before-init-time)))
            gcs-done)

   ;; Need these loaded ASAP (many subsequent libraries depend on them).
   (load "~/.emacs.d/features/package-extensions.el")
   (load "~/.emacs.d/features/libs.el")
   (load "~/.emacs.d/features/mac.el")
   (load "~/.emacs.d/features/ui.el")

   ;; Additional load paths.
   (add-to-list 'load-path "~/.emacs.d/ar")
   (add-to-list 'load-path "~/.emacs.d/local")
   (add-to-list 'load-path "~/.emacs.d/external")

   (defmacro ar/idle-load (library)
     `(run-with-idle-timer 0.5 nil
                           (lambda ()
                             (load ,library))))

   ;; Load all others on idle.
   (ar/idle-load "~/.emacs.d/features/maintenance.el")
   (ar/idle-load "~/.emacs.d/features/ivy.el")
   (ar/idle-load "~/.emacs.d/features/files.el")
   (ar/idle-load "~/.emacs.d/features/editing.el")
   (ar/idle-load "~/.emacs.d/features/git.el")
   (ar/idle-load "~/.emacs.d/features/navigation.el")
   (ar/idle-load "~/.emacs.d/features/platform.el")
   (ar/idle-load "~/.emacs.d/features/helm.el")
   (ar/idle-load "~/.emacs.d/features/file.el")
   (ar/idle-load "~/.emacs.d/features/hydra.el")
   (ar/idle-load "~/.emacs.d/features/eshell.el")
   (ar/idle-load "~/.emacs.d/features/org.el")
   (ar/idle-load "~/.emacs.d/features/dired.el")
   (ar/idle-load "~/.emacs.d/features/dev.el")
   (ar/idle-load "~/.emacs.d/features/company.el")
   (ar/idle-load "~/.emacs.d/features/objc.el")
   (ar/idle-load "~/.emacs.d/features/elfeed.el")
   (ar/idle-load "~/.emacs.d/features/modal.el")
   (ar/idle-load "~/.emacs.d/features/mail.el")
   (ar/idle-load "~/.emacs.d/features/general.el")

   (dolist (file (file-expand-wildcards "~/.emacs.d/work/*.el"))
     (ar/idle-load file))

   ;; Start Emacs server.
   (ar/idle-load "~/.emacs.d/features/server.el")))

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; compile-command: "make newinit"
;; End:
