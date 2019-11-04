;;; -*- lexical-binding: t; -*-
(use-package bazel-mode
  :commands ar/bazel-find-staged
  :mode (("\\.bzl\\'" . bazel-mode)
         ("BUILD\\'" . bazel-mode))
  :hook (bazel-mode . ar/bazel-mode-hook-fun)
  :init
  (defun ar/bazel-mode-hook-fun ()
    (ar/buffer-run-for-saved-file-name "buildifier" "BUILD")
    (setq-local company-backends '(company-bazel company-rfiles)))
  :config
  (use-package ar-bazel)
  (use-package company-bazel)
  (use-package ar-counsel-find)

  (defun ar/bazel-find-staged ()
    "Call the \"find\" shell command and fuzzy narrow using ivy."
    (interactive)
    (ar/counsel-find--in-paths (list (ar/bazel-bin-dir)
                                     (ar/bazel-genfiles-dir)
                                     (ar/bazel-out-dir))))

  (map-put compilation-error-regexp-alist-alist
           ;; Knowing which rule is associated with a compilation error isn't very useful.
           'bazel-originating-rule-error (list "^ERROR: \\(/.*/BUILD\\):\\([0-9]+\\):\\([0-9]+\\)\\(compilation\\)?" 1 2 3 0))
  (add-to-list 'compilation-error-regexp-alist 'bazel-originating-rule-error)

  (map-put compilation-error-regexp-alist-alist
           'bazel-warning (list "^WARNING: \\(.*/BUILD\\):\\([0-9]+\\):\\([0-9]+\\):" 1 2 3 1))
  (add-to-list 'compilation-error-regexp-alist 'bazel-warning))
