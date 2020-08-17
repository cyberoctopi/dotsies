;;; ar-misc.el --- Miscellaneous support. -*- lexical-binding: t; -*-

;;; Commentary:
;; Miscellaneous helpers.


;;; Code:

(defun ar/misc-clipboard-to-qr ()
  "Convert text in clipboard to qrcode and display within Emacs."
  (interactive)
  (let ((temp-file (concat (temporary-file-directory) "qr-code")))
    (if (eq 0 (shell-command (format "qrencode -s10 -o %s %s"
                                     temp-file
                                     (shell-quote-argument (current-kill 0)))
                             "*qrencode*"))
        (switch-to-buffer (find-file-noselect temp-file t))
      (error "Error: Could not create qrcode, check *qrencode* buffer"))))

(defcustom ar/misc-financial-symbols nil "Default financial symbols to look up (cons \"title\" \"symbol\")"
  :type 'list
  :group 'ar-misc)

(defun ar/misc-financial-times-lookup-symbol ()
  "Look up tearsheet for symbol at Financial Times."
  (interactive)
  (ivy-read "Symbol: " ar/misc-financial-symbols
            :action (lambda (item)
                      (assert (consp item) nil "List items must be a cons.")
                      (browse-url (format "https://markets.ft.com/data/funds/tearsheet/charts?s=%s"
                                          (cdr item))))))

;; From https://www.reddit.com/r/emacs/comments/b058f8/weekly_tipstricketc_thread/eilbynr
(defun ar/misc-diff-last-2-yanks ()
  "Run ediff on latest two entries in `kill-ring'."
  (interactive)
  ;; Implementation depends on `lexical-binding' being t, otherwise #'clean-up
  ;; will not be saved as closure to `ediff-cleanup-hook' and thus will lose
  ;; reference to itself.
  (let ((a (generate-new-buffer "*diff-yank*"))
        (b (generate-new-buffer "*diff-yank*")))
    (cl-labels ((clean-up ()
                          (kill-buffer a)
                          (kill-buffer b)
                          (remove-hook 'ediff-cleanup-hook #'clean-up)))
      (add-hook 'ediff-cleanup-hook #'clean-up)
      (with-current-buffer a
        (insert (elt kill-ring 0)))
      (with-current-buffer b
        (insert (elt kill-ring 1)))
      (ediff-buffers a b))))

;; https://gist.github.com/syohex/626af66ba3650252b0a2
(defun ar/misc-hash-region (algorithm beg end)
  "Hash region using ALGORITHM with BEG and END endpoints."
  (interactive
   (list
    (completing-read "Hash type: " '(md5 sha1 sha224 sha256 sha384 sha512))
    (if (use-region-p)
        (region-beginning)
      (point-min))
    (if (use-region-p)
        (region-end)
      (point-max))))
  (message "%s: %s"
           algorithm (secure-hash (intern algorithm) (current-buffer) beg end)))

;; From https://www.reddit.com/r/emacs/comments/b5n1yh/weekly_tipstricketc_thread/ejessje?utm_source=share&utm_medium=web2x
(defun ar/misc-list-faces-for-color (color &optional distance)
  "List faces which use COLOR as fg or bg color.

            Accept colors within DISTANCE which defaults to 0."
  (interactive (list (read-color "Color: ")
                     (and current-prefix-arg
                          (prefix-numeric-value current-prefix-arg))))
  (with-help-window (get-buffer-create (format " *%s*" this-command))
    (dolist (face (sort
                   (ar/misc--list-faces-for-color color distance)
                   (lambda (f1 f2)
                     (string< (symbol-name f1)
                              (symbol-name f2)))))
      (ar/misc-list-faces-print-face face)
      (terpri))))

(defun ar/misc-list-faces-print-face (face)
  "Print face and its parents if any."
  (with-current-buffer standard-output
    (let ((fchain (cdr (ar/list-faces--inheritance-chain face :foreground)))
          (bchain (cdr (ar/list-faces--inheritance-chain face :background))))
      (insert (propertize (format "%s" face) 'face face))
      (cond (fchain
             (dolist (face fchain)
               (insert " > " (propertize (format "%s" face) 'face face))))
            (bchain
             (dolist (face bchain)
               (insert " > " (propertize (format "%s" face) 'face face))))))))

(defun ar/misc--list-faces-inheritance-chain (face attr)
  "Return inheritence change for face and attr."
  (let ((g (face-attribute face attr)))
    (if (and (stringp g)
             (not (string= "unspecified" g)))
        (list face)
      (let ((inherit (face-attribute face :inherit)))
        (when inherit
          (if (facep inherit)
              (cons face
                    (ar/misc--list-faces-inheritance-chain inherit attr))
            (if (consp inherit)
                (cl-dolist (face inherit)
                  (let ((res nil))
                    (when (and (facep face)
                               (setq res (ar/misc--list-faces-inheritance-chain face attr)))
                      (cl-return res)))))))))))

(defun ar/misc--list-faces-attribute (face attr)
  "Get face attribute of face as defined or inherited."
  (let* ((chain (ar/list-faces--inheritance-chain face attr)))
    (cl-dolist (f (nreverse chain))
      (let ((g (face-attribute f attr)))
        (when (and (stringp g)
                   (not (string= "unspecified" g)))
          (cl-return g))))))

(defun ar/misc--list-faces-for-color (color &optional distance)
  "Return all faces with COLOR as fg or bg withing DISTANCE."
  (let ((faces ())
        (distance (or distance 0)))
    (mapatoms (lambda (atom)
                (when (facep atom)
                  (let ((fg (ar/misc--list-faces-attribute atom :foreground))
                        (bg (ar/misc--list-faces-attribute atom  :background)))
                    (when (or (and fg
                                   (<= (color-distance
                                        fg
                                        color)
                                       distance))
                              (and bg
                                   (<= (color-distance
                                        bg
                                        color)
                                       distance)))
                      (push atom faces))))))
    (delete-dups faces)))

(defun ar/misc-pick-font ()
  (interactive)
  (let ((font-name (completing-read "Select font:"
                                    (font-family-list))))
    (if (member font-name (font-family-list))
        (set-face-attribute 'default nil :font font-name)
      (error "'%s' font not found" font-name))))


(defun ar/misc-new-browser-tab ()
  "Open a new browser tab in the default browser."
  (interactive)
  (let ((command (cond
                  ((string-equal system-type "darwin")
                   "open http://google.com")
                  ((string-equal system-type "gnu/linux")
                   "google-chrome http://google.com")
                  (nil))))
    (unless command
      (error "Unrecognized platform"))
    (shell-command command)))

;; Based on http://ergoemacs.org/emacs/emacs_dired_open_file_in_ext_apps.html
(defun ar/misc-open-in-external-app ()
  "Open the current file or dired marked files in external app.
The app is chosen from your OS's preference.

Version 2015-01-26
URL `http://ergoemacs.org/emacs/emacs_dired_open_file_in_ext_apps.html'"
  (interactive)
  (if (eq major-mode 'eww-mode)
      (eww-browse-with-external-browser eww-current-url)
    (let* ((ξfile-list
            (cond ((eq major-mode 'dired-mode)
                   (dired-get-marked-files))
                  (t
                   (list (buffer-file-name)))))
           (ξdo-it-p (if (<= (length ξfile-list) 5)
                         t
                       (y-or-n-p "Open more than 5 files? "))))
      (when ξdo-it-p
        (mapc (ar/misc--open-in-external-app-function) ξfile-list)))))

(defun ar/misc-open-file-at-point ()
  "Open the file path at point.
If there is text selection, uses the text selection for path.
If the path starts with “http://”, open the URL in browser.
Input path can be {relative, full path, URL}.
Path may have a trailing “:‹n›” that indicates line number.
If so, jump to that line number.
If path does not have a file extention, automatically try with “.el” for elisp
files.
This command is similar to `find-file-at-point' but without prompting for
confirmation.

URL `http://ergoemacs.org/emacs/emacs_open_file_path_fast.html'"
  (interactive)
  (let ((ξpath (if (use-region-p)
                   (buffer-substring-no-properties (region-beginning) (region-end))
                 (let (p0 p1 p2)
                   (validate-setq p0 (point))
                   ;; chars that are likely to be delimiters of full path, e.g. space, tabs, brakets.
                   (skip-chars-backward "^  \"\t\n`'|()[]{}<>〔〕“”〈〉《》【】〖〗«»‹›·。\\`")
                   (validate-setq p1 (point))
                   (goto-char p0)
                   (skip-chars-forward "^  \"\t\n`'|()[]{}<>〔〕“”〈〉《》【】〖〗«»‹›·。\\'")
                   (validate-setq p2 (point))
                   (goto-char p0)
                   (buffer-substring-no-properties p1 p2)))))
    (if (string-match-p "\\`https?://" ξpath)
        (browse-url ξpath)
      (progn ; not starting “http://”
        (if (string-match "^\\`\\(.+?\\):\\([0-9]+\\)\\'" ξpath)
            (progn
              (let (
                    (ξfpath (match-string 1 ξpath))
                    (ξline-num (string-to-number (match-string 2 ξpath))))
                (if (file-exists-p ξfpath)
                    (progn
                      (find-file ξfpath)
                      (goto-char 1)
                      (forward-line (1- ξline-num)))
                  (progn
                    (when (y-or-n-p (format "File doesn't exist: %s.  Create? " ξfpath))
                      (find-file ξfpath))))))
          (progn
            (if (file-exists-p ξpath)
                (find-file ξpath)
              (if (file-exists-p (concat ξpath ".el"))
                  (find-file (concat ξpath ".el"))
                (when (y-or-n-p (format "File doesn't exist: %s.  Create? " ξpath))
                  (find-file ξpath ))))))))))

(defun ar/misc--open-in-external-app-function ()
  "Return a function to open FPATH externally."
  (cond
   ((string-equal system-type "darwin")
    (lambda (fPath)
      (shell-command (format "open \"%s\"" fPath))))
   ((string-equal system-type "gnu/linux")
    (lambda (fPath)
      (let ((process-connection-type nil))
        (start-process "" nil "xdg-open" fPath))))))

(provide 'ar-misc)

;;; ar-misc.el ends here
