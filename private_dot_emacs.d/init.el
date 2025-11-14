;;;; -*- lexical-binding: t -*-

;; -----------------------------------------------------------------
;; BASIC UI & STARTUP
;; -----------------------------------------------------------------

;;remove splash screen
(setq inhibit-splash-screen t)

;;remove startup message
(setq inhibit-startup-message t)

;;add global line numbers + relative
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

;;font
(set-face-attribute 'default nil
	:font "FiraCode Nerd Font"
	:height 140)

;;start window size
(add-to-list 'default-frame-alist '(width . 120))
(add-to-list 'default-frame-alist '(height . 35))

;; -----------------------------------------------------------------
;; PACKAGE MANAGEMENT (MELPA & USE-PACKAGE)
;; -----------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives
	'("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;bootstrap 'use-package'
(unless (package-installed-p 'use-package)
	(package-refresh-contents)
	(package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; -----------------------------------------------------------------
;; UI PACKAGES
;; -----------------------------------------------------------------

;;doom themes
(use-package doom-themes
	:ensure t
	:config
	(load-theme 'doom-horizon t))

;;bindings popup
(use-package which-key
	:ensure t
	:config
	(which-key-mode))

;;treemacs
(use-package treemacs
	:ensure t
)

(use-package treemacs-projectile
	:after(treemacs-projectile)
	:ensure t
)

(use-package treemacs-magit
	:after (treemacs-magit)
	:ensure t
)

;; -----------------------------------------------------------------
;; LSP & AUTOCOMPLETION
;; -----------------------------------------------------------------

;;autocompletion (FIXED: Added 'company' package name)
(use-package company
	:ensure t
	:hook (after-init . global-company-mode)
)

;;lsp
(use-package lsp-mode
	:ensure t
	:commands (lsp lsp-deferred)
	:hook(
		(python-mode . lsp-deferred)
		(rust-mode . lsp-deferred)
		(golang-mode . lsp-deferred) ;; <-- (FIXED: Added space)
	)
	:init
	(setq lsp-keymap-prefix "C-c l"))

;;lsp ui
(use-package lsp-ui
	:ensure t
	:commands lsp-ui-mode
	:after lsp-mode
)

;; -----------------------------------------------------------------
;; LANGUAGE-SPECIFIC LSP HELPERS (NEW!)
;; -----------------------------------------------------------------
;;
;; These packages tell lsp-mode which server to use for each
;; language. You MUST also install the servers on your computer.
;;
;; -----------------------------------------------------------------

;; 1. PYTHON (using Pyright)
(use-package lsp-jedi
  :ensure t
)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
