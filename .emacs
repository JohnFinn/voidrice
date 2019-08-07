					; todo
					; multiple crusors (jump to next occurence; next line)
					; faster load time
;prevent emacs from adding mess at the end of this file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(require 'multiple-cursors)
(require 'expand-region)
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

(require 'company)
(require 'company-jedi)
(require 'company-racer)

(add-hook 'python-mode-hook 'auto-complete-mode)
(add-hook 'python-mode-hook 'jedi:ac-setup)
(setq-default py-shell-name "ipython")
(setq-default which-buf-name "IPython")

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
(add-hook 'c++-mode-hook 'rtags-start-process-unless-running)

(require 'rust-mode)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)

(add-hook 'racer-mode-hook #'company-mode)

(require 'rust-mode)
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
(setq company-tooltip-align-annotations t)

(company-mode)


(require 'quelpa)
(require 'use-package)
(require 'quelpa-use-package)
(use-package gdb-mi :quelpa (gdb-mi :fetcher git
                                    :url "https://github.com/weirdNox/emacs-gdb.git"
                                    :files ("*.el" "*.c" "*.h" "Makefile"))
  :init
  (fmakunbound 'gdb)
  (fmakunbound 'gdb-enable-debug))


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
(global-set-key (kbd "C-q") (lambda () (interactive)
			      (if (cdr (window-list))
				  (delete-window)
			      (kill-buffer))
))
(global-set-key [f11] 'toggle-tool-bar-mode-from-frame)
(global-set-key [f12] 'toggle-menu-bar-mode-from-frame)
(global-set-key [f10] 'toggle-scroll-bar)
(global-set-key [f9]  (lambda () (interactive) (my:terminal "make") ))

(setq rtags-split-window-function (lambda ()
      (split-window-right)
      (windmove-right)
      ))


;(setq x-select-enable-clipboard t)

(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-/"))

(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-c C-v") 'clipboard-yank)
(global-set-key (kbd "C-c C-c") 'clipboard-kill-ring-save)

(global-set-key (kbd "C-@") 'er/expand-region)

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
(global-unset-key (kbd "M-j"))

(define-key c-mode-base-map (kbd "M-g k") 'rtags-next-match)
(define-key c-mode-base-map (kbd "M-g l") 'rtags-previous-match)
(global-set-key (kbd "M-g j") 'previous-buffer)
(global-set-key (kbd "M-g ;") 'next-buffer)
(global-set-key (kbd "M-g M-g") 'beginning-of-buffer)
(global-set-key (kbd "M-g G") 'end-of-buffer)


(define-key c-mode-base-map (kbd "M-u") 'rtags-find-references-at-point)
(define-key c-mode-base-map (kbd "M-d") 'rtags-find-symbol-at-point)
(define-key c-mode-base-map (kbd "M-v") 'rtags-find-virtuals-at-point)
(define-key c-mode-base-map (kbd "M-s") 'rtags-find-symbol)
(define-key c-mode-base-map (kbd "M-f") 'rtags-find-file)

(define-key c-mode-base-map (kbd "M-r a") 'rtags-find-references)
(define-key c-mode-base-map (kbd "M-r d") 'rtags-find-references-current-dir)
(define-key c-mode-base-map (kbd "M-r f") 'rtags-find-references-current-file)
(define-key c-mode-base-map (kbd "M-c d") 'rtags-find-symbol-current-dir)
(define-key c-mode-base-map (kbd "M-c f") 'rtags-find-symbol-current-file)


(define-key rust-mode-map (kbd "M-d") 'racer-find-definition)

(defun peek-symbol() (interactive)
       (split-window-below -14)
       (windmove-down)
       (rtags-find-symbol-at-point)
       )

(define-key c-mode-base-map (kbd "M-p") 'peek-symbol)

;(require 'iedit)
; fix idet bug
(define-key global-map (kbd "C-x r") 'iedit-mode)

(global-unset-key (kbd "C-r"))
(global-set-key (kbd "C-r") 'rtags-rename-symbol)

