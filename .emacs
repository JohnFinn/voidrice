; prevent emacs from adding mess at the end of this file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)

(require 'yasnippet)
(yas-global-mode 1)

(defun my:ac-c-header-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'achead:include-directories '"/usr/include/c++/9.1.0")
  (add-to-list 'achead:include-directories '"/usr/include")
)

(add-hook 'c++-mode-hook 'my:ac-c-header-init)
(add-hook 'c-mode-hook 'my:ac-c-header-init)

(require 'drag-stuff)

;(require 'iedit)
; fix idet bug
(define-key global-map (kbd "C-c r") 'iedit-mode)

(defun my:flymake-google-init ()
  (require 'flymake-google-cpplint)
  (custom-set-variables
   '(flymake-google-cpplint-command "/usr/bin/cpplint")
  )
  (flymake-google-cpplint-load)
)

(add-hook 'c-mode-hook 'my:flymake-google-init)
(add-hook 'c++-mode-hook 'my:flymake-google-init)

(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(semantic-mode 1)
(defun my:add-semantic-to-autocomplete()
  (add-to-list 'ac-sources 'ac-source-semantic)
)
(add-hook 'c-mode-common-hook 'my:add-semantic-to-autocomplete)

(require 'rtags)

(load-theme 'monokai)
(global-hl-line-mode 1)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode '(0 . 0))

(defun my:terminal(command) (interactive)
       (start-process "terminal" nil (getenv "TERMINAL") "-e" "two" command (getenv "SHELL"))
)

(global-set-key (kbd "M-1") 'shell-command)
(global-set-key [f2] 'eval-buffer) ; reload config file
(global-set-key (kbd "C-q") 'delete-window)
(global-set-key [f11] 'toggle-tool-bar-mode-from-frame)
(global-set-key [f12] 'toggle-menu-bar-mode-from-frame)
(global-set-key [f10] 'toggle-scroll-bar)
(global-set-key [f9]  (lambda () (interactive) (my:terminal "make") ))

(setq rtags-split-window-function (lambda ()
      (split-window-right)
      (windmove-right)
      ))

(global-set-key (kbd "C-K") 'drag-stuff-down)
(global-set-key (kbd "C-L") 'drag-stuff-up)
(global-set-key (kbd "C-J") 'drag-stuff-left)
(global-set-key (kbd "C-:") 'drag-stuff-right)

(global-unset-key (kbd "M-u"))
(global-set-key (kbd "M-u a") 'rtags-find-references-at-point)
(global-set-key (kbd "M-u d") 'rtags-find-references-current-dir)
(global-set-key (kbd "M-u f") 'rtags-find-references-current-file)

(global-unset-key (kbd "M-f"))
(global-unset-key (kbd "M-v"))
(global-set-key (kbd "M-f a") 'rtags-find-symbol)
(global-set-key (kbd "M-f d") 'rtags-find-symbol-current-dir)
(global-set-key (kbd "M-f f") 'rtags-find-symbol-current-file)
(global-set-key (kbd "M-f v") 'rtags-find-virtuals-at-point)
(global-set-key (kbd "M-f F") 'rtags-find-file)

(global-unset-key (kbd "C-r"))
(global-set-key (kbd "C-r") 'rtags-rename-symbol)
