;; Automatically tangle our Emacs.org config file when we save it
(defun jfl/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/init.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'jfl/org-babel-tangle-config)))

;; File position info
(global-display-line-numbers-mode t)
(global-auto-revert-mode t)
(column-number-mode)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar
;; Enables relative line numbers globally
(setq display-line-numbers-type 'relative)

;; Disable scroll bar
(scroll-bar-mode -1)
;; Disable startup message
(setq inhibit-startup-message t)

;; Remove line numbuers in the follwing
(dolist (mode '(org-mode-hook
        	term-mode-hook
        	shell-mode-hook
        	eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Ding-dong
(setq visible-bell nil)

;; TRANPARENCY!!
(set-frame-parameter (selected-frame) 'alpha '(90 85))

(add-to-list 'default-frame-alist '(alpha 85 85))

(set-face-attribute 'default nil
                    :background "#0F0B0E"  ; your chosen hex color
                    :foreground "#FFFFFF"  ; keeping white for the foreground
                    :font "Courier"
                    :height 180)

;; FONT
(global-font-lock-mode t)
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
:weight 'bold)

(set-face-attribute 'default nil
  :font "VictorMono Nerd Font"
  :height 160
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "Quattrocento Sans"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "VictorMono Nerd Font"
  :height 130
  :weight 'medium)

;; Elpaca Initialization 
(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)

(elpaca `(,@elpaca-order))
;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

(elpaca-wait)

;; EF-Themes
(use-package ef-themes
  :demand t
  :config (load-theme `ef-elea-dark t))

;; Nerd Icons
;; Needs be loaded before the dashboard I think
(use-package nerd-icons 
  :custom
  ;; The Nerd Font you want to use in GUI
  ;; "Symbols Nerd Font Mono" is the default and is recommended
  ;; but you can use any other Nerd Font if you want
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package dashboard
    :ensure t 
    :init
    (setq initial-buffer-choice 'dashboard-open)
    (setq dashboard-set-heading-icons t)
    (setq dashboard-set-file-icons t)
    (setq dashboard-banner-logo-title "Now I am become Death, the destroyer of worlds.")
    ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
    (setq dashboard-startup-banner "~/.emacs.d/images/emacs-dec-resized.jpg")  ;; use custom image as banner
    (setq dashboard-center-content nil) ;; set to 't' for centered content
    (setq dashboard-items '((agenda . 5 )
                            (recents . 5)
                            (bookmarks . 3)
                            (projects . 3)
                            (registers . 3)))
    :custom
    (dashboard-modify-heading-icons '((recents . "file-text")
                                      (bookmarks . "book")))
    :config
    (dashboard-setup-startup-hook))

;; Org Tempo
;; elpaca nil is necessary since Elpaca is asynchronous...
(elpaca nil (require 'org-tempo)
	  (let ((languages '(("sh" . "src shell")
                   ("el" . "src emacs-lisp")
                   ("cpp" . "src c++")
                   ("py" . "src python")
                   ("rb" . "src ruby"))))
  (dolist (language languages)
    (add-to-list 'org-structure-template-alist language))))

(defun jfl/org-mode-setup ()
  (org-indent-mode 1)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

;; Org Babel and syntax highlighting
(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (C . t)
     (ruby .t)))
  (push '("conf-unix" . conf-unix) org-src-lang-modes))
(setq org-babel-python-command "python3")

;; Org mode -- emacs default is usually out of date...
(use-package org
  :config
  (setq org-ellipsis " ▾"
	org-hide-emphasis-markers t))

;; Bullets
(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("▣" "◉" "◈" "◬" "◓" "◑" "◒" "◐" )))

;; Languages
;; Julia Mode
(use-package julia-mode
  :mode "\\.jl\\'"
  :hook (julia-mode . lsp-deferred))
  ;; Julia conventionally uses 4 spaces for indentation, but emacs-julia-mode's default is already set to this.

;; Ruby Mode
(use-package ruby-mode
  :elpaca (:host github :repo "ruby/elisp")
  :mode "\\.rb\\'"
  :hook (ruby-mode . lsp-deferred)
  :config
  ;; Ruby conventionally uses 2 spaces for indentation.
  (setq ruby-indent-level 2))

;; Rust Mode
(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . lsp-deferred)
  :config
  ;; Rust conventionally uses 4 spaces for indentation.
  (setq rust-format-on-save t)
  (setq rust-indent-offset 4))

;; Haskell Mode
(use-package haskell-mode
  :mode "\\.hs\\'"
  :hook (haskell-mode . lsp-deferred)
  :config
  ;; Haskell conventionally uses 4 spaces for indentation.
  (setq haskell-indentation-layout-offset 4
        haskell-indentation-starter-offset 4
        haskell-indentation-left-offset 4
        haskell-indentation-ifte-offset 4))

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil);; Set the variable before loading the package
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  :config
  (evil-mode 1)) ;; Enable Evil mode

;; General 
(use-package general
    :config
    (general-evil-setup)

    ;; set up 'SPC' as the global leader key
    (general-create-definer jfl/leader-keys
      :states '(normal insert visual emacs)
      :keymaps 'override
      :prefix "SPC" ;; set leader
      :global-prefix "M-SPC") ;; access leader in insert mode

    (jfl/leader-keys
      "SPC" '(counsel-M-x :wk "Counsel M-x")
      "." '(find-file :wk "Find file")
      "f c" '((lambda () (interactive) (find-file "~/.emacs.d/config.org")) :wk "Edit emacs config")
      "f r" '(counsel-recentf :wk "Find recent files")
	"f u" '(sudo-edit-find-file :wk "Sudo find file")
	"f U" '(sudo-edit :wk "Sudo edit file")
      "TAB TAB" '(comment-line :wk "Comment lines"))

    (jfl/leader-keys
      "b" '(:ignore t :wk "buffer")
      "b b" '(switch-to-buffer :wk "Switch buffer")
      "b k" '(kill-this-buffer :wk "Kill this buffer")
      "b i" '(ibuffer :wk "Ibuffer")
      "b n" '(next-buffer :wk "Next buffer")
      "b p" '(previous-buffer :wk "Previous buffer")
      "b r" '(revert-buffer :wk "Revert buffer"))

    (jfl/leader-keys
      "e" '(:ignore t :wk "Evaluate")    
      "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
      "e d" '(eval-defun :wk "Evaluate defun containing or after point")
      "e e" '(eval-expression :wk "Evaluate and elisp expression")
      "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
      "e r" '(eval-region :wk "Evaluate elisp in region"))

     (jfl/leader-keys
       "d" '(:ignore t :wk "Dired")
       "d d" '(dired :wk "Open dired")
       "d j" '(dired-jump :wk "Dired jump to current")
       "d n" '(neotree-dir :wk "Open directory in neotree")
       "d p" '(peep-dired :wk "Peep-dired"))

   (jfl/leader-keys
      "h" '(:ignore t :wk "Help")
      "h f" '(describe-function :wk "Describe function")
      "h v" '(describe-variable :wk "Describe variable")
      "h r r" '((lambda () (interactive) (load-file user-init-file)) :wk "Reload emacs config"))
      ;; The code below is if problems are occurring, but it looks like loading it one time should be fine
      ;; "h r r" '((lambda () (interactive) (load-file user-init-file)(load-file user-init-file)) :wk "Reload emacs config"))

    (jfl/leader-keys
        "m" '(:ignore o :wk "Magit")
	  "m s" '(magit-status :wk "Magit Status"))
    
    (jfl/leader-keys
        "o" '(:ignore o :wk "Org")
        "o a" '(org-agenda :wk "Org agenda")
        "o c" '(org-toggle-checkbox :wk "Org toggle check box")
        "o d" '(org-deadline :wk "Org deadline")
        "o e" '(org-export-dispatch :wk "Org export dispatch")
        "o i" '(org-toggle-item :wk "Org toggle item")
        "o l" '(org-insert-link :wk "Org insert link")
        "o s" '(org-schedule :wk "Org schedule")
        "o b" '(org-babel-tangle :wk "Org babel tangle")
        "o T" '(org-todo-list :wk "Org Todo list"))

	;; This could be a hydra option
    (jfl/leader-keys 
        "o t" '(:ignore o :wk "Org")
        "o t -" '(org-table-insert :wk "Org todo")
        "o t 2" '(org-timer :wk "Org timer") ;; org - timer - 2 ('below the @ symbol which looks like a clock)
        "o t @" '(org-timer-stop :wk "Org timer stop") ;; org - timer - 2 ('below the @ symbol which looks like a clock)
        "o t ." '(org-todo :wk "Org todo"))

    (jfl/leader-keys
      "s" '(:ignore t :wk "Shell")
      "s s" '(eshell :which-key "Eshell")
      "s h" '(counsel-esh-history :which-key "Eshell history"))    

     (jfl/leader-keys
      "t" '(:ignore t :wk "Toggle")
      "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
      "t t" '(visual-line-mode :wk "Toggle truncated lines")
      "t v" '(vterm-toggle :wk "Toggle Vterm"))

    (jfl/leader-keys
      "w" '(:ignore t :wk "Windows")
      ;; Window splits
      "w c" '(evil-window-delete :wk "Close window")
      "w n" '(evil-window-new :wk "New window")
      "w s" '(evil-window-split :wk "Horizontal split window")
      "w v" '(evil-window-vsplit :wk "Vertical split window")
      ;; Window motions
      "w h" '(evil-window-left :wk "Window left")
      "w j" '(evil-window-down :wk "Window down")
      "w k" '(evil-window-up :wk "Window up")
      "w l" '(evil-window-right :wk "Window right")
      "w w" '(evil-window-next :wk "Goto next window")
      ;; Window motions
      "w r" '(windresize :wk "Windresize")
      ;; Move Windows
      "w H" '(buf-move-left :wk "Buffer move left")
      "w J" '(buf-move-down :wk "Buffer move down")
      "w K" '(buf-move-up :wk "Buffer move up")
      "w L" '(buf-move-right :wk "Buffer move right"))
  )

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-side-window-location 'bottom
	which-key-sort-order #'which-key-key-order-alpha
	which-key-sort-uppercase-first nil
	which-key-add-column-padding 1
	which-key-max-display-columns nil
	which-key-min-display-lines 6
	which-key-side-window-slot -10
	which-key-side-window-max-height 0.25
	which-key-idle-delay 0.8
	which-key-max-description-length 25
	which-key-allow-imprecise-window-fit nil
	which-key-separator " → " ))

(use-package counsel
  :demand t
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^)

;; IVY
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-f" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :init
  (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-wrap t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t))

;; Ivy Rich
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

;; Doom Modeline
(use-package doom-modeline
  :after nerd-icons
  :ensure t
  :init
  (doom-modeline-mode 1)  ;; Enable Doom Modeline
  :config
  (custom-set-faces
  '(mode-line ((t (:family "Gravitas One" :height 1.1))))
  '(mode-line-active ((t (:family "Gravitas One" :height 1.0)))) ; For 29+
  '(mode-line-inactive ((t (:family "Gravitas One" :height 1.0)))))
  (setq nerd-icons-scale-factor 1.3))

;; Evil collection
(use-package evil-collection
  :after evil
  :init
  (evil-collection-init))

;; Projectile
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom (projectile-completion-system 'ivy)
  :demand t
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package magit
  :commands (magit-status magit-git-current-branch))

;; V-term
(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  (setq vterm-shell "/usr/local/bin/nu")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))
;; Vterm-toggle
;; Source: https://gitlab.com/dwt1/configuring-emacs/-/blob/main/03-shells-terms-and-theming/config.org?ref_type=heads#vterm
(use-package vterm-toggle
:after vterm
:config
(setq vterm-toggle-fullscreen-p nil)
(setq vterm-toggle-scope 'project)
(add-to-list 'display-buffer-alist
             '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                (display-buffer-reuse-window display-buffer-at-bottom)
                ;;(display-buffer-reuse-window display-buffer-in-direction)
                ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                ;;(direction . bottom)
                ;;(dedicated . t) ;dedicated is supported in emacs27
                (reusable-frames . visible)
                (window-height . 0.3))))

(use-package lsp-mode
  :ensure t
  :init
  ;; Set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; Add major modes for LSP
         (ruby-mode . lsp)
         (haskell-mode . lsp)
         (rust-mode . lsp)
         (csharp-mode . lsp)    ;; Ensure lsp is started for C#
         (sh-mode . lsp)        ;; For shell scripts
         (python-mode . lsp)
         (julia-mode . lsp)
         ;; If you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package omnisharp
  :after (company lsp-mode)
  :hook (csharp-mode . omnisharp-mode)
  :config
  (add-to-list 'company-backends 'company-omnisharp))


;; LSP UI tools
(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode)

;; Ivy integration with LSP
(use-package lsp-ivy
  :after lsp-mode 
  :commands lsp-ivy-workspace-symbol)

;; Company Mode
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; LaTeX
;; Assuming you have AUCTeX installed
(use-package auctex
  :ensure t
  :mode ("\\.tex\\'" . LaTeX-mode)
  :hook ((LaTeX-mode . turn-on-reftex)  ; Enable RefTeX with AUCTeX LaTeX mode
         (LaTeX-mode . company-mode))   ; Enable company-mode in LaTeX-mode
  :config
  ;; AUCTeX configurations
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)  ; Query for master file

  ;; Indentation settings, adjust as needed
  (setq LaTeX-indent-level 4)
  (setq LaTeX-item-indent 0)
  (setq TeX-brace-indent-level 4)

  ;; Enable PDF mode by default
  (setq TeX-PDF-mode t))

;; RefTeX settings for both AUCTeX LaTeX mode and Emacs latex mode
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)   ; with AUCTeX LaTeX mode
(add-hook 'latex-mode-hook 'turn-on-reftex)   ; with Emacs latex mode

(use-package sudo-edit)

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

;; Rainbow delimters (parenthises)
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

;; Text size increase
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; Custom Functions
(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
         (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
         (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
         (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
         (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))
