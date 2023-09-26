;; Update load path, and initial value of $PATH used for spawned shells.
(setq user-lib-dir (concat user-emacs-directory "/lib"))
(push user-lib-dir load-path)
(push user-lib-dir exec-path)
(setenv "PATH" (concat  (getenv "PATH") ":" user-lib-dir ":" (concat (getenv "HOME") "/bin")))

;; Helper function: load all .el files in a directory
(defun load-directory (dir)
  (let ((files (directory-files dir t "\\.el$")))
    (while files
      (load-file (car files))
      (setq files (cdr files)))))

;; BEHAVIOR TWEAKS
;; ===============

;; Indent using spaces, not tabs
(setq-default indent-tabs-mode nil)

;; Disable bell
(setq ring-bell-function 'ignore)

;; Honor extension filter when completing file names, even if no characters
;; have been entered.
;; (defadvice completion--file-name-table (after
;;                                         ignoring-backups-f-n-completion
;;                                         activate)
;;   (let ((res ad-return-value))
;;     (if (and (listp res)
;; 	     (stringp (car res))
;; 	     (cdr res))                 ; length > 1, don't ignore sole match
;; 	(setq ad-return-value
;;               (completion-pcm--filename-try-filter res)))))

;; Startup buffer behavior
;; Disable startup screens
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
;; Disable buffer list pop on multiple input files
(setq inhibit-startup-buffer-menu t)
;; Disable window split on multiple input files
;; interferes with ediff-as-difftool
;; (add-hook 'emacs-startup-hook (lambda () (delete-other-windows)) t)

;; Enable integration with the X server clipboard
(setq x-select-enable-clipboard t)

;; Enable automatic reloading of files changed on disk
(global-auto-revert-mode 1)

;; Define revert-all-buffers: Reverts all buffers from their source files
(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files"
  (interactive)
  (let* ((list (buffer-list))
	 (buffer (car list)))
    (while buffer
      (when (and (buffer-file-name buffer)
		 (not (buffer-modified-p buffer)))
	(set-buffer buffer)
	(revert-buffer t t t))
      (setq list (cdr list))
      (setq buffer (car list))))
  (message "Refreshed open files"))

;; Mouse wheel scrolls 3 lines and doesn't accelerate
(setq mouse-wheel-scroll-amount '(3))
(setq mouse-wheel-progressive-speed nil)

;; Set aspell as the spell checker
(setq ispell-program-name "aspell")

;; Enable session management.
(require 'my-desktop)
;; Sessions will also save remotely opened files
(setq desktop-files-not-to-save "^$")

;; Remove trailing whitespace before each save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Refresh syntax highlighting after every save.
(add-hook 'after-save-hook 'font-lock-fontify-buffer)

;; Enable Redo+ mode
(require 'redo+)
;; Set the undo limits to something more reasonable
(setq undo-limit 10000000) ;; soft limit is 10MB
(setq undo-strong-limit 20000000) ;; hard limit is 20MB
;; (setq undo-outer-limit 12000000) ;; max single undoable action is 12MB (by default)

(defun insert-timestamp ()
  "Insert a timestamp on the current line."
  (interactive)
  (progn
    (insert (concatenate 'string
			 "===== "
			 (format-time-string "%b %d %Y")
			 " ==============================================================\n"))))

(defun insert-timestamp-top ()
  "Insert a timestamp at the top of the current buffer."
  (interactive)
  (progn
    (beginning-of-buffer)
    (insert "\n\n")
    (insert-timestamp)
    (insert "\n")
    (beginning-of-buffer)))

;; Enable automatic timestamping on open for files that define the variable
;; timestamp-on-open
(add-hook 'find-file-hook
	  '(lambda ()
	     (if (boundp 'timestamp-on-open)
		 (insert-timestamp-top))))

;; VISUAL TWEAKS
;; =============

;; Enable pixelwise resizing on window systems
(setq frame-resize-pixelwise t)

;; Don't use special formatting for doc comments
(setq c-doc-comment-style 'nil)

;; Autohide the tool bar and menu bar
(when (fboundp 'tool-bar-mode) (tool-bar-mode 0))
(menu-bar-mode 0)

;; Enable column number display
(column-number-mode 1)

;; Indicate column 80, except for C/C++ and python code (using whitespace mode)
;;
(setq-default fill-column 80)
(setq-default whitespace-style '(face lines-tail))
(make-local-variable 'whitespace-line-column)
(setq-default whitespace-line-column 80)
(add-hook 'prog-mode-hook 'whitespace-mode)
(add-hook 'c++-mode-hook
          (lambda ()
	    (setq fill-column 100)
	    (setq c-backslash-max-column 99)
	    (setq whitespace-line-column 100)
	    (whitespace-mode 0)
	    (whitespace-mode 1)))
(add-hook 'python-mode-hook
          (lambda ()
	    (setq fill-column 79)
	    (setq whitespace-line-column 79)
	    (whitespace-mode 0)
	    (whitespace-mode 1)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(whitespace-line ((t (:background "misty rose")))))
;; other options:
;; https://www.emacswiki.org/emacs/ColumnMarker
;; https://github.com/jordonbiondo/column-enforce-mode/
;; https://github.com/ncrohn/emacs/blob/master/vendor/emacs-goodies-el/highlight-beyond-fill-column.el
;; emacs27 native column mode
;; fill-column-indicator
;;   introduces stray characters on character terminals => can't copy out
;;   (require 'fill-column-indicator)
;;   (define-globalized-minor-mode global-fci-mode fci-mode (lambda () (fci-mode 1)))
;;   (global-fci-mode 1)

;; Enable sensible word wrapping by default
(global-visual-line-mode 1)

;; Highlight matching parens
(show-paren-mode t)

;; Disable scrollbars
(when (fboundp 'set-scroll-bar-mode) (set-scroll-bar-mode 'nil))

;; Fix java indentation format to match that of Eclipse
(add-hook 'java-mode-hook (lambda () (setq c-basic-offset 4
					   tab-width 4
					   indent-tabs-mode t)))

;; Highlight programmer annotations
(add-hook 'find-file-hook
	  (lambda ()
	    (font-lock-add-keywords
	     nil
	     '(("\\<\\(FIXME\\|TODO\\|BUG\\|XXX\\|HACK\\|UGLY\\|CAUTION\\|NOTE\\):"
		1 font-lock-warning-face t)))))

;; Fix visual-line-mode
(add-hook 'find-file-hook
	  (lambda () (progn (visual-line-mode 0) (visual-line-mode 1))))

;; Disable visualizaion of subscript
(add-hook 'latex-mode-hook
          (lambda () (fset 'tex-font-lock-suscript 'ignore)))
;;(setq font-latex-fontify-script nil)

;; BUFFER HANDLING
;; ===============

;; Enable inline buffer completion for C-x b
(iswitchb-mode 1)
;; Hide special buffers from C-x b completions
(setq iswitchb-buffer-ignore '("^ " "^\\*.*\\*$"))

;; Disable icons in tabbar-mode, to fix jerkiness issues
(setq tabbar-use-images nil)

;; Enable tabbar mode
(require 'tabbar)
(tabbar-mode 1)

;; Styling choice 1
(set-face-attribute 'tabbar-default nil
                    :background "gray75"
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 3 :color "gray75" :style nil))
(set-face-attribute 'tabbar-unselected nil
                    :background "gray75"
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 3 :color "gray75" :style nil))
(set-face-attribute 'tabbar-modified nil
                    :background "gray75"
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 3 :color "gray75" :style nil))
(set-face-attribute 'tabbar-selected nil
                    :background "#ffffff" ; "white" doesn't work on the terminal
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 3 :color "white" :style nil))
(set-face-attribute 'tabbar-selected-modified nil
                    :background "#ffffff"
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 3 :color "white" :style nil))
(set-face-attribute 'tabbar-highlight nil
                    :background "white"
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 3 :color "white" :style nil))
(set-face-attribute 'tabbar-button nil
                    :background "gray75"
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 1 :color "gray75" :style nil))
(set-face-attribute 'tabbar-button-highlight nil
                    :background "white"
                    :foreground "black"
                    :underline nil
                    :box '(:line-width 1 :color "white" :style nil))
(set-face-attribute 'tabbar-separator nil
                    :background "gray75"
                    :height 0.6)

;; Styling choice 2
;; (set-face-attribute
;;  'tabbar-default nil
;;  :background "gray20"
;;  :foreground "gray20"
;;  :box '(:line-width 1 :color "gray20" :style nil))
;; (set-face-attribute
;;  'tabbar-unselected nil
;;  :background "gray75"
;;  :foreground "gray20"
;;  :box '(:line-width 5 :color "gray20" :style nil))
;; (set-face-attribute
;;  'tabbar-selected nil
;;  :background "gray75"
;;  :foreground "black"
;;  :box '(:line-width 5 :color "black" :style nil))
;; (set-face-attribute
;;  'tabbar-modified nil
;;  :background "gray75"
;;  :foreground "gray30"
;;  :box '(:line-width 5 :color "gray30" :style nil))
;; (set-face-attribute
;;  'tabbar-highlight nil
;;  :background "gray75"
;;  :foreground "black"
;;  :underline nil
;;  :box '(:line-width 5 :color "black" :style nil))
;; (set-face-attribute
;;  'tabbar-button nil
;;  :box '(:line-width 1 :color "gray20" :style nil))
;; (set-face-attribute
;;  'tabbar-separator nil
;;  :background "gray20"
;;  :height 0.6)

;; Styling choice 3
;; (set-face-attribute
;;  'tabbar-default nil
;;  :background "gray60")
;; (set-face-attribute
;;  'tabbar-unselected nil
;;  :background "gray85"
;;  :foreground "gray30"
;;  :box nil)
;; (set-face-attribute
;;  'tabbar-selected nil
;;  :background "#f2f2f6"
;;  :foreground "black"
;;  :box nil)
;; (set-face-attribute
;;  'tabbar-highlight nil
;;  :background "white"
;;  :foreground "black"
;;  :underline nil
;;  :box nil)
;; (set-face-attribute
;;  'tabbar-button nil
;;  :box '(:line-width 1 :color "gray72" :style released-button))
;; (set-face-attribute
;;  'tabbar-separator nil
;;  :height 0.7)

;; Styling choice 4
;; (set-face-attribute
;;  'tabbar-default nil
;;  :background "gray20"
;;  :foreground "gray20"
;;  :box '(:line-width 1 :color "gray20" :style nil))
;; (set-face-attribute
;;  'tabbar-unselected nil
;;  :background "gray30"
;;  :foreground "white"
;;  :box '(:line-width 5 :color "gray30" :style nil))
;; (set-face-attribute
;;  'tabbar-selected nil
;;  :background "gray75"
;;  :foreground "black"
;;  :box '(:line-width 5 :color "gray75" :style nil))
;; (set-face-attribute
;;  'tabbar-highlight nil
;;  :background "white"
;;  :foreground "black"
;;  :underline nil
;;  :box '(:line-width 5 :color "white" :style nil))
;; (set-face-attribute
;;  'tabbar-button nil
;;  :box '(:line-width 1 :color "gray20" :style nil))
;; (set-face-attribute
;;  'tabbar-separator nil
;;  :background "gray20"
;;  :height 0.6)

;; Styling choice 5
;; (set-face-attribute
;;  'tabbar-default nil
;;  :background "gray20"
;;  :foreground "gray20"
;;  :box '(:line-width 1 :color "gray20" :style nil))
;; (set-face-attribute
;;  'tabbar-unselected nil
;;  :background "gray30"
;;  :foreground "white"
;;  :underline nil
;;  :box '(:line-width 5 :color "gray30" :style nil))
;; (set-face-attribute
;;  'tabbar-modified nil
;;  :background "gray30"
;;  :foreground "red"
;;  :underline nil
;;  :box '(:line-width 5 :color "gray30" :style nil))
;; (set-face-attribute
;;  'tabbar-selected nil
;;  :background "white"
;;  :foreground "black"
;;  :underline nil
;;  :box '(:line-width 5 :color "white" :style nil))
;; ;; highlight is hover behavior
;; (set-face-attribute
;;  'tabbar-highlight nil
;;  :background "DarkCyan"
;;  :foreground "green"
;;  :underline nil
;;  :box '(:color "DarkCyan" :style nil))
;; ;; defaults for button
;; (set-face-attribute
;;  'tabbar-button nil
;;  :underline nil
;;  :box '(:line-width 1 :color "white" :style nil))
;; (set-face-attribute
;;  'tabbar-unselected nil
;;  :background "gray34"
;;  :foreground "white"
;;  :box '(:line-width 1 :color "white" :style released-button))
;; (set-face-attribute
;;  'tabbar-modified nil
;;  :background "gray34"
;;  :foreground "pink"
;;  :inherit 'tabbar-unselected
;;  :box '(:line-width 1 :color "white" :style released-button))
;; (set-face-attribute
;;  'tabbar-selected nil
;;  :background "#bcbcbc"
;;  :foreground "black"
;;  :box nil)
;; (set-face-attribute
;;  'tabbar-button nil
;;  :box '(:line-width 1 :color "gray72" :style released-button))
;; (set-face-attribute
;;  'tabbar-separator nil
;;  :height 0.7)
;; (set-face-attribute
;;  'tabbar-button nil
;;  :inherit 'tabbar-default-face
;;  :box '(:line-width 1 :color "gray30"))
;; (set-face-attribute 'tabbar-default  nil
;;                     ;;:family "Courier"
;;                     :height 1.1)
;; (set-face-attribute
;;  'tabbar-selected nil
;;  :inherit 'tabbar-default-face
;;  :foreground "blue3"
;;  :background "LightGoldenrod"
;;  :box '(:line-width 1 :color "DarkGoldenrod")
;;  ;;:overline "black" :underline "black"
;;  :weight 'bold)
;; (set-face-attribute
;;  'tabbar-unselected nil
;;  :inherit 'tabbar-default-face
;;  :box '(:line-width 1 :color "gray70"))

;; Hide tabbar buttons
(customize-set-variable 'tabbar-scroll-right-button '(("") ""))
(customize-set-variable 'tabbar-scroll-left-button '(("") ""))
(customize-set-variable 'tabbar-buffer-home-button '(("") ""))

;; Change padding of the tabs
;; we also need to set separator to avoid overlapping tabs by highlighted tabs
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fringe-mode (quote (5 . 0)) nil (fringe))
 '(lua-indent-level 2)
 '(safe-local-variable-values (quote ((timestamp-on-open . f))))
 '(tabbar-separator (quote (0.5)))
 '(terra-indent-level 2))

;; adding spaces
(defun tabbar-buffer-tab-label (tab)
  "Return a label for TAB.
   That is, a string used to represent it on the tab bar."
  (let ((label (if tabbar--buffer-show-groups
		   (format "[%s] " (tabbar-tab-tabset tab))
		 (format "%s " (tabbar-tab-value tab)))))
    ;; Unless the tab bar auto scrolls to keep the selected tab
    ;; visible, shorten the tab label to keep as many tabs as possible
    ;; in the visible area of the tab bar.
    (if tabbar-auto-scroll-flag
	label
      (tabbar-shorten
       label (max 1 (/ (window-width)
		       (length (tabbar-view
				(tabbar-current-tabset)))))))))

;; Sort tabbar buffers by name
(defun tabbar-add-tab (tabset object &optional append_ignored)
  "Add to TABSET a tab with value OBJECT if there isn't one there yet.
   If the tab is added, it is added at the beginning of the tab list,
   unless the optional argument APPEND is non-nil, in which case it is
   added at the end."
  (let ((tabs (tabbar-tabs tabset)))
    (if (tabbar-get-tab object tabset)
        tabs
      (let ((tab (tabbar-make-tab object tabset)))
        (tabbar-set-template tabset nil)
        (set tabset (sort (cons tab tabs)
                          (lambda (a b) (string< (buffer-name (car a)) (buffer-name (car b))))))))))

;; One group for all tabs
(setq tabbar-buffer-groups-function
      (lambda () (list "All Buffers")))

;; Hide scratch and TAGS tabs
(require 'cl)
(setq tabbar-buffer-list-function
      (lambda ()
	(remove-if
	 (lambda(buffer)
	   (or (find (aref (buffer-name buffer) 0) " *")
	       (string= (buffer-name buffer) "TAGS")))
	 (buffer-list))))

;; Start maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; CUSTOM KEY BINDINGS
;; ===================

;; Disable keybindings that conflict with common window manager shortcuts
(global-unset-key (kbd "C-z")) ;; Ctrl-Z minimization/suspension (typically undo)
(global-unset-key (kbd "C-x C-z"))
(global-unset-key (kbd "C-t")) ;; Ctrl-T (typically new tab)
;; M-tab (typically window switching)

;; Define custom next-buffer and previous-buffer commands, that skip over
;; automatic buffers
;; (setq skippable-buffers '("*Messages*" "*scratch*" "*Help*" "*Completions*"
;; 			  "*Buffer List*"))
;; (defun my-next-buffer ()
;;   "next-buffer that skips certain buffers"
;;   (interactive)
;;   (next-buffer)
;;   (while (member (buffer-name) skippable-buffers)
;;     (next-buffer)))
;; (defun my-previous-buffer ()
;;   "previous-buffer that skips certain buffers"
;;   (interactive)
;;   (previous-buffer)
;;   (while (member (buffer-name) skippable-buffers)
;;     (previous-buffer)))

;; Use a minor mode for all custom key bindings:
;; This will stop major modes from overriding my key bindings
(defvar my-keys-minor-mode-map (make-keymap) "my-keys-minor-mode keymap.")

;; These conflict with xref (xref-find-definitions, xref-pop-marker-stack)
(define-key my-keys-minor-mode-map (kbd "M-.") 'tabbar-forward)
(define-key my-keys-minor-mode-map (kbd "M-,") 'tabbar-backward)
;; Ctrl-, and Ctrl-. won't get passed through terminal
;;(define-key my-keys-minor-mode-map (kbd "C-.") 'my-next-buffer)
;;(define-key my-keys-minor-mode-map (kbd "C-,") 'my-previous-buffer)
(define-key my-keys-minor-mode-map (kbd "C-x C-/") 'redo)
(define-key my-keys-minor-mode-map (kbd "C-x C-_") 'redo)
(define-key my-keys-minor-mode-map (kbd "C-x ,") 'windmove-left)
(define-key my-keys-minor-mode-map (kbd "C-x .") 'windmove-right)
(define-key my-keys-minor-mode-map (kbd "C-x C-,") 'windmove-left)
(define-key my-keys-minor-mode-map (kbd "C-x C-.") 'windmove-right)
(define-key my-keys-minor-mode-map (kbd "C-;") 'comment-region)
;; (define-key my-keys-minor-mode-map (kbd "C-:") 'uncomment-region)
(define-key my-keys-minor-mode-map (kbd "C-x k") 'kill-this-buffer)
(define-key my-keys-minor-mode-map (kbd "C-x f") 'find-file)
(define-key my-keys-minor-mode-map (kbd "C-M-i") 'dumb-jump-go)
(define-key my-keys-minor-mode-map (kbd "C-M-u") 'dumb-jump-back)

(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  t " my-keys" 'my-keys-minor-mode-map)
(my-keys-minor-mode 1)

;; Turn this behavior off in the minibuffer:
(defun my-minibuffer-setup-hook ()
  (my-keys-minor-mode 0))
(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)

;; Make sure my keybindings retain precedence, even if subsequently-loaded
;; libraries bring in new keymaps of their own.
;; Because keymaps can be generated at compile time, load seemed like the best
;; place to do this.
;;(defadvice load (after give-my-keybindings-priority)
;;  "Try to ensure that my keybindings always have priority."
;;  (if (not (eq (car (car minor-mode-map-alist)) 'my-keys-minor-mode))
;;      (let ((mykeys (assq 'my-keys-minor-mode minor-mode-map-alist)))
;;        (assq-delete-all 'my-keys-minor-mode minor-mode-map-alist)
;;        (add-to-list 'minor-mode-map-alist mykeys))))
;;(ad-activate 'load)

;; Disable secondary selection
(global-unset-key (kbd "<M-drag-mouse-1>"))   ; was mouse-set-secondary
(global-unset-key (kbd "<M-down-mouse-1>"))   ; was mouse-drag-secondary
(global-unset-key (kbd "<M-mouse-1>"))    ; was mouse-start-secondary
(global-unset-key (kbd "<M-mouse-2>"))    ; was mouse-yank-secondary
(global-unset-key (kbd "<M-mouse-3>"))    ; was mouse-secondary-save-then-kill

;; OLD FIXES
;; =========

;; Lua mode (edited to parse terra blocks)
;; (require 'lua-mode)

;; Regent mode
;; (require 'regent-mode)

;; Highlight word at point
(require 'highlight-symbol)
(setq highlight-symbol-idle-delay 0.5)
(add-hook 'find-file-hook
	  (lambda ()
           (highlight-symbol-mode t)))

;; Enable down/upcase commands
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Don't ask to follow symlinks to VC-managed files
(setq vc-follow-symlinks nil)

;; One space after sentence-ending period
(setq sentence-end-double-space nil)

;; Ediff configuration
;;(setq ediff-diff-options "-w") ;; ignore whitespace
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-ignore-similar-regions t)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; Additional extensions to open in C++ mode
(add-to-list 'auto-mode-alist '("\\.inl\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cuh\\'" . c++-mode))

;; dumb-jump (C-M-g to jump to definition)
(require 'dumb-jump)
(dumb-jump-mode 1)
(setq dumb-jump-force-searcher 'rg)
(setq dumb-jump-rg-search-args "--pcre2 --type-add cpp:*.cu --type-add cpp:*.cuh")
(setq dumb-jump-default-project "~/doesnotexist")

;; Google C++ style
(require 'google-c-style)
(add-hook 'c++-mode-hook 'google-set-c-style)
(add-hook 'c++-mode-hook 'google-make-newline-indent)

;; Disable version control for tramp
(setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp))

;; Disable backups for remote files
(add-to-list 'backup-directory-alist (cons tramp-file-name-regexp nil))

;; Dockerfile mode
(require 'dockerfile-mode)
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

;; Cython mode
(require 'cython-mode)
