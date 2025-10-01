;;; init.el --- Entry point -*- lexical-binding: t -*-

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t
      use-package-always-ensure t)

(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))

(dolist (module '(init-core
                  init-ui
                  init-completion
                  init-editor
                  init-languages
                  init-lsp
                  init-projects
                  init-vc
                  init-copilot
                  init-modal))
  (require module))

(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))

(provide 'init)
;;; init.el ends here
