;;; early-init.el --- Early startup tweaks -*- lexical-binding: t -*-

(setq package-enable-at-startup nil
      inhibit-startup-message t
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 128 1024 1024)
                  gc-cons-percentage 0.1
                  file-name-handler-alist my/file-name-handler-alist)))

(when (featurep 'native-compile)
  (setq native-comp-deferred-compilation t
        native-comp-async-report-warnings-errors 'silent))

(provide 'early-init)
;;; early-init.el ends here
