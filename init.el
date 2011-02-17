;; Notes
;; C-x +  (balanced windows after split)

;; when I paste with mouse, do it at click (and not at point)
(setq mouse-yank-at-point nil)

;; starter kit disables this
;; (menu-bar-mode 1)
;; '(scroll-bar-mode 'right)

;; from
;; http://curiousprogrammer.wordpress.com/2009/07/13/my-emacs-defaults/

(global-font-lock-mode 1)
(setq inhibit-splash-screen t)
(setq font-lock-maximum-decoration 3)
(setq use-file-dialog nil)
(setq use-dialog-box nil)
(fset 'yes-or-no-p 'y-or-n-p)
(tool-bar-mode -1)
(show-paren-mode 1)
(transient-mark-mode t)
(setq case-fold-search t)
(blink-cursor-mode 0)
(custom-set-variables

 '(indent-tabs-mode nil))
(line-number-mode 1)
(column-number-mode 1)

;; scrolly stuff
;; http://emacs-fu.blogspot.com/2009/12/scrolling.html
(setq
  scroll-margin 0                  
  scroll-conservatively 100000
  scroll-preserve-screen-position 1)

  ;; for some reason 7 at startup is too small, but changing to 7 is pretty...
    ;;(set-default-font "Envy Code R-9")
    ;; the following is size 7 for me...
    ;;(set-default-font "Bitstream Vera Sans Mono-8")

(set-face-font 'default "-unknown-Envy Code R-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")

;; process to save a keyboard macro
;; record it using f3 and f4 (to signal start/stop)
;; C-x C-k n  Give a command name (for the duration of the Emacs session) to the most recently defined keyboard macro (kmacro-name-last-macro).  
;;  M-x insert-kbd-macro <RET> macroname <RET>
;; not used but here for example
(fset 'rerun-pdb
      (lambda (&optional arg)
        "Goto next window.  Kill pdb (gud).  Start pdb and hit
        the c character to
        continue" (interactive "p") (kmacro-exec-ring-item (quote ([24
        111 24 98 103 117 100 return 24 107 return 134217848 112
        100 98 return return 99 return] 0 "%d")) arg)))


;; bind it to f11
(global-set-key '[(f11)]  'rerun-pdb)

;; make shift arrows move between windows
;; http://justinsboringpage.blogspot.com/2009/09/directional-window-movement-in-emacs.html
(windmove-default-keybindings)

;; window resizing http://www.emacswiki.org/emacs/WindowResize
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;; make printer work - http://www.emacswiki.org/emacs/CupsInEmacs
(setq lpr-command "kprinter")

;; xml indent
(defun indent-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    (while (search-forward-regexp "\>[ \\t]*\<" nil t)
      (backward-char) (insert "\n")
      )
    (mark-whole-buffer)
    (indent-region begin end)
    ;(indent-region point-min point-max)
    )
  (message "Ah, much better!"))


(fset 'indent-xml
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([134217848 109 97 114 tab 45 119 tab 104 tab return 134217848 105 110 100 101 tab 45 120 109 tab return] 0 "%d")) arg)))
(global-set-key '[(f9)]  'indent-xml)



