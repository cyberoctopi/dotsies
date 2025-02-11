;;; -*- lexical-binding: t; -*-

(use-package projectile
  :ensure t
  :defer
  :ensure-system-package fd
  :validate-custom
  (projectile-dynamic-mode-line nil)
  (projectile-enable-caching t)
  (projectile-completion-system 'ivy)
  ;; Use `hybrid' since `alien' ignores .projectile file, which is
  ;; handy for very large repositories.
  (projectile-indexing-method 'hybrid)
  ;; fd is super fast. Use it if available.
  (projectile-project-root-files-functions
   '(projectile-root-local
     projectile-root-bottom-up))
  :config
  (when (executable-find "fd")
    (let ((fd-command "fd . --print0"))
      (require 'validate)
      (validate-setq projectile-hg-command fd-command)
      (validate-setq projectile-git-command fd-command)
      (validate-setq projectile-fossil-command fd-command)
      (validate-setq projectile-bzr-command fd-command)
      (validate-setq projectile-darcs-command fd-command)
      (validate-setq projectile-svn-command fd-command)
      (validate-setq projectile-generic-command fd-command)))

  (defun adviced:projectile-project-root (orig-fun &rest r)
    "Same as `projectile-project-root' but return nil if remote location (ie. tramp)."
    (defvar adviced:projectile-project-root--cache '())
    (let* ((dir (or (nth 0 r) default-directory))
           (cached-root (map-elt adviced:projectile-project-root--cache
                                 dir)))
      (if (file-remote-p dir)
          nil ;; Always ignore remote (pretend they are not projects)
        (if cached-root
            cached-root
          (setq cached-root (apply orig-fun r))
          (map-put adviced:projectile-project-root--cache dir cached-root)
          cached-root))))

  (advice-add #'projectile-project-root
              :around
              #'adviced:projectile-project-root)

  (projectile-mode))

(use-package dired
  :defer
  :hook (dired-mode . dired-hide-details-mode)
  :bind (:map dired-mode-map
              ([remap dired-do-async-shell-command] . ar/dired-do-async-shell-command)
              ([remap dired-do-shell-command] . ar/dired-do-async-shell-command)
              ("j" . dired-next-line)
              ("k" . dired-previous-line)
              ;; Go to parent directory.
              ("^" . ar/file-find-parent-dir)
              ("RET" . dired-find-file)
              ("P" . peep-dired)
              ("i" . dired-hide-details-mode)
              ("s" . hydra-dired-sort/body)
              ("A" . ar/dired-mark-all)
              ("M" . ar/dired-mark-all))
  :commands (dired-mode
             dired
             ar/find-all-dired-current-dir
             ar/dired-mark-all
             ar/file-find-alternate-parent-dir)
  :validate-custom
  (dired-recursive-copies 'always)
  (delete-by-moving-to-trash t)
  :config
  (use-package wdired
    :validate-custom
    (wdired-allow-to-change-permissions t)
    (wdired-create-parent-directories t))

  ;; For dired-jump.
  (use-package dired-x)

  (use-package peep-dired
    :ensure t
    :bind (:map dired-mode-map
                ("P" . peep-dired)))

  ;; Flaten display of nested directories with no other content.
  (use-package dired-collapse
    :ensure t)

  (use-package dired-subtree :ensure t
    :validate-custom
    ;; Adding human readable units and sorted by date.
    ;; -A List all entries except for "." and "..".
    ;; -l List in long format.
    ;; -h Use unites (ie. Byte, Kilobyte, Megabyte).
    ;; -t Sort by time
    ;; -c Use last file status changed time for sorting (show me last download).
    (dired-listing-switches "-Alhtc")
    ;; Try to guess the target directory for operations.
    (dired-dwim-target t)
    ;; Automatically refresh dired buffers when contents changes.
    (dired-auto-revert-buffer t)
    :bind (:map dired-mode-map
                ("<tab>" . dired-subtree-toggle)
                ("<backtab>" . dired-subtree-cycle)))

  ;; Enable since disabled by default.
  (put 'dired-find-alternate-file 'disabled nil)

  ;; Hide some files
  (setq dired-omit-files "^\\..*$\\|^\\.\\.$")
  (setq dired-omit-mode t)

  (defun ar/dired-sort-by-size()
    "Sort dired buffer by size."
    (interactive)
    (dired-sort-other "-AlhS")
    (beginning-of-buffer)
    (next-line))

  (defun ar/dired-sort-by-date ()
    "Sort dired buffer by date."
    (interactive)
    (dired-sort-other "-Alhtc")
    (beginning-of-buffer)
    (next-line))

  (defun ar/dired-sort-by-name ()
    "Sort dired buffer by name."
    (interactive)
    (dired-sort-other "-Alh")
    (beginning-of-buffer)
    (next-line))

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

  (defun ar/dired--async-shell-command (command)
    "Execute async shell COMMAND (replacing $f and $f.ext) with file
 path and path sans extension."
    (cl-letf (((symbol-function 'dired-shell-stuff-it) #'ar/dired-shell-stuff-it))
      (dired-do-async-shell-command command
                                    nil (dired-get-marked-files t nil nil nil t))))

  (defun ar/dired-convert-audio-to-mp3 ()
    (interactive)
    (cl-assert (executable-find "ffmpeg") nil "ffmpeg not installed")
    (ar/dired--async-shell-command "ffmpeg -stats -n -i $f -acodec libmp3lame $f.mp3"))

  (defun ar/dired-convert-image-to-jpg ()
    (interactive)
    (cl-assert (executable-find "convert") nil "Install imagemagick")
    (ar/dired--async-shell-command "convert -verbose $f $f.jpg"))

  (defun ar/dired-convert-image-to-png ()
    (interactive)
    (cl-assert (executable-find "convert") nil "Install imagemagick")
    (ar/dired--async-shell-command "convert -verbose $f $f.png"))

  (defun ar/dired-optimize-gif (&optional arg)
    (interactive "P")
    (cl-assert (executable-find "gifsicle") nil "gifsicle not installed")
    (mapc
     (lambda (fpath)
       (let* ((src-fpath fpath)
              (base-name (file-name-nondirectory (file-name-sans-extension src-fpath)))
              (dst-fpath (format "%s_optimized.gif" (file-name-sans-extension src-fpath)))
              (process (lambda (&rest args)
                         (with-temp-buffer
                           (let ((out (list :exit-status
                                            (apply 'call-process (seq-concatenate
                                                                  'list
                                                                  (list (car args) nil t nil)
                                                                  (cdr args)))
                                            :output
                                            (buffer-string))))
                             (cl-assert (eq (map-elt out :exit-status)
                                            0) nil (map-elt out :output))
                             out)))))
         (message "Processing %s" (file-name-nondirectory src-fpath))
         (funcall process "gifsicle" "-O3" src-fpath "--lossy=80" "-o" dst-fpath)
         (message "Created %s" (file-name-nondirectory dst-fpath))))
     (dired-map-over-marks (dired-get-filename) arg)))

  (defun ar/dired-convert-video-to-gif (&optional arg)
    (interactive "P")
    (cl-assert (executable-find "ffmpeg") nil "ffmpeg not installed")
    (cl-assert (executable-find "gifsicle") nil "gifsicle not installed")
    (mapc
     (lambda (fpath)
       (let* ((src-fpath fpath)
              (base-name (file-name-nondirectory (file-name-sans-extension src-fpath)))
              (dst-fpath (format "%s.gif" (file-name-sans-extension src-fpath)))
              (every (string-to-number
                      (completing-read "Speed up x times: " '("1" "2" "3" "4"))))
              (process (lambda (&rest args)
                         (with-temp-buffer
                           (let ((out (list :exit-status
                                            (apply 'call-process (seq-concatenate
                                                                  'list
                                                                  (list (car args) nil t nil)
                                                                  (cdr args)))
                                            :output
                                            (buffer-string))))
                             (cl-assert (eq (map-elt out :exit-status)
                                            0) nil (map-elt out :output))
                             out)))))
         (message "Processing %s" (file-name-nondirectory src-fpath))
         (funcall process "ffmpeg" "-y" "-i" src-fpath "-pix_fmt" "rgb24" "-r" "15" dst-fpath)
         (apply process (seq-concatenate
                         'list
                         (list "gifsicle" "-U" dst-fpath)
                         ;; Returns #0 #1 #2 ... #framecount.
                         (seq-map (lambda (n)
                                    (format "#%d" n))
                                  (number-sequence 0 (string-to-number
                                            ;; Get total grame count.
                                            (seq-first (process-lines "identify" "-format" "%n\n" dst-fpath)))
                                         every))
                         (list "-O2" "-o" dst-fpath)))
         (message "Created %s" (file-name-nondirectory dst-fpath))))
     (dired-map-over-marks (dired-get-filename) arg)))

  (defun ar/dired-do-async-shell-command ()
  "Like `dired-do-async-shell-command' but supports $f and $f.ext and always sequential."
  (interactive)
  (cl-letf (((symbol-function 'dired-shell-stuff-it) #'ar/dired-shell-stuff-it))
    (call-interactively #'dired-do-async-shell-command)))

  (defun ar/dired-shell-stuff-it (template file-list on-each &optional _raw-arg)
    "Similar to `dired-shell-stuff-it' in spirit, but replaces $f with file from FILE-LIST.
In addition, $f.ext replaces the extension with ext for file in FILE-LIST. Commands are
always executed sequentually."
    (let ((background (string-suffix-p "&" template))
          (command))
      (when background
        (setq template (string-remove-suffix "&" template)))
      (when (string-suffix-p ";" template)
        (setq template (string-remove-suffix ";" template)))
      (concat
       (string-join
        (mapcar (lambda (path)
                  (setq command template)
                  ;; $f (/path/file.jpg)-> /path/file.jpg
                  (when (string-match "[[:blank:]]\\($f\\)\\([[:blank:]]\\|$\\)" command)
                    (setq command (replace-match (format "\"%s\"" path) nil nil command 1)))
                  ;; $f.png (/path/file.jpg) -> /path/file.png
                  (when (string-match "[[:blank:]]\\(\\($f\\)\\.\\([[:alnum:]]+\\)\\)\\([[:blank:]]\\|$\\)" command)
                    (setq command (replace-match (format "\"%s.\\3\"" (file-name-sans-extension path))
                                                 nil nil command 1)))
                  command)
                file-list)
        ";")
       (if background "&" ""))))

  (defun ar/dired-xcode-build-dir ()
    "Open dired buffer in current Xcode's build directory."
    (interactive)
    (unless (executable-find "xcodebuild")
      (error "xcodebuild not found"))
    (let ((default-directory (locate-dominating-file
                              default-directory (lambda (dir)
                                                  (seq-contains-p (directory-files dir)
                                                                  "xcodeproj" (lambda (f ext)
                                                                                (equal (file-name-extension f) ext)))))))
      (unless default-directory
        (user-error "No Xcode project found"))
      (let-alist (seq-elt (json-read-from-string
                           (shell-command-to-string "xcodebuild -showBuildSettings -json"))
                          0)
        (dired (file-name-directory .buildSettings.BUILD_DIR)))))

  (defun ar/dired-create-icns-iconset (&optional arg)
    "Convert image ios icns and iconset (needs 1024x1024)."
    (interactive "P")
    (cl-assert (executable-find "sips") nil "sips not installed")
    (mapc
     (lambda (fpath)
       (let* ((src-fpath fpath)
              (base-name (file-name-nondirectory (file-name-sans-extension src-fpath)))
              (dst-fpath (format "%s.iconset" (file-name-sans-extension src-fpath))))
         (message "Processing %s" (file-name-nondirectory src-fpath))
         (process-lines "mkdir" dst-fpath)
         (process-lines "sips" "-z" "16" "16" src-fpath "--out" (format "%s/icon16x16.png" dst-fpath))
         (process-lines "sips" "-z" "32" "32" src-fpath "--out" (format "%s/icon16x16@2x.png" dst-fpath))
         (process-lines "sips" "-z" "32" "32" src-fpath "--out" (format "%s/icon32x32.png" dst-fpath))
         (process-lines "sips" "-z" "64" "64" src-fpath "--out" (format "%s/icon32x32@2x.png" dst-fpath))
         (process-lines "sips" "-z" "128" "128" src-fpath "--out" (format "%s/icon128x128.png" dst-fpath))
         (process-lines "sips" "-z" "256" "256" src-fpath "--out" (format "%s/icon128x128@2x.png" dst-fpath))
         (process-lines "sips" "-z" "256" "256" src-fpath "--out" (format "%s/icon256x256.png" dst-fpath))
         (process-lines "sips" "-z" "512" "512" src-fpath "--out" (format "%s/icon256x256@2x.png" dst-fpath))
         (process-lines "sips" "-z" "512" "512" src-fpath "--out" (format "%s/icon512x512.png" dst-fpath))
         (process-lines "sips" "-z" "1024" "1024" src-fpath "--out" (format "%s/icon_512x512@2x.png" dst-fpath))
         (process-lines "iconutil" "-c" "icns" dst-fpath)
         (message "Created %s and %s.icns" (file-name-nondirectory dst-fpath) (file-name-nondirectory src-fpath))))
     (dired-map-over-marks (dired-get-filename) arg)))

  ;; Predownloaded to ~/.emacs.d/downloads
  (use-package tmtxt-dired-async
    :config
    (use-package tmtxt-async-tasks)
    (dired-async-mode +1))

  (use-package dired-atool
    :ensure t
    :ensure-system-package atool
    :validate-custom
    (dired-atool-unpack-no-confirm t)
    :bind (:map dired-mode-map
                ("z" . dired-atool-do-unpack-to-current-dir)
                ("Z" . dired-atool-do-pack)))

  (use-package dired-git-info
    :ensure t
    :bind (:map dired-mode-map
                (")" . dired-git-info-mode)))

  ;; Colourful entries.
  (use-package diredfl
    :ensure t
    :config
    (diredfl-global-mode 1))

  (defun ar/file-find-parent-dir ()
    "Open parent dir."
    (interactive)
    (find-file ".."))

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

  (use-package dired-filter
    :ensure t
    :hook (dired-mode . dired-filter-mode)
    :bind (:map dired-filter-map
                ("v" . dired-filter-by-videos))
    :config
    (dired-filter-define videos
        "Toggle current view to video files."
      (:description "videos")
      (string-match-p "\\.\\(mp4\\|264\\|dav\\|exo\\|h264\\|n3r\\|wve\\|tscproj\\|swf\\|avc\\|ts\\|hkv\\|g64x\\|avi\\|vproj\\|mepx\\|dvr\\|vob\\|bup\\|mkv\\|trec\\|encm\\|v264\\|webm\\|rec\\|pz\\|kux\\|dv4\\|bu\\|yify\\|arf\\|ifv\\|nfv\\|pds\\|dv5\\|h260\\|mov\\|lrv\\|dash\\|es3\\|flv\\|etrg\\|wlmp\\|fbr\\|ezp\\|dvt\\|prproj\\|tvs\\|vcr\\|m4s\\|strg\\|gifv\\|rf\\|trp\\|bvr\\|hbox\\|dxa\\|um4\\|veg\\|dcf\\|dc8\\|mk3d\\|dat\\|wmv\\|vvf\\|bik\\|dxr\\|lrec\\|mks\\|vpj\\|vep\\|vse\\|mts\\|mp41\\|dfxp\\|mxf\\|m2t\\|m4f\\|usm\\|bnk\\|h265\\|demo\\|mpg\\|dir\\|3gp\\|dtcp-ip\\|stx\\|vcd\\|vp6\\|sdr2\\|vgz\\|viv\\|mod\\|xvid\\|avh\\|hevc\\|ogv\\|vf\\|evo\\|dce\\|m4v\\|doink-gs\\|asf\\|rdt\\|vghd\\|cine\\|eti\\|moff\\|sol\\|mjpeg\\|vfo\\|3gp_128x96\\|ssif\\|m2p\\|ub1\\|ravi\\|irf\\|mts1\\|hmt\\|avf\\|dmx\\|asx\\|camproj\\|nmm\\|ismv\\|tp\\|nvc\\|vro\\|stu\\|tod\\|fcpxml\\|ivf\\|vp3\\|tts\\|xba\\|mjpg\\|3g2\\|sdv\\|hav\\|rec_part0\\|h3r\\|vid\\|amv\\|eztv\\|h64\\|dmsd\\|crec\\|265\\|amc\\|camrec\\|epm\\|hup\\|mtv\\|mps\\|p2\\|djanimations\\|mpg4\\|swi\\|mpeg\\|m2ts\\|rdg\\|flux\\|cct\\|vs4\\|rmvb\\|flm\\|vmlf\\|rt4\\|mj2\\|ts4\\|awlive\\|m65\\|ifv\\|3gpp\\|r3d\\|rm\\|g2m\\|mpv\\|prel\\|otrkey\\|mpgv\\|urc\\|wsve\\|mmv\\|dmsm\\|rpl\\|fsv\\|cpvc\\|jyk\\|rargb\\|mvc\\|ppj\\|dvr-ms\\|mpgx\\|swc\\|f4v\\|avd\\|rv\\|gmm\\|vp9\\|qt\\|w32\\|eye\\|str\\|ml20\\|60d\\|bdav\\|jmf\\|cpk\\|bdmv\\|dscf\\|fm2\\|tsp\\|dvm\\|mxv\\|mp4\\|lsf\\|tmi\\|eva\\|w3d\\|m1v\\|rcproject\\|fmv\\|xvw\\|aut\\|ilm\\|dlx\\|fcp\\|mpeg2\\|dv\\|swz\\|ty\\|mv\\|mpcpl\\|m2v\\|dtv\\|rax\\|g64\\|iva\\|epj\\|rec_part1\\|vcl\\|san\\|rtv\\|pgmx\\|vpg\\|m2s\\|xpv\\|ivm\\|movie\\|pxm\\|flexolibrary\\|divx\\|seq\\|ogm\\|mvd\\|mvy\\|slc\\|theater\\|mpeg4\\|cvc\\|y4m\\|kmv\\|rca\\|hlv\\|wtv\\|44\\|dmss\\|mjp\\|rvl\\|h263\\|ssm\\|lsproj\\|htd\\|gir\\|mv4\\|603\\|tms\\|vp8\\|mkv3D\\|hgd\\|s4ud\\|flc\\|vdr\\|cx3\\|hmv\\|vg2\\|hq\\|m-jpeg\\|gts\\|iis\\|mcv\\|mv2\\|tgv\\|nde\\|st4\\|bdtp\\|dvx\\|ratDVD\\|stj\\|wmv3\\|890\\|tp0\\|mpegps\\|film\\|pmf\\|mqv\\|smv\\|fli\\|vep4\\|nxv\\|scc\\|k3g\\|vs2\\|3mm\\|263\\|jmm\\|apz\\|s11\\|gvi\\|mbv\\|mjp\\|xmv\\|lsx\\|dvddata\\|ev2\\|fvt\\|$ts\\|dof\\|svcd\\|dgw\\|pyv\\|tvv\\|aqt\\|bsf\\|rcrec\\|bbv\\|xtodvd\\|gxf\\|mvv\\|vod\\|ivs\\|sqz\\|mjp2\\|l32\\|dsm\\|flh\\|ncor\\|imovietrailer\\|s2e\\|mio\\|261\\|m1s\\|flvat\\|800\\|l3\\|rtsp\\|splash\\|vid\\|imovieproj\\|jpv\\|am2\\|hnm\\|uvs\\|tivo\\|rec_part2\\|mgv\\|vg\\|vivo\\|vc1\\|vcm\\|dvdrip\\|dcr\\|demo4\\|fli_\\|qtc\\|qtm\\|wfsp\\|mpeg1\\|sbst\\|dcr\\|dwz\\|pxv\\|3gpp2\\|sbs\\|am7\\|zeg\\|ssw\\|wm3\\|rki\\|bub\\|pmp\\|h4v\\|axm\\|scm\\|bay\\|rec_part3\\|video\\|kava\\|roq\\|tridefmovie\\|htp\\|mep\\|hls\\|xas\\|lza\\|rvx\\|viewlet\\|svi\\|moov\\|nvl\\|tdt2\\|mvf\\|mpe\\|noa\\|3gp2\\|wm\\|ogx\\|4xm\\|moo\\|olproj\\|rum\\|c2r\\|flm\\|clk\\|vcpf\\|mpg2\\|qmx\\|crv\\|xmm\\|xlmv\\|hdmov\\|mp4v\\|arcut\\|nvavi\\|el8\\|d2v\\|buy\\|dvsd\\|mcf\\|bs4\\|siv\\|mvr\\|px\\|mhg\\|stk\\|ipr\\|tv\\|qvt\\|ml20\\|mmp\\|aec\\|mp7\\|qcif\\|vprj\\|jts\\|m21\\|vpd\\|biz\\|ppp\\|vp7\\|scn\\|vgx\\|vcv\\|dpg\\|pvr\\|mpj\\|osp\\|tab\\|dfv\\|mp2v\\|cak\\|vp5\\|ftvx\\|daproj\\|3ivx\\|pproj\\|avb\\|h261\\|zrb\\|dv-avi\\|cam\\|par\\|tvs\\|wpe\\|drc\\|grasp\\|dvdmedia\\|mnv\\|gfp\\|avr\\|asdvdcrtproj\\|hkm\\|orv\\|qtvr\\|cmmp\\|gdwx\\|ivr\\|mv1\\|ctd\\)$" file-name)))

  (use-package openwith
    :ensure t
    :validate-custom
    (openwith-associations
     (cond
      ((string-equal system-type "darwin")
       '(("\\.\\(dmg\\|doc\\|docs\\|xls\\|xlsx\\)$"
          "open" (file))
         ("\\.\\(aiff\\|wav\\|mp4\\|mp3\\|mkv\\|webm\\|avi\\|flv\\|mov\\)$"
          "open" ("-a" "mpv" "--args" "--geometry=<oww>+<owx>+<owy>" file))))
      ((string-equal system-type "gnu/linux")
       '(("\\.\\(mp4\\|mp3\\|mkv\\|webm\\|avi\\|flv\\|mov\\)$"
          "xdg-open" (file))))))
    :config
    (defun adviced:openwith-file-handler (orig-fun &rest r)
      "Same as `openwith-file-handler' but replace <oww> <owh> <owx> and
 <owy> with frame width height x y coordinates in params."
      (let* ((args (cdr r))
             (assocs openwith-associations)
             (operation (nth 0 r))
             (file (nth 1 r))
             (assoc (seq-find (lambda (candidate)
                                (string-match (car candidate) file))
                              assocs))
             (app (nth 1 assoc))
             (params (mapcar
                      (lambda (x)
                        (cond
                         ((eq x 'file)
                          file)
                         ((or (string-match-p "<oww>" x)
                              (string-match-p "<owh>" x)
                              (string-match-p "<owx>" x)
                              (string-match-p "<owy>" x))
                          ;; Geometry values tweaked for macOS.
                          (replace-regexp-in-string
                           "<oww>" (format "%d" (frame-pixel-width))
                           (replace-regexp-in-string
                            "<owh>" (format "%d" (+ (frame-pixel-height) 20))
                            (replace-regexp-in-string
                             "<owx>" (format "%d" (car (frame-position)))
                             (replace-regexp-in-string
                              "<owy>" (format "%d" (- (- (x-display-pixel-height)
                                                         (+ (cdr (frame-position)) (frame-pixel-height)))
                                                      20))
                              x)))))
                         (t
                          x)))
                      (nth 2 assoc))))
        (if app
            (progn
              (if (eq system-type 'windows-nt)
	          (openwith-open-windows file)
	        (openwith-open-unix app params))
              (kill-buffer nil)
              (when (featurep 'recentf)
                (recentf-add-file file)))
          (let ((inhibit-file-name-handlers
                 (cons 'openwith-file-handler
                       (and (eq inhibit-file-name-operation operation)
                            inhibit-file-name-handlers)))
                (inhibit-file-name-operation operation))
            (apply operation args)))))
    (advice-add #'openwith-file-handler
                :around
                #'adviced:openwith-file-handler)
    (openwith-mode +1)))

(use-package tramp
  :defer
  :config
  (use-package tramp-sh
    :validate-custom
    ;; Favor .ssh/config instead.
    (tramp-use-ssh-controlmaster-options nil))
  ;; Use remote PATH on tramp (handy for eshell).
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  ;; make sure vc stuff is not making tramp slower
  (setq vc-ignore-dir-regexp
	(format "%s\\|%s"
		vc-ignore-dir-regexp
		tramp-file-name-regexp)))
