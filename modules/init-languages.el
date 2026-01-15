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

(provide 'init-languages)
;;; init-languages.el ends here
