;;; init-dired.el --- Dired defaults -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package dired
  :straight nil
  :ensure nil
  :config
  ;; Friendlier listings (GNU ls assumed on Linux; on macOS you may need coreutils/gls).
  (setq dired-listing-switches "-alh --group-directories-first"
        dired-recursive-copies 'always
        dired-recursive-deletes 'top
        dired-kill-when-opening-new-dired-buffer t)
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
