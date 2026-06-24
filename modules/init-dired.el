;;; init-dired.el --- Dired defaults -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package dired
  :straight nil
  :ensure nil
  :config
  ;; Friendlier listings. --group-directories-first is GNU coreutils only;
  ;; macOS ships BSD ls, which rejects it and makes dired fail to list any
  ;; directory. Prefer GNU `gls' if installed; otherwise fall back to Emacs'
  ;; built-in ls-lisp emulation, which groups directories first on its own.
  (setq dired-listing-switches "-alh --group-directories-first"
        dired-recursive-copies 'always
        dired-recursive-deletes 'top
        dired-kill-when-opening-new-dired-buffer t)
  (when (eq system-type 'darwin)
    (let ((gls (executable-find "gls")))
      (if gls
          (setq insert-directory-program gls)
        (require 'ls-lisp)
        (setq ls-lisp-use-insert-directory-program nil
              ls-lisp-dirs-first t
              dired-listing-switches "-alh"))))
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'auto-revert-mode))

(use-package dired-narrow
  :after dired
  :bind (:map dired-mode-map
              ("/" . dired-narrow)))

(use-package nerd-icons-dired
  :after dired
  :hook (dired-mode . nerd-icons-dired-mode))

(provide 'init-dired)
;;; init-dired.el ends here