;; make js2-mode work with yasnippet
;; see http://blog.tuxicity.se/?p=339
(eval-after-load 'js2-mode
  '(progn
     (define-key js2-mode-map (kbd "TAB") (lambda()
                                            (interactive)
                                            (let ((yas/fallback-behavior 'return-nil))
                                              (unless (yas/expand)
                                                (indent-for-tab-command)
                                                (if (looking-back "^\s*")
                                                    (back-to-indentation))))))))



;; bind M-n to next flymake error
;; inspired by http://www.emacswiki.org/emacs/FlyMake comments
(defun matt-next-flymake-err ()
  (interactive)
  (flymake-goto-next-error)
  (let ((err (get-char-property (point) 'help-echo)))
    (when err
      (message err)))
  )
(defun matt-prev-flymake-err ()
  (interactive)
  (flymake-goto-prev-error)
  (let ((err (get-char-property (point) 'help-echo)))
    (when err
      (message err)))
  )

(global-set-key "\M-n" 'matt-next-flymake-err)
(global-set-key "\M-p" 'matt-prev-flymake-err)

;; local flymake settings for javascript
;; this doesn't currently work.... updating flymake-js.el right now
(defcustom flymake-js-rhino-jar "/home/matt/work/3rdparty/rhino1_7R2/js.jar"
  "Path to Rihno jar file.
The file seems to be named js.jar now and be in the top directory
of the Rhino dir tree."
  :type '(file :must-match t)
  :group 'flymake)


(defcustom flymake-js-rhino-js "/home/matt/work/3rdparty/jslint/fulljslint_rhino.js"
  "Path to rhino.js"
  :type '(file :must-match t)
  :group 'flymake)

;; if compilation-shell-minor-mode is on, then these regexes
;; will make errors linkable
;; thanks Gerard Brunick
(defun matt-add-global-compilation-errors (list)
  (dolist (x list)
    (add-to-list 'compilation-error-regexp-alist (car x))
    (setq compilation-error-regexp-alist-alist
          (cons x
                (assq-delete-all (car x)
                                 compilation-error-regexp-alist-alist)))))
;; (matt-add-global-compilation-errors
;;  `(
;;    (matt-python ,(concat "^ *File \\(\"?\\)\\([^,\" \n    <>]+\\)\\1"
;;                         ", lines? \\([0-9]+\\)-?\\([0-9]+\\)?")
;;                2 (3 . 4) nil 2 2)
;;    (matt-pdb-stack ,(concat "^>?[[:space:]]*\\(\\([-_./a-zA-Z0-9 ]+\\)"
;;                            "(\\([0-9]+\\))\\)"
;;                            "[_a-zA-Z0-9]+()[[:space:]]*->")
;;                   2 3 nil 0 1)
;;    (matt-python-unittest-err "^  File \"\\([-_./a-zA-Z0-9 ]+\\)\", line \\([0-9]+\\).*" 1 2)
;;    )
 ;; We rule out filenames starting with < as these aren't files.
 ;;(pdb "^> *\\([^(< ][^(]*\\)(\\([0-9]+\\))" 1 2)
;; )

(defun matt-set-local-compilation-errors (errors)
  "Set the buffer local compilation errors.

Ensures than any symbols given are defined in
compilation-error-regexp-alist-alist."
  (dolist (e errors)
    (when (symbolp e)
      (unless (assoc e compilation-error-regexp-alist-alist)
        (error (concat "Error %s is not listed in "
                       "compilation-error-regexp-alist-alist")
               e))))
  (set (make-local-variable 'compilation-error-regexp-alist)
       errors))

(add-hook 'shell-mode-hook (lambda () (compilation-shell-minor-mode)))

;; from dimitri fontaine's blog
;; C-c . in org-mode
(defun insert-date ()
  "Insert a time-stamp according to locale's date and time format.\"
(interactive)
(insert (format-time-string "%a, %e %b %Y, %k:%M" (current-time)))'")

(defun darkroom-mode ()
	"Make things simple-looking by removing decoration 
and choosing a simple theme."
        (interactive)
        (setq left-margin 10)
        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (scroll-bar-mode -1)
        (border-width . 0)
        (internal-border-width . 64)
        (auto-fill-mode 1))
;; need to toggle

;;
;; Use archive mode to open Python eggs
(add-to-list 'auto-mode-alist '("\\.egg\\'" . archive-mode))
(add-to-list 'auto-mode-alist '("\\.odp\\'" . archive-mode))
(add-to-list 'auto-mode-alist '("\\.otp\\'" . archive-mode))
;; also for .xo files (zip)
(add-to-list 'auto-mode-alist '("\\.xo\\'" . archive-mode))
;; google gadget
(add-to-list 'auto-mode-alist '("\\.gg\\'" . archive-mode))

;; python coverage
(load-file "/home/matt/work/emacs/pycoverage/pycov2.el")
(require 'pycov2)
(add-hook 'python-mode-hook
          (function (lambda ()
                      (pycov2-mode)
                      (linum-mode))))

;; rainbow mode
(load-file "/home/matt/work/emacs/rainbow/rainbow-mode.el")


;; company mode
(add-to-list 'load-path "/home/matt/work/emacs/company/")
(autoload 'company-mode "company" nil t)

;; anything
(add-to-list 'load-path "/home/matt/work/emacs/anything/")
(require 'anything-config)

;; smex
(add-to-list 'load-path "/home/matt/work/emacs/smex/")
(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)

;; pretty-mode
(add-to-list 'load-path "/home/matt/work/emacs/")
(require 'pretty-mode)

;; point-stack
(add-to-list 'load-path "/home/matt/work/emacs/point-stack")
(require 'point-stack)
(global-set-key '[(f5)] 'point-stack-push)
(global-set-key '[(f6)] 'point-stack-pop)
(global-set-key '[(f7)] 'point-stack-forward-stack-pop)

;; js2
(add-to-list 'load-path "~/work/emacs/js2-mode/")
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(load-file "~/work/emacs/emacs-tango-theme/tango-theme.el")
(setq frame-background-mode 'dark) ;; see rst.el

;; add full-ack
