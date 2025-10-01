;;; init-core.el --- Core defaults -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(defun my-keyboard-quit-context+ ()
  "Quit the current context. Abort the minibuffer if active."
  (interactive)
  (if (minibufferp (current-buffer))
      (abort-recursive-edit)
    (when (active-minibuffer-window)
      (abort-recursive-edit))
    (keyboard-quit)))

(global-set-key [remap keyboard-quit] #'my-keyboard-quit-context+)

(use-package exec-path-from-shell
  :if (or (memq window-system '(mac ns x pgtk)) (daemonp))
  :custom
  (exec-path-from-shell-variables '("PATH" "MANPATH" "CARGO_HOME" "RUSTUP_HOME"))
  :config
  (exec-path-from-shell-initialize))

(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

(setq-default inhibit-startup-screen t)

(delete-selection-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(windmove-default-keybindings)

(savehist-mode 1)
(recentf-mode 1)

(dolist (dir '("~/.emacs.d/whatever-tmp/" "~/.emacs.d/tmp/backups/"))
  (make-directory (expand-file-name dir) t))

(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" "~/.emacs.d/whatever-tmp/" t))
      lock-file-name-transforms `((".*" "~/.emacs.d/whatever-tmp/" t))
      recentf-max-saved-items 300
      recentf-auto-cleanup 'never
      recentf-exclude '("^/tmp/" "/ssh:" "/sudo:" "\\.gz\\'"))

(provide 'init-core)
;;; init-core.el ends here
