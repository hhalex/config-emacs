;;; init-vc.el --- Version control helpers -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package magit
  :defer t)

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode)
  (fringe-mode '(4 . 0))
  (setq diff-hl-draw-borders nil
        diff-hl-fringe-bmp-function 'diff-hl-fringe-bmp-from-type))

(with-eval-after-load 'modus-themes
  (defun my-diff-hl-modus-pastel ()
    (modus-themes-with-colors
      (let ((added green-faint)
            (changed yellow-faint)
            (removed red-faint))
        (custom-set-faces
         `(diff-hl-change ((t (:background ,changed :foreground ,changed))))
         `(diff-hl-insert ((t (:background ,added :foreground ,added))))
         `(diff-hl-delete ((t (:background ,removed :foreground ,removed))))
         `(diff-hl-margin-change ((t (:background ,changed :foreground ,changed))))
         `(diff-hl-margin-insert ((t (:background ,added :foreground ,added))))
         `(diff-hl-margin-delete ((t (:background ,removed :foreground ,removed))))))))
  (my-diff-hl-modus-pastel)
  (when (boundp 'enable-theme-functions)
    (add-hook 'enable-theme-functions
              (lambda (_theme) (my-diff-hl-modus-pastel)))))

(provide 'init-vc)
;;; init-vc.el ends here
