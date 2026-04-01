;;; init-packages.el --- straight.el helpers -*- lexical-binding: t -*-

(defconst my/package-versions-file
  (expand-file-name "package-versions.el" user-emacs-directory)
  "Repo-local straight.el lockfile.")

(defun my/freeze-package-versions (&optional force)
  "Write current straight.el revisions to `package-versions.el'.
With prefix argument FORCE, skip straight.el safety checks."
  (interactive "P")
  (straight-freeze-versions force)
  (message "Wrote package versions to %s" my/package-versions-file))

(defun my/thaw-package-versions ()
  "Restore package revisions from `package-versions.el'."
  (interactive)
  (straight-thaw-versions)
  (message "Restored package versions from %s" my/package-versions-file))

(defun my/update-packages (&optional force)
  "Fetch, rebuild, and freeze straight.el packages.
With prefix argument FORCE, skip straight.el safety checks while freezing."
  (interactive "P")
  (straight-pull-all)
  (straight-check-all)
  (straight-rebuild-all)
  (my/freeze-package-versions force)
  (message "Updated packages and refreshed %s" my/package-versions-file))

(provide 'init-packages)
;;; init-packages.el ends here
