;;; init-copilot.el --- GitHub Copilot integration -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(defun my/copilot-safe-mode ()
  "Enable `copilot-mode', tolerating a missing/unstartable language server.
Without this guard a missing `copilot-language-server' aborts major-mode
setup for every `prog-mode' buffer."
  (condition-case err
      (copilot-mode 1)
    (error
     (copilot-mode -1)
     (message "Copilot disabled: %s" (error-message-string err)))))

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :hook ((prog-mode . my/copilot-safe-mode)
         (git-commit-mode . my/copilot-safe-mode))
  :config
  (define-key copilot-completion-map (kbd "<backtab>") #'copilot-accept-completion-by-word)
  (dolist (k '("TAB" "<tab>"))
    (define-key copilot-completion-map (kbd k) #'copilot-accept-completion))
  (add-hook 'minibuffer-setup-hook (lambda () (copilot-mode -1)))
  (add-to-list 'copilot-indentation-alist '(rust-mode 4))
  (add-to-list 'copilot-indentation-alist '(rust-ts-mode 4))
  ;; The magit commit buffer's major-mode is `text-mode' (git-commit-mode is
  ;; only a minor mode), so key the indentation off text-mode to avoid
  ;; `copilot--infer-indentation-offset' warnings there.
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
  (add-to-list 'copilot-indentation-alist '(lisp-mode 2)))

(provide 'init-copilot)
;;; init-copilot.el ends here
