;;; init-projects.el --- Projects and navigation -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(use-package project
  :config
  (setq project-search-path '("~/Documents/repos" "~/Documents/hackathon/")
        project-respect-compile-command t
        project-switch-commands
        '((project-find-file "Find file")
          (project-dired "Dired")
          (magit-project-status "Magit" ?m))))

(setq compilation-read-command nil)

(defun my/consult-cargo-commands ()
  "Choisir une commande Cargo et l'exécuter via `compile`."
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
  "Choisir un projet puis ouvrir `project-find-file` dans celui-ci."
  (interactive)
  (let ((dir (project-prompt-project-dir)))
    (let ((default-directory dir))
      (when-let ((proj (project-current nil dir)))
        (project-remember-project proj))
      (project-find-file))))

(defun my/consult-flymake-project ()
  "Afficher les diagnostics Flymake pour tous les buffers du projet courant."
  (interactive)
  (consult-flymake t))

(use-package ripgrep)

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
  (global-set-key [f8] #'neotree-toggle)
  (custom-set-faces
   '(neo-root-dir-face      ((t (:inherit font-lock-keyword-face :weight semi-bold))))
   '(neo-file-link-face     ((t (:inherit default))))
   '(neo-dir-link-face      ((t (:inherit dired-directory))))
   '(neo-banner-face        ((t (:inherit shadow))))
   '(neo-header-face        ((t (:inherit shadow))))
   '(neo-expand-btn-face    ((t (:inherit shadow))))
   '(neo-selected-face      ((t (:inherit hl-line))))
   '(neo-vc-edited-face     ((t (:inherit diff-hl-change))))
   '(neo-vc-added-face      ((t (:inherit diff-hl-insert))))
   '(neo-vc-removed-face    ((t (:inherit diff-hl-delete))))
   '(neo-vc-conflict-face   ((t (:inherit error))))
   '(neo-vc-missing-face    ((t (:inherit warning))))
   '(neo-vc-needs-merge-face ((t (:slant italic :inherit warning))))
   '(neo-vc-needs-update-face ((t (:inherit shadow))))
   '(neo-vc-unregistered-face ((t (:inherit shadow))))
   '(neo-vc-ignored-face    ((t (:inherit shadow))))
   '(neo-vc-uptodate-face   ((t (:inherit success))))))

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

(use-package ansi-color
  :config
  (defun my/ansi-colorize-compilation ()
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region compilation-filter-start (point))))
  (add-hook 'compilation-filter-hook #'my/ansi-colorize-compilation))

(provide 'init-projects)
;;; init-projects.el ends here
