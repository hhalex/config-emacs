;;; init-copilot.el --- GitHub Copilot integration -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :hook ((prog-mode . copilot-mode)
         (git-commit-mode . copilot-mode))
  :config
  (define-key copilot-completion-map (kbd "<backtab>") #'copilot-accept-completion-by-word)
  (dolist (k '("TAB" "<tab>"))
    (define-key copilot-completion-map (kbd k) #'copilot-accept-completion))
  (add-hook 'minibuffer-setup-hook (lambda () (copilot-mode -1)))
  (add-to-list 'copilot-indentation-alist '(rust-mode 4))
  (add-to-list 'copilot-indentation-alist '(rust-ts-mode 4))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
  (add-to-list 'copilot-indentation-alist '(lisp-mode 2)))

(provide 'init-copilot)
;;; init-copilot.el ends here
