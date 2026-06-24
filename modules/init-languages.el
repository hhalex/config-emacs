;;; init-languages.el --- Major mode tweaks -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(defun my/treesit-ensure-react-grammars ()
  "Installe les grammaires Tree-sitter nécessaires aux langages web."
  (interactive)
  (dolist (lang '(tsx typescript javascript css html json))
    (unless (treesit-language-available-p lang)
      (ignore-errors (treesit-install-language-grammar lang)))))

(add-to-list 'auto-mode-alist '("\\.ts\\'"  . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'"  . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))

(defun my/ts-like-setup ()
  (setq-local tab-width 2)
  (electric-pair-mode 1)
  (subword-mode 1)
  (display-line-numbers-mode 1))

(add-hook 'typescript-ts-mode-hook #'my/ts-like-setup)
(add-hook 'tsx-ts-mode-hook        #'my/ts-like-setup)
(add-hook 'js-ts-mode-hook         #'my/ts-like-setup)

(use-package emmet-mode
  :hook ((tsx-ts-mode html-ts-mode css-ts-mode) . emmet-mode)
  :custom
  (emmet-expand-jsx-className? t))

(use-package rust-ts-mode
  :mode "\\.rs\\'"
  :hook ((rust-ts-mode . corfu-mode)))

(add-hook 'rust-mode-hook
          (lambda ()
            (when (and (fboundp 'treesit-ready-p)
                       (treesit-ready-p 'rust))
              (rust-ts-mode))))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

(defun my/rust-current-function-name ()
  "Retourne le nom de la fonction Rust au point."
  (let ((node (treesit-node-at (point))))
    (while (and node (not (string= (treesit-node-type node) "function_item")))
      (setq node (treesit-node-parent node)))
    (when node
      (treesit-node-text (treesit-node-child-by-field-name node "name") t))))

(defun my/rust-run-test-at-point ()
  "Lance `cargo test` sur la fonction Rust actuelle."
  (interactive)
  (let ((fn-name (my/rust-current-function-name)))
    (if fn-name
        (compile (format "cargo test %s" fn-name))
      (message "Pas de fonction Rust trouvée à point."))))

(use-package yaml-ts-mode
  :mode "\\.ya?ml\\'"
  :init
  ;; `yaml-ts-mode' is built-in but needs the tree-sitter grammar installed.
  ;; The explicit `:mode' mapping bypasses treesit-auto's prompt, so register
  ;; the source and compile it once on demand.
  (add-to-list 'treesit-language-source-alist
               '(yaml "https://github.com/ikatyang/tree-sitter-yaml"))
  (unless (treesit-language-available-p 'yaml)
    (treesit-install-language-grammar 'yaml))
  :hook ((yaml-ts-mode . corfu-mode))
  :custom
  (yaml-indent-offset 2))

(use-package noir-ts-mode
  :mode "\\.nr\\'")

(use-package hcl-mode
  :mode ("\\.hcl\\'" "terragrunt\\.hcl\\'")
  :hook ((hcl-mode . display-line-numbers-mode)
         (hcl-mode . electric-pair-mode)
         (hcl-mode . eglot-ensure)))

(use-package terraform-mode
  :mode ("\\.tf\\'" "\\.tfvars\\'")
  :hook ((terraform-mode . display-line-numbers-mode)
         (terraform-mode . electric-pair-mode)
         (terraform-mode . eglot-ensure))
  :custom
  (terraform-indent-level 2))

;; Helm charts: Go templates ({{ ... }}) embedded in YAML. The tree-sitter
;; YAML grammar flags the template delimiters as parse errors, so base the
;; Helm mode on the classic regexp `yaml-mode' and layer Go-template
;; highlighting on top, where `font-lock-add-keywords' works reliably.
(use-package yaml-mode
  ;; Loaded eagerly below so `helm-template-mode' (which derives from it) is
  ;; defined before `auto-mode-alist' tries to resolve a template file.
  :demand t
  :config
  (define-derived-mode helm-template-mode yaml-mode "Helm"
    "Major mode for Helm chart templates (Go templates mixed with YAML)."
    (font-lock-add-keywords
     nil
     '(("{{-?\\|-?}}" . font-lock-builtin-face)
       ("{{-?[ \t]*\\(if\\|else\\|end\\|range\\|with\\|define\\|template\\|block\\|include\\|required\\|default\\|toYaml\\|toJson\\|nindent\\|indent\\|quote\\|printf\\|tpl\\)\\_>"
        1 font-lock-keyword-face)
       ("\\.\\(Values\\|Release\\|Chart\\|Files\\|Capabilities\\|Template\\|Subcharts\\)\\_>"
        . font-lock-variable-name-face)
       ("\\$[A-Za-z_][A-Za-z0-9_]*" . font-lock-variable-name-face))
     'append))
  ;; Loading yaml-mode (re)claims .yaml/.yml in `auto-mode-alist', shadowing
  ;; our tree-sitter `yaml-ts-mode'. Strip those entries here, after the load,
  ;; so yaml-ts-mode stays the default and yaml-mode only backs Helm templates.
  (setq auto-mode-alist (rassq-delete-all 'yaml-mode auto-mode-alist))
  (add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode)))

;; Files under a chart's templates/ directory, plus Helm helper templates.
(add-to-list 'auto-mode-alist
             '("/templates/.*\\.\\(ya?ml\\|tpl\\)\\'" . helm-template-mode))
(add-to-list 'auto-mode-alist '("_helpers\\.tpl\\'" . helm-template-mode))

(use-package dockerfile-mode
  :mode ("Dockerfile\\(?:\\..*\\)?\\'" "\\.dockerfile\\'")
  :hook ((dockerfile-mode . display-line-numbers-mode)
         (dockerfile-mode . electric-pair-mode)))

(provide 'init-languages)
;;; init-languages.el ends here
