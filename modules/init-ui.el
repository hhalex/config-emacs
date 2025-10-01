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
        which-func-display 'header
        which-func-modes '(prog-mode)
        which-func-non-auto-modes '(lisp-interaction-mode))
  :config
  (which-function-mode 1)

  (with-eval-after-load 'which-func
    (defun my/disable-which-func-header ()
      ;; Prevent header injection in scratch-style buffers.
      (setq-local which-func-mode nil)
      (when (boundp 'which-func--use-header-line)
        (setq-local which-func--use-header-line nil))
      (setq-local header-line-format nil))

    (add-hook 'lisp-interaction-mode-hook #'my/disable-which-func-header)

    (when-let ((scratch (get-buffer "*scratch*")))
      (with-current-buffer scratch
        (my/disable-which-func-header)))))

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
