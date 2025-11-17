;; config-go.el
(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :hook ((go-mode . eglot-ensure)
         (before-save . gofmt-before-save)))

(provide 'config-go)
