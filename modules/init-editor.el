;;; init-editor.el --- Editing helpers -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(require 'subr-x)

(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

(defun my/treesit-select-node-by-type (type)
  "Sélectionne le nœud parent ayant TYPE via treesit."
  (interactive)
  (when-let ((node (and (fboundp 'treesit-node-at) (treesit-node-at (point)))))
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
  "Sélectionne le plus petit statement Rust autour du point."
  (interactive)
  (let* ((node (and (fboundp 'treesit-node-at) (treesit-node-at (point))))
         (stmt-types '("let_declaration" "expression_statement" "empty_statement"))
         (flow-expr-types '("if_expression" "while_expression" "loop_expression"
                            "for_expression" "match_expression"))
         (stop-types '("block" "function_item" "impl_item" "trait_item"
                       "struct_item" "enum_item" "mod_item" "source_file"))
         (target nil))
    (unless node (user-error "Treesitter indisponible ici"))
    (while (and node (not target))
      (let ((type (treesit-node-type node)))
        (cond
         ((member type stmt-types)
          (setq target node))
         ((member type flow-expr-types)
          (let ((parent (treesit-node-parent node)))
            (unless (and parent
                         (string= (treesit-node-type parent) "expression_statement"))
              (setq target node))))
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

(defun my/ts-select-expression-chain ()
  "Sélectionne une chaîne d'expressions Rust au point."
  (interactive)
  (let* ((node (and (fboundp 'treesit-node-at) (treesit-node-at (point))))
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

(defun my/ts-select-function ()
  (interactive)
  (my/treesit-select-node-by-type "function_item"))

(defun my/ts-select-function-with-attrs ()
  "Sélectionne une fonction Rust avec ses attributs #[...]."
  (interactive)
  (let ((node (and (fboundp 'treesit-node-at) (treesit-node-at (point)))))
    (while (and node (not (string= (treesit-node-type node) "function_item")))
      (setq node (treesit-node-parent node)))
    (when node
      (let ((start (treesit-node-start node))
            (end (treesit-node-end node)))
        (while-let ((prev (treesit-node-prev-sibling node)))
          (when (string= (treesit-node-type prev) "attribute_item")
            (setq start (treesit-node-start prev)
                  node prev))
          (setq node prev))
        (goto-char start)
        (push-mark end nil t)))))

(defun my/ts-select-impl ()
  (interactive)
  (my/treesit-select-node-by-type "impl_item"))

(defun my/ts-select-struct-expr ()
  (interactive)
  (my/treesit-select-node-by-type "struct_expression"))

(defun my/ts-select-trait ()
  (interactive)
  (my/treesit-select-node-by-type "trait_item"))

(defun my/ts-select-block ()
  (interactive)
  (my/treesit-select-node-by-type "block"))

(defun my/flip-selection-cursor ()
  (interactive)
  (when (region-active-p)
    (exchange-point-and-mark)))

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

(use-package smartparens
  :hook ((prog-mode . smartparens-mode)
         (prog-mode . show-smartparens-mode))
  :config
  (require 'smartparens-config))

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)))

(use-package expand-region)

(provide 'init-editor)
;;; init-editor.el ends here
