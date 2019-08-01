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
(add-hook 'c-mode-hook 'rtags-start-process-unless-running)

(require 'quelpa)
(require 'use-package)
(require 'quelpa-use-package)
(use-package gdb-mi :quelpa (gdb-mi :fetcher git
                                    :url "https://github.com/weirdNox/emacs-gdb.git"
                                    :files ("*.el" "*.c" "*.h" "Makefile"))
  :init
  (fmakunbound 'gdb)
  (fmakunbound 'gdb-enable-debug))


(load "~/.emacs.d/debugger.el")

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
(global-unset-key (kbd "M-r"))
(global-unset-key (kbd "M-f"))
(global-unset-key (kbd "M-d"))
(global-unset-key (kbd "M-k"))
(global-unset-key (kbd "M-l"))
(global-unset-key (kbd "M-c"))

(global-set-key (kbd "M-u") 'rtags-find-references-at-point)
(global-set-key (kbd "M-d") 'rtags-find-symbol-at-point)
(global-set-key (kbd "M-v") 'rtags-find-virtuals-at-point)
(global-set-key (kbd "M-s") 'rtags-find-symbol)
(global-set-key (kbd "M-f") 'rtags-find-file)
(global-set-key (kbd "M-k") 'rtags-next-match)
(global-set-key (kbd "M-l") 'rtags-previous-match)

(global-set-key (kbd "M-r a") 'rtags-find-references)
(global-set-key (kbd "M-r d") 'rtags-find-references-current-dir)
(global-set-key (kbd "M-r f") 'rtags-find-references-current-file)
(global-set-key (kbd "M-c d") 'rtags-find-symbol-current-dir)
(global-set-key (kbd "M-c f") 'rtags-find-symbol-current-file)

					;(require 'iedit)
; fix idet bug
(define-key global-map (kbd "C-c r") 'iedit-mode)

(global-unset-key (kbd "C-r"))
(global-set-key (kbd "C-r") 'rtags-rename-symbol)
