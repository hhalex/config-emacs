;;; init-lsp.el --- Eglot and formatting -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package eglot
  :hook ((prog-mode . eglot-ensure)
         (noir-ts-mode . eglot-ensure)
         ;; helm-template-mode derives from text-mode, so it misses the
         ;; prog-mode hook; only attach when the helm_ls binary is present.
         (helm-template-mode . (lambda ()
                                 (when (executable-find "helm_ls")
                                   (eglot-ensure)))))
  :custom
  (eglot-code-action-indications nil)
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
  (require 'subr-x)
  (require 'cl-lib)
  (dolist (entry '((typescript-ts-mode . ("typescript-language-server" "--stdio"))
                   (tsx-ts-mode        . ("typescript-language-server" "--stdio"))
                   (js-ts-mode         . ("typescript-language-server" "--stdio"))
                   (json-ts-mode       . ("vscode-json-language-server" "--stdio"))
                   (css-ts-mode        . ("vscode-css-language-server" "--stdio"))
                   (html-ts-mode       . ("vscode-html-language-server" "--stdio"))
                   (noir-ts-mode       . ("nargo" "lsp"))
                   (terraform-mode     . ("terraform-ls" "serve"))
                   (hcl-mode           . ("terraform-ls" "serve"))
                   (helm-template-mode . ("helm_ls" "serve"))))
    ;; Ensure Eglot knows which language servers to spawn for our modes.
    (add-to-list 'eglot-server-programs entry))

  ;; `dockerfile-mode' derives from `prog-mode', so the global
  ;; `eglot-ensure' hook fires for Dockerfiles and tries to launch the
  ;; built-in `docker-langserver' mapping, which we don't install. Drop
  ;; that mapping so editing Dockerfiles stays LSP-free and quiet.
  (setq eglot-server-programs
        (seq-remove (lambda (entry)
                      (let ((modes (car entry)))
                        (if (listp modes)
                            (memq 'dockerfile-mode modes)
                          (eq modes 'dockerfile-mode))))
                    eglot-server-programs))

  (defun my/eglot--import-action-title-p (title)
    "Return non-nil when TITLE appears to be an import-related code action."
    (and title
         (let ((case-fold-search t))
           (string-match-p (rx (or string-start (not letter))
                               (group-n 1 "import")
                               (or string-end (not letter)))
                           title))))

  (defun my/eglot--decorate-action-title (title)
    "Return a display string for TITLE, highlighting imports in yellow."
    (let ((copy (copy-sequence (or title ""))))
      (if (my/eglot--import-action-title-p copy)
          (propertize copy 'face '(:inherit warning :weight semi-bold))
        copy)))

  (defun my/eglot--arrange-code-actions (actions)
    "Return menu items prioritizing import ACTIONS with decorated titles."
    (let (imports others)
      (dolist (action actions)
        (let* ((title (plist-get action :title))
               (display (my/eglot--decorate-action-title title))
               (cell (cons display action)))
          (if (my/eglot--import-action-title-p title)
              (push cell imports)
            (push cell others))))
      (append (nreverse imports) (nreverse others))))

  (defun my/eglot--read-execute-code-action (_orig actions server &optional action-kind)
    "Priority wrapper for `eglot--read-execute-code-action' to sort imports.
Applies `warning' face to import actions."
    (let* ((menu-items (or (my/eglot--arrange-code-actions actions)
                           (apply #'eglot--error
                                  (if action-kind
                                      `("No \"%s\" code actions here" ,action-kind)
                                    '("No code actions here")))))
           (preferred-action (cl-find-if
                              (lambda (menu-item)
                                (plist-get (cdr menu-item) :isPreferred))
                              menu-items))
           (default-action (car (or preferred-action (car menu-items))))
           (chosen
           (if (and action-kind (null (cadr menu-items)))
               (cdr (car menu-items))
             (if (listp last-nonmenu-event)
                  (x-popup-menu
                   last-nonmenu-event
                   `("Eglot code actions:"
                     ("dummy" ,@menu-items)))
                (cdr (assoc (completing-read
                             (format "[eglot] Pick an action (default %s): "
                                     (substring-no-properties default-action))
                             menu-items nil t nil nil default-action)
                            menu-items))))))
      (when chosen
        (eglot-execute server chosen))))

  (advice-add 'eglot--read-execute-code-action :around #'my/eglot--read-execute-code-action)

  (defun my/eglot--highlight-types (doc)
    "Apply type-oriented faces to DOC without altering its text content."
    (when (and doc (not (string-empty-p doc)))
      (let ((text (copy-sequence doc))
            (case-fold-search nil)
            (pos 0))
        ;; Highlight types appearing after colon.
        (while (string-match
                "\\(?:\\sw\\|[]})>]\\)\\s-*:\\s-*\\([^,)\n;]+\\)" text pos)
          (add-face-text-property (match-beginning 1) (match-end 1)
                                  'font-lock-type-face t text)
          (setq pos (match-end 1)))
        ;; Highlight return types after arrows like \"=>\" or \"->\".
        (setq pos 0)
        (while (string-match
                "\\(?:=>\\|->\\)\\s-*\\([^,)\n;]+\\)" text pos)
          (add-face-text-property (match-beginning 1) (match-end 1)
                                  'font-lock-type-face t text)
          (setq pos (match-end 1)))
        ;; Emphasize common primitive names wherever they occur.
        (dolist (word '("string" "number" "boolean" "void" "null" "undefined"
                        "any" "never" "unknown" "Promise" "Result" "Option"))
          (setq pos 0)
          (while (string-match (concat "\\_<" word "\\_>") text pos)
            (add-face-text-property (match-beginning 0) (match-end 0)
                                    'font-lock-type-face t text)
            (setq pos (match-end 0))))
        text)))

  (advice-add 'eglot--hover-info :filter-return #'my/eglot--highlight-types)
  (advice-add 'eglot--sig-info :filter-return #'my/eglot--highlight-types))

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
  (setf (alist-get 'terraformfmt apheleia-formatters)
        '("terraform" "fmt" "-"))
  (add-to-list 'apheleia-mode-alist '(terraform-mode . terraformfmt))
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
