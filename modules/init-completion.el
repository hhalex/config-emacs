;;; init-completion.el --- Completion and minibuffer -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package which-key
  :defer 1
  :config
  (which-key-mode))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :after vertico
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil))

(use-package consult
  :after vertico)

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package eldoc
  :ensure nil
  :hook ((prog-mode . eldoc-mode)
         (eglot-managed-mode . eldoc-mode))
  :custom
  (eldoc-echo-area-use-multiline-p t)
  (eldoc-idle-delay 0.2)
  (eldoc-documentation-strategy #'eldoc-documentation-compose))

(setq read-extended-command-predicate #'command-completion-default-include-p)

(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-quit-no-match 'separator)
  (corfu-preview-current nil)
  (corfu-echo-documentation t)
  (corfu-scroll-margin 4))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :init
  (dolist (backend '(cape-file cape-keyword cape-dict))
    (add-hook 'completion-at-point-functions backend 'append)))

(provide 'init-completion)
;;; init-completion.el ends here
