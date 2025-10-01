;;; init-lsp.el --- Eglot and formatting -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package eglot
  :hook ((prog-mode . eglot-ensure)
         (noir-ts-mode . eglot-ensure))
  :config
  (add-hook 'before-save-hook
            (lambda ()
              (when (derived-mode-p 'rust-mode 'rust-ts-mode)
                (eglot-format-buffer))))

  (defun my/rust-eglot-init-options ()
    '(:rust-analyzer (:cargo (:allFeatures t)
                             :checkOnSave (:command "clippy"))))

  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (when (derived-mode-p 'rust-mode 'rust-ts-mode)
                (setq-local eglot-workspace-configuration
                            (my/rust-eglot-init-options))))))

(with-eval-after-load 'eglot
  (dolist (entry '((typescript-ts-mode . ("typescript-language-server" "--stdio"))
                   (tsx-ts-mode        . ("typescript-language-server" "--stdio"))
                   (js-ts-mode         . ("typescript-language-server" "--stdio"))
                   (json-ts-mode       . ("vscode-json-language-server" "--stdio"))
                   (css-ts-mode        . ("vscode-css-language-server" "--stdio"))
                   (html-ts-mode       . ("vscode-html-language-server" "--stdio"))
                   (noir-ts-mode       . ("nargo" "lsp"))))
    ;; Ensure Eglot knows which language servers to spawn for tree-sitter modes.
    (add-to-list 'eglot-server-programs entry)))

(defun my/eglot-ts-init-options ()
  '(:typescript
    (:inlayHints
     (:includeInlayParameterNameHints "all"
                                      :includeInlayFunctionParameterTypeHints t
                                      :includeInlayVariableTypeHints t
                                      :includeInlayPropertyDeclarationTypeHints t
                                      :includeInlayFunctionLikeReturnTypeHints t
                                      :includeInlayEnumMemberValueHints t)
     :preferences
     (:includeCompletionsForModuleExports t
                                         :includeCompletionsForImportStatements t
                                         :includeCompletionsWithSnippetText t
                                         :includeAutomaticOptionalChainCompletions t
                                         :autoImportFileExcludePatterns ["**/node_modules/**"]
                                         :quotePreference "auto"
                                         :preferGoToSource t))))

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (when (derived-mode-p 'typescript-ts-mode 'tsx-ts-mode 'js-ts-mode)
              (setq-local eglot-workspace-configuration (my/eglot-ts-init-options)))))

(defun my/ts-organize-imports ()
  (interactive)
  (eglot-code-actions nil nil "source.organizeImports.ts"))

(defun my/ts-fix-all ()
  (interactive)
  (eglot-code-actions nil nil "source.fixAll.ts"))

(global-set-key (kbd "C-c o") #'my/ts-organize-imports)
(global-set-key (kbd "C-c x") #'my/ts-fix-all)

(use-package consult-eglot)

(use-package apheleia
  :after eglot
  :init
  (apheleia-global-mode +1)
  :config
  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (dolist (mode '(typescript-ts-mode tsx-ts-mode js-ts-mode json-ts-mode css-ts-mode html-ts-mode))
    (add-to-list 'apheleia-mode-alist (cons mode 'prettier)))
  (setq apheleia-remote-algorithm 'local))

(use-package eslintd-fix
  :hook ((typescript-ts-mode tsx-ts-mode js-ts-mode) . eslintd-fix-mode))

(use-package flymake
  :ensure nil
  :hook ((eglot-managed-mode . flymake-mode))
  :custom
  (flymake-no-changes-timeout 0.2)
  (flymake-start-on-save-buffer t)
  (flymake-start-on-flymake-mode t)
  :config
  (add-hook 'flymake-mode-hook
            (lambda ()
              (setq-local help-at-pt-display-when-idle t)
              (help-at-pt-set-timer))))

(setq flymake-fringe-indicator-position nil)

(with-eval-after-load 'modus-themes
  (modus-themes-with-colors
    (custom-set-faces
     `(flymake-error   ((t (:underline (:style wave :color ,red)   :background ,bg-main))))
     `(flymake-warning ((t (:underline (:style wave :color ,yellow) :background ,bg-main))))
     `(flymake-note    ((t (:underline (:style wave :color ,cyan)  :background ,bg-main)))))))

(provide 'init-lsp)
;;; init-lsp.el ends here
