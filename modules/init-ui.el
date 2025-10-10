;;; init-ui.el --- Visual tweaks -*- lexical-binding: t -*-

(eval-when-compile (require 'use-package))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(column-number-mode 1)

(setq-default cursor-type 'bar
              frame-resize-pixelwise t)

(use-package which-func
  :ensure nil
  :init
  (setq which-func-unknown "–"
        which-func-display nil
        which-func-modes '(prog-mode)
        which-func-non-auto-modes '(lisp-interaction-mode))
  :config
  (defface my/which-func-header-face
    '((t :inherit header-line
         :height 0.9
         :box (:line-width -1 :color "gray35")))
    "Face used for the which-function header line.")

  (which-function-mode 1)

  (defun my/which-func-header-string ()
    (when (bound-and-true-p which-func-mode)
      (let* ((label (or (which-function) which-func-unknown))
             (text (cond
                    ((stringp label) label)
                    (label (format "%s" label))
                    (t which-func-unknown)))
             (content (format "  %s  " text))
             (face 'my/which-func-header-face)
             (width (max 0 (- (window-body-width) (string-width content))))
             (padding (make-string width ? )))
        (concat (propertize content 'face face)
                (propertize padding 'face face)))))

  (defun my/setup-which-func-header ()
    ;; Present a compact which-function readout at the top of code buffers.
    (if (eq major-mode 'lisp-interaction-mode)
        (kill-local-variable 'header-line-format)
      (setq-local header-line-format
                  '((which-function-mode (:eval (my/which-func-header-string)))))))

  (add-hook 'prog-mode-hook #'my/setup-which-func-header))

(require 'prot-common)
(require 'prot-modeline)
(require 'use-modeline)
(require 'use-emacs-theme)

(setq modus-themes-italic-constructs t
      modus-themes-bold-constructs t)
(load-theme 'modus-vivendi-tinted t)

(use-package ligature
  :config
  (ligature-set-ligatures
   'prog-mode
   '("<---" "<--" "<<-" "<-" "->" "-->" "--->" "<->" "<-->" "<--->" "<---->" "<!--"
     "<==" "<===" "<=" "=>" "=>>" "==>" "===>" ">=" "<=>" "<==>" "<===>" "<====>" "<!---"
     "<~~" "<~" "~>" "~~>" "::" ":::" "==" "!=" "===" "!==" ":=" ":-" ":+" "<*" "<*>" "*>"
     "<|" "<|>" "|>" "+:" "-:" "=:" "<******>" "++" "+++"))
  (global-ligature-mode t))

(provide 'init-ui)
;;; init-ui.el ends here
