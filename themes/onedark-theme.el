;;; onedark-theme.el --- OneDark Custom Theme -*- lexical-binding: t; -*-

(deftheme onedark "A custom OneDark-inspired theme based on Helix colors")

(let ((class '((class color) (min-colors 89)))
      (yellow "#EFCF7F") (blue "#6699FF") (red "#FF9988") (purple "#CC77CC")
      (green "#98C379") (gold "#D19A66") (cyan "#56B6C2") (white "#ABB2BF")
      (black "#161A28") (light-black "#2C323C") (gray "#3E4452")
      (faint-gray "#3B4048") (light-gray "#5C6370") (linenr "#4B5263")
      (orange "#D19A66"))

  (custom-theme-set-faces
   'onedark

   ;; Default UI
   `(default ((,class (:background ,black :foreground ,white))))
   `(cursor ((,class (:background ,white))))
   `(region ((,class (:background ,faint-gray))))
   `(fringe ((,class (:background ,black))))
   `(highlight ((,class (:background ,gray))))
   `(vertical-border ((,class (:foreground ,gray))))
   `(line-number ((,class (:foreground ,linenr :background ,black))))
   `(line-number-current-line ((,class (:foreground ,white :background ,black :weight bold))))

   ;; Status line / modeline
   `(mode-line ((,class (:background ,light-black :foreground ,white))))
   `(mode-line-inactive ((,class (:background ,light-black :foreground ,light-gray))))

   ;; Syntax highlighting
   `(font-lock-comment-face ((,class (:foreground ,light-gray :slant italic))))
   `(font-lock-constant-face ((,class (:foreground ,purple))))
   `(font-lock-preprocessor-face ((,class (:foreground ,purple))))
   `(font-lock-builtin-face ((,class (:foreground ,gold))))
   `(font-lock-function-name-face ((,class (:foreground ,blue))))
   `(font-lock-variable-name-face ((,class (:foreground ,red))))
   `(font-lock-type-face ((,class (:foreground ,yellow))))
   `(font-lock-keyword-face ((,class (:foreground ,purple))))
   `(font-lock-string-face ((,class (:foreground ,green))))
   `(font-lock-warning-face ((,class (:foreground ,red :weight bold))))
   
   `(font-lock-custom-visibility-modifier ((,class (:foreground ,orange))))
   `(font-lock-custom-method-call-field ((,class (:foreground ,blue))))
   `(font-lock-custom-attribute ((,class (:foreground ,blue))))
   `(font-lock-custom-attribute-arguments ((,class (:foreground ,yellow))))
   `(font-lock-custom-use-import ((,class (:foreground ,blue))))

   ;; Markup (org, markdown, etc.)
   `(markup-heading-face ((,class (:foreground ,red :weight bold))))
   `(markup-raw-inline-face ((,class (:foreground ,green))))
   `(markup-bold-face ((,class (:foreground ,gold :weight bold))))
   `(markup-italic-face ((,class (:foreground ,purple :slant italic))))
   `(markup-strikethrough-face ((,class (:strike-through t))))
   `(markup-list-face ((,class (:foreground ,red))))
   `(markup-quote-face ((,class (:foreground ,yellow))))
   `(markup-link-url-face ((,class (:foreground ,cyan :underline t))))
   `(markup-link-text-face ((,class (:foreground ,purple))))
   
   ;; Neotree
   `(neo-root-dir-face ((,class (:foreground ,yellow :weight bold))))
   `(neo-dir-link-face ((,class (:foreground ,blue))))
   `(neo-file-link-face ((,class (:foreground ,white))))
   `(neo-expand-btn-face ((,class (:foreground ,gray))))
   `(neo-banner-face ((,class (:foreground ,light-gray))))
   `(neo-header-face ((,class (:foreground ,light-gray :weight bold))))
   `(neo-vc-added-face ((,class (:foreground ,green))))
   `(neo-vc-edited-face ((,class (:foreground ,yellow))))
   `(neo-vc-removed-face ((,class (:foreground ,red))))
   `(neo-button-face ((,class (:foreground ,cyan))))
   `(neo-selected-file-face ((,class (:foreground ,white :background ,faint-gray :weight bold))))

   ;; Dired / Directory view
   `(dired-directory ((,class (:foreground ,blue))))

   ;; Popup / menu
   `(minibuffer-prompt ((,class (:foreground ,blue :weight bold))))
   `(tooltip ((,class (:background ,gray :foreground ,white))))
   `(popup-face ((,class (:background ,gray :foreground ,white))))
   `(popup-menu-face ((,class (:background ,gray :foreground ,white))))
   `(popup-menu-selection-face ((,class (:background ,blue :foreground ,black))))

   ;; Git Gutter / diff-hl
   `(diff-hl-insert ((,class (:foreground ,green :background ,green))))
   `(diff-hl-delete ((,class (:foreground ,red :background ,red))))
   `(diff-hl-change ((,class (:foreground ,yellow :background ,yellow))))


   ;; Diagnostics
   `(error ((,class (:foreground ,red :weight bold))))
   `(warning ((,class (:foreground ,yellow :weight bold))))
   `(success ((,class (:foreground ,green :weight bold))))

   ;; Diff
   `(diff-added ((,class (:foreground ,green))))
   `(diff-removed ((,class (:foreground ,red))))
   `(diff-changed ((,class (:foreground ,gold))))

   ;; LSP diagnostics underline
   `(flycheck-info ((,class (:underline (:style wave :color ,blue)))))
   `(flycheck-warning ((,class (:underline (:style wave :color ,yellow)))))
   `(flycheck-error ((,class (:underline (:style wave :color ,red)))))

   ;; Buffer line
   `(header-line ((,class (:background ,light-black :foreground ,light-gray))))

   ;; Rainbow delimiters
   `(rainbow-delimiters-depth-1-face ((,class (:foreground ,red))))
   `(rainbow-delimiters-depth-2-face ((,class (:foreground ,orange))))
   `(rainbow-delimiters-depth-3-face ((,class (:foreground ,yellow))))
   `(rainbow-delimiters-depth-4-face ((,class (:foreground ,green))))
   `(rainbow-delimiters-depth-5-face ((,class (:foreground ,cyan))))
   `(rainbow-delimiters-depth-6-face ((,class (:foreground ,blue))))
   `(rainbow-delimiters-depth-7-face ((,class (:foreground ,purple))))
   `(rainbow-delimiters-unmatched-face ((,class (:foreground ,red :background ,black :weight bold))))

   ;; Which-key
   `(which-key-key-face ((,class (:foreground ,blue :weight bold))))
   `(which-key-group-description-face ((,class (:foreground ,purple))))
   `(which-key-command-description-face ((,class (:foreground ,white))))
   `(which-key-local-map-description-face ((,class (:foreground ,yellow :weight bold))))

   ;; hl-todo
   `(hl-todo ((,class (:weight bold :foreground ,yellow :background ,black))))
   `(todo ((,class (:weight bold :foreground ,yellow :background ,black))))
   `(warning ((,class (:foreground ,yellow :weight bold))))

   ;; Tab-bar (Emacs 27+)
   `(tab-bar ((,class (:background ,light-black :foreground ,light-gray))))
   `(tab-bar-tab ((,class (:background ,blue :foreground ,black :weight bold))))
   `(tab-bar-tab-inactive ((,class (:background ,light-black :foreground ,light-gray))))
   ))
(provide-theme 'onedark)
;;; onedark-theme.el ends here
