;;; =========================
;;; early-init.el
;;; =========================

;; Ne pas charger package.el trop tôt
(setq package-enable-at-startup nil
      inhibit-startup-message t
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Accélère le démarrage en gelant les handlers de fichiers
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restaure des valeurs raisonnables après le boot
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 128 1024 1024)
                  gc-cons-percentage 0.1
                  file-name-handler-alist my/file-name-handler-alist)))

;; Native-comp (Emacs 28+)
(when (featurep 'native-compile)
  (setq native-comp-deferred-compilation t
        native-comp-async-report-warnings-errors 'silent))


;; Annule l'action courante, avec minibuffer actif ou non

(defun my-keyboard-quit-context+ ()
  "Quit. If minibuffer is active, exit it too."
  (interactive)
  (if (minibufferp (current-buffer))
      (abort-recursive-edit)
    (when (active-minibuffer-window)
      (abort-recursive-edit))
    (keyboard-quit)))

(global-set-key [remap keyboard-quit] #'my-keyboard-quit-context+)

;;; =========================
;;; init.el
;;; =========================

;; Bootstrap straight ----------------------------------------------------------
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t
      use-package-always-ensure t)

;; Chemins shell utiles (GUI/mac/daemon)
(use-package exec-path-from-shell
  :if (or (memq window-system '(mac ns x pgtk)) (daemonp))
  :custom
  (exec-path-from-shell-variables '("PATH" "MANPATH" "CARGO_HOME" "RUSTUP_HOME"))
  :config
  (exec-path-from-shell-initialize))

(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

;; Appearance ---------------------------------------------------------------
(menu-bar-mode -1) (tool-bar-mode -1) (scroll-bar-mode -1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(column-number-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(setq-default inhibit-startup-screen t
              cursor-type 'bar
              frame-resize-pixelwise t)

(delete-selection-mode t)

;; Modus: variables avant le thème
(setq modus-themes-italic-constructs t
      modus-themes-bold-constructs t)
(load-theme 'modus-vivendi-tinted t)

;; Modules perso
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
(require 'prot-common)
(require 'prot-modeline)
(require 'use-modeline)
(require 'use-emacs-theme)

;; Ligatures
(use-package ligature
  :config
  (ligature-set-ligatures
   'prog-mode
   '("<---" "<--"  "<<-" "<-" "->" "-->" "--->" "<->" "<-->" "<--->" "<---->" "<!--"
     "<==" "<===" "<=" "=>" "=>>" "==>" "===>" ">=" "<=>" "<==>" "<===>" "<====>" "<!---"
     "<~~" "<~" "~>" "~~>" "::" ":::" "==" "!=" "===" "!=="
     ":=" ":-" ":+" "<*" "<*>" "*>" "<|" "<|>" "|>" "+:" "-:" "=:" "<******>" "++" "+++"))
  (global-ligature-mode t))

;; Ergonomie / complétion ---------------------------------------------------
(use-package which-key   :defer 1 :config (which-key-mode))
(use-package vertico     :init (vertico-mode))
(use-package orderless
  :after vertico
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil))
(use-package consult     :after vertico)
(use-package marginalia  :after vertico :init (marginalia-mode))

;; Eldoc — docs contextuelles dans l'écho-area (intégré à Eglot)
(use-package eldoc
  :ensure nil                       ;; intégré à Emacs
  :hook ((prog-mode . eldoc-mode)   ;; partout en code
         (eglot-managed-mode . eldoc-mode)) ;; s'assure que c'est ON avec Eglot
  :custom
  (eldoc-echo-area-use-multiline-p t)      ;; autorise plusieurs lignes
  (eldoc-idle-delay 0.2)                   ;; délai avant affichage
  (eldoc-documentation-strategy #'eldoc-documentation-compose)) ;; compose plusieurs sources (Eglot + autres)



;; Confort M-x (filtrage par défaut raisonnable)
(setq read-extended-command-predicate #'command-completion-default-include-p)

;; Interface de complétion
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

;; Icônes avec nerd-icons
(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Ajout de sources de complétion avec CAPE (append pour ne pas écraser LSP)
(use-package cape
  :init
  (dolist (backend '(cape-file cape-keyword cape-dict))
    (add-hook 'completion-at-point-functions backend 'append)))

;; Copilot --------------------------------------------------------------
(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
(add-hook 'prog-mode-hook #'copilot-mode)
(with-eval-after-load 'copilot
  (define-key copilot-completion-map (kbd "<backtab>") #'copilot-accept-completion-by-word)
  (dolist (k '("TAB" "<tab>"))
    (define-key copilot-completion-map (kbd k) #'copilot-accept-completion))
  ;; Désactiver dans le minibuffer
  (add-hook 'minibuffer-setup-hook (lambda () (copilot-mode -1))))
;; Indentation spécifique
(with-eval-after-load 'copilot
  (add-to-list 'copilot-indentation-alist '(rust-mode 4))
  (add-to-list 'copilot-indentation-alist '(rust-ts-mode 4))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
  (add-to-list 'copilot-indentation-alist '(lisp-mode 2)))

;; Édition de code ----------------------------------------------------------
(use-package treesit-auto :config (global-treesit-auto-mode))

;; --- TS/TSX via tree-sitter natif
(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'"  . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))

(defun my/treesit-ensure-react-grammars ()
  "Installe les grammaires TS/TSX/JS/CSS/HTML/JSON si absentes."
  (interactive)
  (dolist (lang '(tsx typescript javascript css html json))
    (unless (treesit-language-available-p lang)
      (ignore-errors (treesit-install-language-grammar lang)))))

(use-package magit        :defer t)



(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode)
  
  ;; Réduit la fringe gauche à 4 pixels, supprime la droite
  (fringe-mode '(4 . 0))

  ;; pas de bordures épaisses
  (setq diff-hl-draw-borders nil)
  (setq diff-hl-fringe-bmp-function 'diff-hl-fringe-bmp-from-type)

  )

;; === Couleurs prises dans la palette Modus ===
(with-eval-after-load 'modus-themes
  (defun my-diff-hl-modus-pastel ()
    (modus-themes-with-colors
      (custom-set-faces
       `(diff-hl-change ((t (:background ,bg-changed :foreground ,bg-changed))))
       `(diff-hl-insert ((t (:background ,bg-added  :foreground ,bg-added))))
       `(diff-hl-delete ((t (:background ,bg-removed :foreground ,bg-removed)))))))

  ;; Applique immédiatement (si le thème est déjà chargé)
  (my-diff-hl-modus-pastel)

  ;; Emacs 29+ : réapplique quand on change de thème
  (when (boundp 'enable-theme-functions)
    (add-hook 'enable-theme-functions
              (lambda (_theme) (my-diff-hl-modus-pastel)))))

(setq flymake-fringe-indicator-position nil)

(with-eval-after-load 'modus-themes
  (modus-themes-with-colors
    (custom-set-faces
     `(flymake-error   ((t (:underline (:style wave :color ,red)   :background ,bg-main))))
     `(flymake-warning ((t (:underline (:style wave :color ,yellow) :background ,bg-main))))
     `(flymake-note    ((t (:underline (:style wave :color ,cyan)  :background ,bg-main)))))))

;; --- Mode Noir (coloration .nr via tree-sitter) ---
(use-package noir-ts-mode
  :mode "\\.nr\\'")   ;; ouvre .nr avec noir-ts-mode

;; Eglot / Rust --------------------------------------------------------------
(use-package eglot
  :hook (
	 (prog-mode . eglot-ensure)
	 (noir-ts-mode . eglot-ensure)
	 )
  :config
  (add-hook 'before-save-hook
            (lambda ()
              (when (derived-mode-p 'rust-mode 'rust-ts-mode)
                (eglot-format-buffer)))))

(with-eval-after-load 'eglot
  (defun my/rust-eglot-init-options ()
    '(:rust-analyzer (:cargo (:allFeatures t)
                             :checkOnSave (:command "clippy"))))
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (when (derived-mode-p 'rust-mode 'rust-ts-mode)
                (setq-local eglot-workspace-configuration
                            (my/rust-eglot-init-options))))))

(with-eval-after-load 'eglot
  ;; Associe explicitement les serveurs
  (add-to-list 'eglot-server-programs '(typescript-ts-mode . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(tsx-ts-mode        . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(js-ts-mode         . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(json-ts-mode       . ("vscode-json-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(css-ts-mode        . ("vscode-css-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs '(html-ts-mode       . ("vscode-html-language-server" "--stdio")))

  (add-to-list 'eglot-server-programs '(noir-ts-mode       . ("nargo" "lsp")))

  ;; Préférences pratiques côté tsserver (completion, import, goto, inlay hints)
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
                (setq-local eglot-workspace-configuration (my/eglot-ts-init-options))))))

;; Raccourcis actions TS utiles
(with-eval-after-load 'eglot
  (defun my/ts-organize-imports () (interactive)
         (eglot-code-actions nil nil "source.organizeImports.ts"))
  (defun my/ts-fix-all () (interactive)
         (eglot-code-actions nil nil "source.fixAll.ts"))
  (global-set-key (kbd "C-c o") #'my/ts-organize-imports)
  (global-set-key (kbd "C-c x") #'my/ts-fix-all))

;; Formatters / Linters ------------------------------------------------------
(use-package apheleia
  :after (eglot)
  :init (apheleia-global-mode +1)
  :config
  ;; Utilise Prettier (prend celui du projet si présent)
  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (dolist (mode '(typescript-ts-mode tsx-ts-mode js-ts-mode json-ts-mode css-ts-mode html-ts-mode))
    (add-to-list 'apheleia-mode-alist (cons mode 'prettier)))
  ;; n'écrase pas les edits Eglot à la volée
  (setq apheleia-remote-algorithm 'local))

;; ESLint fixes à la volée (en plus de Apheleia/Prettier)
(use-package eslintd-fix
  :hook ((typescript-ts-mode tsx-ts-mode js-ts-mode) . eslintd-fix-mode))

;; Compilation buffer avec couleurs ANSI -------------------------------------
(use-package ansi-color
  :config
  (defun my/ansi-colorize-compilation ()
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region compilation-filter-start (point))))
  (add-hook 'compilation-filter-hook #'my/ansi-colorize-compilation))

;; Emmet (HTML/CSS/JSX) ------------------------------------------------------
(use-package emmet-mode
  :hook ((tsx-ts-mode html-ts-mode css-ts-mode) . emmet-mode)
  :custom (emmet-expand-jsx-className? t))

;; TS/JS modes setup ---------------------------------------------------------
(defun my/ts-like-setup ()
  (setq-local tab-width 2)
  (electric-pair-mode 1)
  (subword-mode 1)                     ;; M-f/M-b sur camelCase
  (display-line-numbers-mode 1))
(add-hook 'typescript-ts-mode-hook #'my/ts-like-setup)
(add-hook 'tsx-ts-mode-hook        #'my/ts-like-setup)
(add-hook 'js-ts-mode-hook         #'my/ts-like-setup)

;; Eglot + Consult -----------------------------------------------------------
(use-package consult-eglot)

;; Rust modes ---------------------------------------------------------------
(use-package rust-ts-mode
  :mode "\\.rs\\'"
  :hook ((rust-ts-mode . corfu-mode)))

;; Basculer rust-mode -> rust-ts-mode si la grammaire est dispo
(add-hook 'rust-mode-hook
          (lambda ()
            (when (and (fboundp 'treesit-ready-p)
                       (treesit-ready-p 'rust))
              (rust-ts-mode))))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

;; Yaml
(use-package yaml-ts-mode 
  :mode "\\.ya?ml\\'"
  :hook ((yaml-ts-mode . corfu-mode))
  :config
  (setq yaml-indent-offset 2))

;; which-func en header-line -----------------------------------------------
(use-package which-func
  :hook (
	 (rust-ts-mode . my/enable-which-func-header)
	 (typescript-ts-mode . my/enable-which-func-header)
	 (tsx-ts-mode . my/enable-which-func-header)
         (lisp-mode . my/enable-which-func-header))
  :config
  (setq which-func-unknown "-"
        which-func-modes t
        which-func-format
        '((:propertize which-func-current
                       face which-func
                       local-map ,which-func-keymap)))
  (defun my/enable-which-func-header ()
    (which-function-mode 1)
    (setq-local header-line-format
                '((which-func-mode (" → " which-func-format " ")))))
  (custom-set-faces
   '(header-line
     ((t (:inherit mode-line
                   :background "unspecified-bg"
                   :box (:line-width 1 :color "unspecified-bg")
                   :underline nil :overline nil
                   :weight normal :height 0.95))))))

;; Flymake (pas Flycheck) ----------------------------------------------------
(use-package flymake
  :hook ((eglot-managed-mode . flymake-mode))
  :custom
  (flymake-no-changes-timeout 0.2)
  (flymake-start-on-save-buffer t)
  (flymake-start-on-flymake-mode t)
  :config
  ;; Afficher les erreurs dans le minibuffer
  (add-hook 'flymake-mode-hook
            (lambda ()
              (setq-local help-at-pt-display-when-idle t)
              (help-at-pt-set-timer))))

;; Compilation ---------------------------------------------------------------
(setq compilation-read-command nil)

(defun my/consult-cargo-commands ()
  "Choisir une commande cargo et l'exécuter via `compile`."
  (interactive)
  (let* ((default-directory (or (when-let ((proj (project-current)))
                                  (project-root proj))
                                default-directory))
         (commands '("cargo build" "cargo check" "cargo clippy"
                     "cargo test" "cargo fmt" "cargo run"))
         (command (consult--read
                   commands :prompt "Cargo command: "
                   :sort nil :require-match t
                   :history 'compilation-history)))
    (compile command)))


(defun my/project-switch-to-find-file ()
  "Choisir un projet puis ouvrir directement `project-find-file` dedans."
  (interactive)
  (let ((dir (project-prompt-project-dir)))
    (let ((default-directory dir))
      ;; mémorise le projet, utile pour certaines commandes
      (when-let ((proj (project-current nil dir)))
        (project-remember-project proj))
      (project-find-file))))

;; Project -------------------------------------------------------------------
(use-package project
  :config
  (setq project-search-path '("~/Documents/repos" "~/Documents/hackathon/")
        project-respect-compile-command t
        project-switch-commands
        '((project-find-file "Find file")
          (project-dired "Dired")
          (magit-project-status "Magit" ?m))))

(defun my/consult-flymake-project ()
  "Afficher les erreurs Flymake dans tous les buffers du projet courant."
  (interactive)
  (consult-flymake t))

(defun my-delete-other-windows-and-kill-minibuffer ()
  "Comme `delete-other-windows`, mais tue aussi le minibuffer actif."
  (interactive)
  ;; Si un minibuffer est actif, on l’annule proprement
  (when (active-minibuffer-window)
    (abort-recursive-edit))
  ;; Puis on fait le comportement normal
  (delete-other-windows))


;; Meow (modal editing) ------------------------------------------------------
(use-package meow
  :config
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-leader-define-key
     '("?" . meow-cheatsheet)
     '("f" . find-file)
     '("p p" . my/project-switch-to-find-file)
     '("p f" . project-find-file)
     '("p b" . consult-project-buffer)
     '("b" . switch-to-buffer)
     '("d" . consult-flymake)
     '("D" . my/consult-flymake-project)
     '("s" . consult-eglot-symbols)
     '("k" . kill-buffer)
     '("w" . save-buffer)
     '("." . magit-status)
     '("t" . neotree-toggle)
     '("/" . consult-ripgrep)
     ;; LSP
     '("a" . eglot-code-actions)
     '("r" . eglot-rename)
     '("l f" . eglot-format)
     '("l d" . xref-find-definitions)
     '("," . xref-find-references)
     ;; Compilation / Cargo
     '("' c" . (lambda () (interactive) (compile "cargo build")))
     '("' t" . my/rust-run-test-at-point)
     '("' T" . (lambda () (interactive) (compile "cargo test")))
     '("' R" . (lambda () (interactive) (compile "cargo run"))))
    (meow-normal-define-key
     '("e" . er/expand-region)
     '("E" . er/contract-region)
     '("vv" . my/flip-selection-cursor)
     '("vs" . my/ts-select-statement)
     '("ve" . my/ts-select-expression-chain)
     '("vF" . my/ts-select-function-with-attrs)
     '("vf" . my/ts-select-function)
     '("vi" . my/ts-select-impl)
     '("vS" . my/ts-select-struct-expr)
     '("vt" . my/ts-select-trait)
     '("vb" . my/ts-select-block)
     '("h" . eldoc)
     '("H" . eldoc-doc-buffer)
     '("C" . mc/mark-next-like-this)
     '("j" . meow-join)
     '("d" . meow-kill)
     '("y" . meow-save)
     '("P" . meow-clipboard-yank)
     '("p" . meow-yank)
     '("/" . meow-visit)
     '("i" . meow-insert)
     '("x" . meow-line)
     '("Q" . my-delete-other-windows-and-kill-minibuffer)
     '("q" . kill-current-buffer)
     '("u" . undo)
     '("U" . undo-redo)
     '("n" . meow-search)
     '("g l" . end-of-line)
     '("g h" . beginning-of-line)
     '("'" . meow-mark-word)
     '(";" . comment-line)
     '("M-<up>" . backward-up-list)
     '("M-S-<up>" . meow-block)
     '("M-S-<left>" . meow-pop-to-mark)
     '("M-S-<right>" . meow-unpop-to-mark)
     '("M-RET" . xref-find-definitions)
     '("<backspace>" .  my/meow-backspace-and-insert )
     '("RET" .  my/meow-newline-and-insert )
     '("<escape>" . meow-cancel)))
  (meow-setup)
  (meow-global-mode 1)
  ;; Raccourcis pour sortir d'insert
  (dolist (key '("C-c" "C-g"))
    (define-key meow-insert-state-keymap (kbd key) 'meow-normal-mode))
  ;; Del = delete-forward-char en insert (cohérent avec delete-selection-mode)
  (define-key meow-insert-state-keymap [delete] #'delete-forward-char)
  ;; Retour en normal après save si on était en insert
  (add-hook 'after-save-hook
            (lambda ()
              (when (meow-insert-mode-p) (meow-normal-mode))))
  (defun my/meow-newline-and-insert () (interactive) (newline) (unless (meow-insert-mode-p) (meow-insert)))
  (defun my/meow-backspace-and-insert () (interactive) (delete-backward-char 1) (unless (meow-insert-mode-p) (meow-insert))))

(use-package expand-region)

;; 🌳 Sélections AST (Emacs 30+ treesit native)
(defun my/treesit-select-node-by-type (type)
  "Sélectionne le nœud parent ayant TYPE via treesit."
  (interactive)
  (when-let ((node (treesit-node-at (point))))
    (let ((found nil))
      (while (and node (not found))
        (if (string= (treesit-node-type node) type)
            (setq found t)
          (setq node (treesit-node-parent node))))
      (when node
        (goto-char (treesit-node-start node))
        (set-mark (point))
        (goto-char (treesit-node-end node))))))


(defun my/ts-select-statement ()
  "Sélectionne le plus petit énoncé (statement-like) englobant au point.
Couvre Rust tree-sitter : let_declaration, expression_statement, empty_statement,
et, lorsqu'ils ne sont pas suivis d'un ';', les if/while/loop/for/match en tant
qu'expressions structurantes finales d'un bloc."
  (interactive)
  (let* ((node (and (fboundp 'treesit-node-at) (treesit-node-at (point))))
         ;; Nœuds considérés comme des *statements* en Rust
         (stmt-types '("let_declaration"
                       "expression_statement"
                       "empty_statement"))
         ;; Nœuds de contrôle de flux qui peuvent constituer un “statement-like”
         (flow-expr-types '("if_expression" "while_expression" "loop_expression"
                            "for_expression" "match_expression"))
         ;; Limites à ne pas dépasser (on ne remonte pas au-delà)
         (stop-types '("block" "function_item" "impl_item"
                       "trait_item" "struct_item" "enum_item"
                       "mod_item" "source_file"))
         (target nil))
    (unless node (user-error "Treesitter indisponible ici"))
    (while (and node (not target))
      (let ((type (treesit-node-type node)))
        (cond
         ;; Si on tombe sur un vrai statement → sélectionner
         ((member type stmt-types)
          (setq target node))
         ;; Contrôles de flux non terminés par ';' → sélectionner eux-mêmes
         ((member type flow-expr-types)
          ;; S'il est directement contenu dans un expression_statement, on le laissera
          ;; attraper par le cas ci-dessus au tour suivant ; sinon on peut le prendre.
          (let ((parent (treesit-node-parent node)))
            (unless (and parent
                         (string= (treesit-node-type parent) "expression_statement"))
              (setq target node))))
         ;; Si on atteint une barrière, on s'arrête
         ((member type stop-types)
          (setq node nil))))
      (when node
        (setq node (treesit-node-parent node))))
    (if target
        (progn
          (goto-char (treesit-node-start target))
          (set-mark (point))
          (goto-char (treesit-node-end target)))
      (message "Aucun statement trouvé au voisinage."))))


(defun my/ts-select-function () (interactive) (my/treesit-select-node-by-type "function_item"))
(defun my/ts-select-function-with-attrs ()
  "Sélectionne une fonction Rust avec ses attributs #[...] au-dessus."
  (interactive)
  (let* ((node (treesit-node-at (point))))
    (while (and node (not (string= (treesit-node-type node) "function_item")))
      (setq node (treesit-node-parent node)))
    (when node
      (let ((start (treesit-node-start node))
            (end   (treesit-node-end node)))
        (while-let ((prev (treesit-node-prev-sibling node)))
          (when (string= (treesit-node-type prev) "attribute_item")
            (setq start (treesit-node-start prev)
                  node prev))
          (setq node prev))
        (goto-char start) (push-mark end nil t)))))

(defun my/ts-select-impl () (interactive) (my/treesit-select-node-by-type "impl_item"))
(defun my/ts-select-struct-expr () (interactive) (my/treesit-select-node-by-type "struct_expression"))
(defun my/ts-select-trait () (interactive) (my/treesit-select-node-by-type "trait_item"))
(defun my/ts-select-block () (interactive) (my/treesit-select-node-by-type "block"))
(defun my/ts-select-expression-chain ()
  "Chaîne d'expression Rust à point (field/call/method/etc) sans let/stmt."
  (interactive)
  (let* ((node (treesit-node-at (point)))
         (expression-types '("call_expression" "method_call_expression" "field_expression"
                             "await_expression" "reference_expression" "scoped_identifier"
                             "parenthesized_expression" "struct_expression" "unary_expression"
                             "macro_invocation"))
         (stop-types '("let_declaration" "expression_statement" "assignment_expression"
                       "local_variable_declaration" "statement_block"))
         (last-good node))
    (while (and node (not (member (treesit-node-type node) stop-types)))
      (when (member (treesit-node-type node) expression-types)
        (setq last-good node))
      (setq node (treesit-node-parent node)))
    (when last-good
      (goto-char (treesit-node-start last-good))
      (set-mark (point))
      (goto-char (treesit-node-end last-good)))))

(defun my/flip-selection-cursor () (interactive) (when (region-active-p) (exchange-point-and-mark)))

(use-package ripgrep)

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

;; Smartparens / Multiple cursors -------------------------------------------
(use-package smartparens
  :hook ((prog-mode . smartparens-mode)
         (prog-mode . show-smartparens-mode))
  :config (require 'smartparens-config))

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)))

;; Icons and folders ---------------------------------------------------------
(use-package nerd-icons)
(use-package neotree
  :after nerd-icons
  :config
  (setq neo-theme (if (display-graphic-p) 'nerd-icons 'arrow)
        neo-smart-open t
        neo-autorefresh t
        neo-window-fixed-size t
        neo-window-width 30
        neo-window-position 'left)
  (global-set-key [f8] 'neotree-toggle)

  ;; Look global plus doux
  (custom-set-faces
   '(neo-root-dir-face      ((t (:inherit font-lock-keyword-face :weight semi-bold))))
   '(neo-file-link-face     ((t (:inherit default))))
   '(neo-dir-link-face      ((t (:inherit dired-directory))))
   '(neo-banner-face        ((t (:inherit shadow))))
   '(neo-header-face        ((t (:inherit shadow))))
   '(neo-expand-btn-face    ((t (:inherit shadow))))
   ;; Harmonise la ligne sélectionnée avec ton thème
   '(neo-selected-face      ((t (:inherit hl-line)))))

  ;; >>> COHÉRENCE VC ↔ diff-hl (pastel/flat)
  ;; On fait hériter les états VC des mêmes couleurs que diff-hl
  (custom-set-faces
   '(neo-vc-edited-face         ((t (:inherit diff-hl-change))))
   '(neo-vc-added-face          ((t (:inherit diff-hl-insert))))
   '(neo-vc-removed-face        ((t (:inherit diff-hl-delete))))
   ;; États supplémentaires -> choix sobres cohérents Modus
   '(neo-vc-conflict-face       ((t (:inherit error))))
   '(neo-vc-missing-face        ((t (:inherit warning))))
   '(neo-vc-needs-merge-face    ((t (:slant italic :inherit warning))))
   '(neo-vc-needs-update-face   ((t (:inherit shadow))))
   '(neo-vc-unregistered-face   ((t (:inherit shadow))))
   '(neo-vc-ignored-face        ((t (:inherit shadow))))
   '(neo-vc-uptodate-face       ((t (:inherit success))))))


(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))


(defun neotree-project-dir ()
  "Ouvrir NeoTree à la racine du projet courant."
  (interactive)
  (let* ((proj (project-current))
         (project-dir (if proj (project-root proj) default-directory))
         (file-name (buffer-file-name)))
    (neotree-dir project-dir)
    (when file-name
      (neotree-find file-name))))

;; (defun neotree-project-dir ()
;;   (interactive)
;;   (let ((project-dir (project-root (project-current)))
;;         (file-name (buffer-file-name)))
;;     (neotree-dir project-dir)
;;     (neotree-find file-name)))

(windmove-default-keybindings)

;; Outils Rust ---------------------------------------------------------------
(defun my/rust-current-function-name ()
  "Retourne le nom de la fonction Rust à point."
  (let ((node (treesit-node-at (point))))
    (while (and node (not (string= (treesit-node-type node) "function_item")))
      (setq node (treesit-node-parent node)))
    (when node
      (treesit-node-text (treesit-node-child-by-field-name node "name") t))))

(defun my/rust-run-test-at-point ()
  "Lance `cargo test nom_de_fonction` pour la fonction Rust à point."
  (interactive)
  (let ((fn-name (my/rust-current-function-name)))
    (if fn-name
        (compile (format "cargo test %s" fn-name))
      (message "Pas de fonction Rust trouvée à point."))))

;; Fichiers récents • sauvegardes propres -----------------------------------
(savehist-mode 1)
(recentf-mode 1)

;; Crée les dossiers si besoin
(dolist (dir '("~/.emacs.d/whatever-tmp/" "~/.emacs.d/tmp/backups/"))
  (make-directory (expand-file-name dir) t))

(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" "~/.emacs.d/whatever-tmp/" t))
      lock-file-name-transforms `((".*" "~/.emacs.d/whatever-tmp/" t))
      recentf-max-saved-items 300
      recentf-auto-cleanup 'never
      recentf-exclude '("^/tmp/" "/ssh:" "/sudo:" "\\.gz\\'"))

;; Custom --------------------------------------------------------------------
(custom-set-variables
 '(custom-safe-themes
   '("04aa1c3ccaee1cc2b93b246c6fbcd597f7e6832a97aaeac7e5891e6863236f9f"
     "6fc9e40b4375d9d8d0d9521505849ab4d04220ed470db0b78b700230da0a86c1"
     "77f281064ea1c8b14938866e21c4e51e4168e05db98863bd7430f1352cab294a"
     "6bf350570e023cd6e5b4337a6571c0325cec3f575963ac7de6832803df4d210a"
     "6242983189e4bf1ba242ce2c3898f00a7c3a47e1efa5e30bb16decc152561763"
     "4cb05ff1c61cdc6ebf20660a6df7b0c42b3c81f71fd26f43d60bb771747f36fe"
     "971810f25e8b71e7707b2664938527de862285f0262faef4b78f5f44123aa0bf"
     "ba15d4e40d0aac4a52b488e9653f55b4b23e3cd138cd1f92b4985e75eb9d5cef"
     "c65aa5e34a509b87490a1bf0dd57f6f7945a93ecdea3a132f28eeea85ea85fba"
     "3c5d0dbea8e6fd345022388067c017e70f3664578fb7162464c5f0eb59d443f4"
     "78ece742f4b77ec99a3154ba54fce904dfb5a34dd17d30e8c5d8e32616c5070b"
     "c08b7f761b6af5bd634b35dd0f1b6895bf587064706a52f75a772c2b57e16884"
     "7e2b6a353ab975f5f900da299e84164eceab0506fddb809384bdcafc56f15e66"
     "b5b854b2078308f853cdc4569cd59fae7f08492d287ee7845bc2059b83e403eb"
     "4100257752b84facf7a6898d619fa1d3ac51e36d34f9e2ef4ee9b52445f1ddeb"
     "942bd96d683002053ca9a7a1cf1a8dea397a6c851eb0a17db02c21db9ec01236"
     "b754d3a03c34cfba9ad7991380d26984ebd0761925773530e24d8dd8b6894738"
     "c1d5759fcb18b20fd95357dcd63ff90780283b14023422765d531330a3d3cec2"
     "9013233028d9798f901e5e8efb31841c24c12444d3b6e92580080505d56fd392"
     "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0"
     "dccf4a8f1aaf5f24d2ab63af1aa75fd9d535c83377f8e26380162e888be0c6a9"
     "10e5d4cc0f67ed5cafac0f4252093d2119ee8b8cb449e7053273453c1a1eb7cc"
     "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69"
     "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098"
     "7ec8fd456c0c117c99e3a3b16aaf09ed3fb91879f6601b1ea0eeaee9c6def5d9"
     "a9eeab09d61fef94084a95f82557e147d9630fbbb82a837f971f83e66e21e5ad"
     "4b6cc3b60871e2f4f9a026a5c86df27905fb1b0e96277ff18a76a39ca53b82e1"
     "2078837f21ac3b0cc84167306fa1058e3199bbd12b6d5b56e3777a4125ff6851"
     "34cf3305b35e3a8132a0b1bdf2c67623bc2cb05b125f8d7d26bd51fd16d547ec"
     "2721b06afaf1769ef63f942bf3e977f208f517b187f2526f0e57c1bd4a000350"
     "4d5d11bfef87416d85673947e3ca3d3d5d985ad57b02a7bb2e32beaf785a100e"
     "f64189544da6f16bab285747d04a92bd57c7e7813d8c24c30f382f087d460a33"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8"
     default)))
(custom-set-faces)
