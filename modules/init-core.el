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
(add-to-list 'exec-path (expand-file-name "~/.local/bin"))

(setq-default inhibit-startup-screen t)

(delete-selection-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(windmove-default-keybindings)

(savehist-mode 1)
(recentf-mode 1)

(use-package better-jumper
  :config
  (setq better-jumper-context 'window
        better-jumper-use-evil-jump-advice t
        better-jumper-add-jump-behavior 'replace)
  (setq better-jumper-disabled-modes
        (delq 'magit-mode better-jumper-disabled-modes))
  (better-jumper-mode 1)
  (defun my/better-jumper-set-jump (&rest _)
    "Record a jump point for cross-buffer navigation."
    (better-jumper-set-jump))
  (dolist (fn '(xref-find-definitions
                xref-find-references
                xref-go-back
                xref-go-forward
                magit-status
                consult-line
                consult-ripgrep
                consult-grep
                consult-imenu
                consult-goto-line
                consult-buffer
                avy-goto-char
                avy-goto-char-2
                avy-goto-word-1
                avy-goto-line
                beginning-of-buffer
                end-of-buffer
                beginning-of-defun
                end-of-defun
                forward-paragraph
                backward-paragraph
                outline-next-visible-heading
                outline-previous-visible-heading
                next-error
                previous-error
                imenu
                recenter-top-bottom
                mouse-set-point
                mouse-set-region
                mouse-drag-region
                switch-to-buffer
                other-window))
    (when (fboundp fn)
      (advice-add fn :before #'my/better-jumper-set-jump)))
  (add-hook 'isearch-mode-hook #'better-jumper-set-jump)
  (dolist (fn '(meow-search
                meow-visit
                meow-imenu
                meow-insert
                meow-append
                meow-yank
                meow-clipboard-yank
                meow-pop-selection))
    (when (fboundp fn)
      (advice-add fn :before #'my/better-jumper-set-jump))))

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
