;;; init-vc.el --- Version control helpers -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package magit
  :defer t)

(use-package git-commit
  :straight nil
  :ensure nil
  :after magit
  :bind (:map git-commit-mode-map
              ("C-c C-d" . my-git-commit-insert-staged-diff))
  :config
  (declare-function magit-git-string "magit-git" (&rest args))

  (defun my-git-commit-insert-staged-diff (&optional full)
    "Insert commented staged diff to help Copilot suggest messages.
With prefix argument FULL, insert the full patch instead of a summary."
    (interactive "P")
    (let* ((args (if full
                     '("diff" "--cached")
                   '("diff" "--cached" "--stat" "--shortstat")))
           (diff (apply #'magit-git-string args))
           (prefix (or comment-start "# ")))
      (if (and diff (string-match-p "\\S-" diff))
          (save-excursion
            (goto-char (point-max))
            (unless (bolp)
              (insert "\n"))
            (insert prefix "Copilot context: staged diff\n")
            (dolist (line (split-string diff "\n"))
              (insert prefix line "\n")))
        (message "No staged changes to insert.")))))

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
