;; Recommended to have this at the top
(setq treesit-extra-load-path `(,(concat user-emacs-directory "var/tree-sitter-dist/")
                ,(concat user-emacs-directory "tree-sitter")))
(setq load-prefer-newer t)
(use-package no-littering
  :ensure t)

(use-package quelpa :ensure t)
(use-package quelpa-use-package :ensure t)

(setq
 default-frame-alist
 '((fullscreen . maximized)
   (background-color . "#221")))

;; Customize default emacs
(use-package emacs
  :ensure nil
  :defer
  :hook ((after-init . pending-delete-mode)
;     (after-init . toggle-frame-maximized)
     (after-init . (lambda () (scroll-bar-mode -1)))
     (after-init . (lambda () (window-divider-mode -1)))
     (after-init . gopar/add-env-vars))
  :custom
  ;; flash the frame to represent a bell.
  (visible-bell t)
  (debugger-stack-frame-as-list t)
  (narrow-to-defun-include-comments t)
  (use-short-answers t)
  (confirm-nonexistent-file-or-buffer nil)
  ;; Treat manual switching of buffers the same as programatic
  (switch-to-buffer-obey-display-actions t)
  (switch-to-buffer-in-dedicated-window nil)
  (window-sides-slots '(3 0 3 1))
  ;; Sentences end with 1 space not 2
  (sentence-end-double-space nil)
  ;; make cursor the width of the character it is under
  ;; i.e. full width of a TAB
  (x-stretch-cursor t)
  ;; Stop cursor from going into minibuffer prompt text
  (minibuffer-prompt-properties '(read-only t point-entered minibuffer-avoid-prompt face minibuffer-prompt))
  (history-delete-duplicates t)
  ;; Completion stuff for consult
  (completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-cycle-threshold 3)
  (tab-always-indent 'complete)
  (use-dialog-box nil) ; Lets be consistent and use minibuffer for everyting
  (scroll-conservatively 100)
  (frame-inhibit-implied-resize t)
  (custom-file "~/.emacs.d/ignoreme.el")

  :config
  ;; set keys for Apple keyboard, for emacs in OS X
  (load custom-file)
  (when (eq system-type 'darwin)
    (setq mac-option-key-is-meta nil
      mac-command-key-is-meta t
      mac-command-modifier 'meta
      ns-left-option-modifier 'super ; make opt key do Super
      ns-right-option-modifier 'none ; make opt key do Super
      mac-control-modifier 'control ; make Control key do Control
      ns-function-modifier 'hyper  ; make Fn key do Hyper
      ))
  (setq-default c-basic-offset 4
        c-default-style "linux"
        indent-tabs-mode nil
        ;bxcx
        fill-column 95
        tab-width 4)
  ;; Replaced in favor for `use-short-answers`
  ;; (fset 'yes-or-no-p 'y-or-n-p)
  (prefer-coding-system 'utf-8)
  ;; Uppercase is same as lowercase
  (define-coding-system-alias 'UTF-8 'utf-8)
  ;; Enable some commands
  (put 'upcase-region 'disabled nil)
  (put 'downcase-region 'disabled nil)
  (put 'erase-buffer 'disabled nil)
  ;; C-x n <key> useful stuff
  (put 'narrow-to-region 'disabled nil)
  ;(tool-bar-mode -1)
  ;(menu-bar-mode -1)
  (setq user-full-name "Th3 BxCx")

  :bind (("C-z" . nil)
     ("C-x C-z" . nil)
     ;("C-x C-k RET" . nil)
     ("RET" . newline-and-indent)
     ("C-j" . newline)
     ("M-\\" . cycle-spacing)
     ("C-x \\" . align-regexp)
     ("C-x C-b" . ibuffer)
     ("M-u" . upcase-dwim)
     ("M-l" . downcase-dwim)
     ("M-c" . capitalize-dwim)
     ("C-S-k" . gopar/delete-line-backward)
     ("C-k" . gopar/delete-line)
     ("M-d" . gopar/delete-word)
     ("<M-backspace>" . gopar/backward-delete-word)
     ("M-e" . gopar/next-sentence)
     ("M-a" . gopar/last-sentence)
     ;("Ç" . bxcx/easy-tilde)
     ("C-x k" . (lambda () (interactive) (kill-buffer)))
     ("C-x C-k" . (lambda () (interactive) (bury-buffer))))

  :init
  (defun gopar/copy-filename-to-kill-ring ()
    (interactive)
    (kill-new (buffer-file-name))
    (message "Copied to file name kill ring"))

;;   (defun bxcx/easy-tilde (arg)
;;     "Convert all inputs of Ç in tilde.
;; If given ARG, then it will insert the actual Ç"
;;     (interactive "P")
;;     (if arg
;;         (insert "Ç")
;;       (insert "~")))

  (defun easy-camelcase (arg)
    (interactive "c")
    ;; arg is between a-z
    (cond ((and (>= arg 97) (<= arg 122))
       (insert (capitalize (char-to-string arg))))
      ;; If it's a new line
      ((= arg 13)
       (newline-and-indent))
      ((= arg 59)
       (insert ";"))
      ;; We probably meant a key command, so lets execute that
      (t (call-interactively
          (lookup-key (current-global-map) (char-to-string arg))))))

  (defun sudo-edit (&optional arg)
    "Edit currently visited file as root.
With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
    (interactive "P")
    (if (or arg (not buffer-file-name))
    (find-file (concat "/sudo:root@localhost:"
               (completing-read "Find file(as root): ")))
      (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

  ;; Stolen from https://emacs.stackexchange.com/a/13096/8964
  (defun gopar/reload-dir-locals-for-current-buffer ()
    "Reload dir locals for the current buffer"
    (interactive)
    (let ((enable-local-variables :all))
      (hack-dir-local-variables-non-file-buffer)))

  (defun gopar/delete-word (arg)
    "Delete characters forward until encountering the end of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
    (interactive "p")
    (delete-region
     (point)
     (progn
       (forward-word arg)
       (point))))

  (defun gopar/backward-delete-word (arg)
    "Delete characters backward until encountering the beginning of a word.
With argument, do this that many times.
This command does not push text to `kill-ring'."
    (interactive "p")
    (gopar/delete-word (- arg)))

  (defun gopar/delete-line ()
    "Delete text from current position to end of line char.
This command does not push text to `kill-ring'."
    (interactive)
    (delete-region
     (point)
     (progn (end-of-line 1) (point)))
    (delete-char 1))

  (defadvice gopar/delete-line (before kill-line-autoreindent activate)
    "Kill excess whitespace when joining lines.
If the next line is joined to the current line, kill the extra indent whitespace in front of the next line."
    (when (and (eolp) (not (bolp)))
      (save-excursion
    (forward-char 1)
    (just-one-space 1))))

  (defun gopar/delete-line-backward ()
    "Delete text between the beginning of the line to the cursor position.
This command does not push text to `kill-ring'."
    (interactive)
    (let (p1 p2)
      (setq p1 (point))
      (beginning-of-line 1)
      (setq p2 (point))
      (delete-region p1 p2)))

  (defun gopar/next-sentence ()
    "Move point forward to the next sentence.
Start by moving to the next period, question mark or exclamation.
If this punctuation is followed by one or more whitespace
characters followed by a capital letter, or a '\', stop there. If
not, assume we're at an abbreviation of some sort and move to the
next potential sentence end"
    (interactive)
    (re-search-forward "[.?!]")
    (if (looking-at "[    \n]+[A-Z]\\|\\\\")
    nil
      (gopar/next-sentence)))

  (defun gopar/last-sentence ()
    "Does the same as 'gopar/next-sentence' except it goes in reverse"
    (interactive)
    (re-search-backward "[.?!][   \n]+[A-Z]\\|\\.\\\\" nil t)
    (forward-char))

  (defvar gopar-ansi-escape-re
    (rx (or ?\233 (and ?\e ?\[))
    (zero-or-more (char (?0 . ?\?)))
    (zero-or-more (char ?\s ?- ?\/))
    (char (?@ . ?~))))

  (defun gopar/nuke-ansi-escapes (beg end)
    (save-excursion
      (goto-char beg)
      (while (re-search-forward gopar-ansi-escape-re end t)
    (replace-match ""))))

  (defun gopar/toggle-window-dedication ()
    "Toggles window dedication in the selected window."
    (interactive)
    (set-window-dedicated-p (selected-window)
                (not (window-dedicated-p (selected-window)))))

  (defun gopar/add-env-vars ()
    "Setup environment variables that I will need."
    (load-file "~/.emacs.d/etc/eshell/set_env.el")
    (setq-default eshell-path-env (getenv "PATH"))

    (setq exec-path (append exec-path
                `("/usr/local/bin"
                  "/usr/bin"
                  "/usr/sbin"
                  "/sbin"
                  "/bin"
                  )
                (split-string (getenv "PATH") ":")))))

(use-package calendar
  :ensure nil
  :defer
  :mode ("\\diary\\'" . diary-mode)
  :custom
  ;(diary-file (concat user-emacs-directory "etc/diary"))
  (diary-file (concat "~/Downloads/OrgFiles/" "private/diary"))
  (diary-display-function 'ignore)
  (calendar-mark-diary-entries-flat t)
  (diary-comment-start ";;")
  (diary-comment-end ""))

;; https://stackoverflow.com/a/10091330/2178312
(use-package org
  :defer
  :pin gnu
  :custom
  (org-agenda-include-diary t)
  ;; Where the org files live
  (org-directory "~/codelab/blog/")
  ;; Where archives should go
  (org-archive-location (concat (expand-file-name "~/Documents/OrgFiles/archives.org") "::"))
  ;; Make sure we see syntax highlighting
  (org-src-fontify-natively t)
  ;; I dont use it for subs/super scripts
  (org-use-sub-superscripts nil)
  ;; Should everything be hidden?
  (org-startup-folded 'content)
  (org-M-RET-may-split-line '((default . nil)))
  ;; Don't hide stars
  (org-hide-leading-stars nil)
  (org-hide-emphasis-markers nil)
  ;; Show as utf-8 chars
  (org-pretty-entities t)
  ;; put timestamp when finished a todo
  (org-log-done 'time)
  ;; timestamp when we reschedule
  (org-log-reschedule t)
  ;; Don't indent the stars
  (org-startup-indented nil)
  (org-list-allow-alphabetical t)
  (org-image-actual-width nil)
  ;; Save notes into log drawer
  (org-log-into-drawer t)
  ;;
  (org-fontify-whole-heading-line t)
  (org-fontify-done-headline t)
  ;;
  (org-fontify-quote-and-verse-blocks t)
  ;; See down arrow instead of "..." when we have subtrees
  ;; (org-ellipsis "⤵")
  ;; catch invisible edit
  ( org-catch-invisible-edits 'show-and-error)
  ;; Only useful for property searching only but can slow down search
  (org-use-property-inheritance t)
  ;; Count all children TODO's not just direct ones
  (org-hierarchical-todo-statistics nil)
  ;; Unchecked boxes will block switching the parent to DONE
  (org-enforce-todo-checkbox-dependencies t)
  ;; Don't allow TODO's to close without their dependencies done
  (org-enforce-todo-dependencies t)
  (org-track-ordered-property-with-tag t)
  ;; Where should notes go to? Dont even use them tho
  ;(org-default-notes-file (concat org-directory "notes.org"))
  (org-default-notes-file (concat "~/Documents/OrgFiles/" "notes.org"))
  ;; The right side of | indicates the DONE states
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "IN-PROGRESS(i!)" "WAITING(w!)" "|" "DONE(d!)" "CANCELED(c!)" "DELEGATED(p!)")))

  (setq org-todo-keyword-faces
        '(("TODO" . "#ff0000")
          ("NEXT" . "#ff00ff")
          ("IN-PROGRESS" . "#ff00ff")
          ("WAITING" . "#ff00ff")
          ("DONE" . "#a3cfa0")
          ("CANCELED" . "#ffff00")
          ("DELEGATED" . "#ffff00")))

    ;; Etiquetas que utilizo para mis notas
  (setq org-tag-alist '(("@nota" . ?n)
                        ("@casa" . ?c)
                        ("@fecha" . ?f)
                        ("@salud" . ?s)
                        ("@tarea" . ?t)
                        ("@trabajo" . ?b)))

  ;; Alinea etiquetas
  (setq org-tags-column 80)

  ;; Finalmente haremos que cuando se visualice un fichero con extensión .org éste se adapte a
  ;; la ventana y cuando la línea llegue al final de esta, haga un salto de carro.
  (add-hook 'org-mode-hook 'visual-line-mode)

  ;; Needed to allow helm to compute all refile options in buffer
  (org-outline-path-complete-in-steps nil)
  (org-deadline-warning-days 2)
  (org-log-redeadline t)
  (org-log-reschedule t)
  ;; Repeat to previous todo state
  ;; If there was no todo state, then dont set a state
  (org-todo-repeat-to-state t)
  ;; Refile options
  (org-refile-use-outline-path 'file)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-refile-targets '(("~/~/Documents/OrgFiles/gtd.org" :maxlevel . 3)
            ("~/~/Documents/OrgFiles/someday.org" :level . 1)
            ("~/~/Documents/OrgFiles/tickler.org" :maxlevel . 1)
            ("~/~/Documents/OrgFiles/repeat.org" :maxlevel . 1)
            ))

  ;; Guarda los buffers Org despues de rellenar
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  ;; Lets customize which modules we load up
  (org-modules '(;; ol-eww
         ;; Stuff I've enabled below
         org-habit
         ;; org-checklist
         ))
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  :hook ((org-mode . org-indent-mode)
     (org-mode . org-display-inline-images))
  :custom-face
  (org-scheduled-previously ((t (:foreground "orange"))))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((sql . t)
     (sqlite . t)
     (python . t)
     (java . t)
     ;; (cpp . t)
     (C . t)
     (emacs-lisp . t)
     (shell . t)))
  ;; Save history throughout sessions
  (org-clock-persistence-insinuate))

(use-package org-tempo
  :after org
  :config
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("p" . "src python"))
  (add-to-list 'org-structure-template-alist '("j" . "src java"))
  (add-to-list 'org-structure-template-alist '("k" . "src kotlin"))
  (add-to-list 'org-structure-template-alist '("la" . "src latex"))
  (add-to-list 'org-structure-template-alist '("sa" . "src sage"))
  (add-to-list 'org-structure-template-alist '("sh" . "src sh")))

(use-package org-clock
  :after org
  :custom
  ;; Save clock history accross emacs sessions (read var for required info)
  (org-clock-persist t)
  ;; If idle for more than 15 mins, resolve by asking what to do with clock
  (org-clock-idle-time 15)
  ;; Don't show current clocked in task
  (org-clock-clocked-in-display nil)
  ;; Show more clocking history
  (org-clock-history-length 10)
  ;; Include running time in clock reports
  (org-clock-report-include-clocking-task t)
  ;; Put all clocking info int the "CLOCKING" drawer
  (org-clock-into-drawer "CLOCKING")
  ;; Setup default clocktable summary
  (org-clock-clocktable-default-properties
   '(:maxlevel 2 :scope file :formula % ;; :properties ("Effort" "Points")
           :sort (5 . ?t) :compact t :block today))
  :bind (:map global-map
          ("C-c j" . (lambda () (interactive) (org-clock-jump-to-current-clock)))
          :map org-mode-map
          ("C-c C-x r" . (lambda () (interactive) (org-clock-report)))))

(use-package org-agenda
  :after org
  :bind (("C-c a" . org-agenda))
  :hook ((org-agenda-finalize . hl-line-mode)
     ;; (org-agenda-finalize . org-agenda-entry-text-mode)
     )
  :custom
  (org-agenda-current-time-string (if (and (display-graphic-p)
       (char-displayable-p ?←)
       (char-displayable-p ?─))
      "⬅️ now"
    "now - - - - - - - - - - - - - - - - - - - - - - - - -"))
  (org-agenda-timegrid-use-ampm t)
  (org-agenda-tags-column 0)
  (org-agenda-window-setup 'only-window)
  (org-agenda-restore-windows-after-quit t)
  (org-agenda-log-mode-items '(closed clock state))
  (org-agenda-time-grid '((daily today require-timed)
              (600 800 1000 1200 1400 1600 1800 2000)
              " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"))
  ;; (org-agenda-start-with-log-mode '(closed clock state))
  (org-agenda-files "~/Documents/OrgFiles/agenda-files.org")
  ;; (org-agenda-todo-ignore-scheduled 'future)
  ;; TODO entries that can't be marked as done b/c of children are shown as dimmed in agenda view
  (org-agenda-dim-blocked-tasks 'invisible)
  ;; Start the week view on whatever day im on
  (org-agenda-start-on-weekday nil)
  ;; How to identify stuck/non-stuck projects
  ;; Projects are identified by the 'project' tag and its always the first level
  ;; Next any of these todo keywords means it's not a stuck project
  ;; 3rd, theres no tags that I use to identify a stuck Project
  ;; Finally, theres no special text that signify a non-stuck project
  (org-stuck-projects
   '("+project+LEVEL=1"
     ("IN-PROGRESS" "WAITING" "DONE" "CANCELED" "DELEGATED")
     nil
     ""))
  (org-agenda-prefix-format
   '((agenda . " %-4e %i %-12:c%?-12t% s ")
     (todo . " %i %-10:c %-5e %(gopar/get-schedule-or-deadline-if-available)")
     (tags . " %i %-12:c")
     (search . " %i %-12:c")))
  ;; Lets define some custom cmds in agenda menu
  (org-agenda-custom-commands
   '(("h" "Agenda and Home tasks"
      ((agenda "" ((org-agenda-span 2)))
       (todo "WAITING|IN-PROGRESS")
       (tags-todo "inbox|break")
       (todo "NEXT"))
      ((org-agenda-sorting-strategy '(time-up habit-up priority-down category-up))))

     ("w" "Agenda and break|inbox tasks"
      ((agenda "" ((org-agenda-span 1)))
       (tags-todo "inbox|break"))
      ((org-agenda-sorting-strategy '(time-up habit-up priority-down category-up))))

     ("i" "In-Progress Tasks"
      ((todo "IN-PROGRESS|WAITING")
       (agenda ""))
      ((org-agenda-sorting-strategy '(time-up habit-up priority-down category-up))))

     ("g" "Goals: 12 Week Year"
      ((agenda "")
       (todo "IN-PROGRESS|WAITING"))
      ((org-agenda-sorting-strategy '(time-up habit-up priority-down category-up))
       (org-agenda-tag-filter-preset '("+12WY"))
       (org-agenda-start-with-log-mode '(closed clock state))
       (org-agenda-archives-mode t)
       ))

     ("r" "Weekly Review"
      ((agenda "")
       (todo))
      ((org-agenda-sorting-strategy '(time-up habit-up category-up priority-down ))
       (org-agenda-files "~/Documents/OrgFiles/weekly-reivew-agenda-files.org")
       (org-agenda-include-diary nil)))))
  :init
  ;; Originally from here: https://stackoverflow.com/a/59001859/2178312
  (defun gopar/get-schedule-or-deadline-if-available ()
    (let ((scheduled (org-get-scheduled-time (point)))
      (deadline (org-get-deadline-time (point))))
      (if (not (or scheduled deadline))
      (format "🗓️ ")
      ;; (format " ")
    "   "))))

(use-package org-contacts
  :after org
  :custom
  (org-contacts-files '("~/Documents/OrgFiles/references/contacts.org")))

(use-package org-capture
  :after org
  :bind (("C-c c" . org-capture))
  :custom
  ;; dont create a bookmark when calling org-capture
  (org-capture-bookmark nil)
  ;; also don't create bookmark in other things
  (org-bookmark-names-plist nil)
  (org-capture-templates
   '(
     ("c" "Inbox" entry (file "~/Documents/OrgFiles/inbox.org")
      "* TODO %?\n:PROPERTIES:\n:DATE_ADDED: %u\n:END:")
     ("p" "Project" entry (file "~/Documents/OrgFiles/gtd.org")
      "* %? [%] :project: \n:PROPERTIES: \n:TRIGGER: next-sibling todo!(NEXT) scheduled!(copy)\n:ORDERED: t \n:DATE_ADDED: %u\n:END:\n** TODO Add entry")
     ("t" "Tickler" entry (file "~/Documents/OrgFiles/tickler.org")
      "* TODO %? \nSCHEDULED: %^{Schedule}t\n:PROPERTIES:\n:DATE_ADDED: %u\n:END:\n")
     ("k" "Contact" entry (file "~/Documents/OrgFiles/references/contacts.org")
      "* %? \n%U
:PROPERTIES:
:EMAIL:
:PHONE:
:NICKNAME:
:NOTE:
:ADDRESS:
:BIRTHDAY:
:Blog:
:END:"))))

(use-package ol
  :after org
  :custom
  (org-link-shell-confirm-function 'y-or-n-p)
  (org-link-elisp-confirm-function 'y-or-n-p))

(use-package org-src
  :after org
  :custom
  (org-src-preserve-indentation nil)
  ;; Don't ask if we already have an open Edit buffer
  (org-src-ask-before-returning-to-edit-buffer nil)
  (org-edit-src-content-indentation 0))

(use-package ob-core
  :after org
  :custom
  ;; Don't ask every time when I run a code block
  (org-confirm-babel-evaluate nil))

(use-package org-habit
  :ensure nil
  :custom
  (org-habit-graph-column 45))

(use-package org-indent
  :ensure nil
  :diminish
  :custom
  (org-indent-mode-turns-on-hiding-stars nil))

(use-package org-pomodoro
  :ensure t
  :after org
  :bind (("<f12>" . org-pomodoro))
  :hook ((org-pomodoro-started . gopar/load-window-config-and-close-home-agenda)
     (org-pomodoro-finished . gopar/save-window-config-and-show-home-agenda))
  :custom
  (org-pomodoro-manual-break t)
  (org-pomodoro-short-break-length 20)
  (org-pomodoro-long-break-length 30)
  (org-pomodoro-length 60)
  :init
  (defun gopar/home-pomodoro ()
    (interactive)
    (setq org-pomodoro-length 25
      org-pomodoro-short-break-length 5))

  (defun gopar/work-pomodoro ()
    (interactive)
    (setq org-pomodoro-length 60
      org-pomodoro-short-break-length 20))

  (defun gopar/save-window-config-and-show-home-agenda ()
    (interactive)
    (window-configuration-to-register ?`)
    (delete-other-windows)
    (org-save-all-org-buffers)
    (org-agenda nil "h"))

  (defun gopar/load-window-config-and-close-home-agenda ()
    (interactive)
    (org-save-all-org-buffers)
    (jump-to-register ?`)))

(use-package org-edna
  :ensure t
  :diminish
  :custom
  (org-edna-use-inheritance t)
  ;; Global minor mode, lets enable it once
  :hook (after-init . org-edna-mode))

(use-package org-roam
  :ensure t
  :defer
  :custom
  (org-roam-v2-ack t)
  (org-roam-directory (expand-file-name "~/Documents/OrgFiles/org-roam"))
  (org-roam-db-location (expand-file-name "~/Documents/OrgFiles/org-roam/org-roam.db"))
  (org-roam-tag-sources '(prop))
  (org-roam-db-update-method 'immediate)
  (org-roam-graph-viewer 'browse-url-firefox)
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
      :target (file+head "./references/${slug}.org" "#+title: ${title}\n")
      :unnarrowed t)))
  (org-roam-dailies-directory (expand-file-name "~/Documents/OrgFiles/private/journal/"))
  (org-roam-dailies-capture-templates
   `(("d" "daily" plain (file "~/Documents/OrgFiles/templates/dailies-daily.template")
      :target (file+head "daily/%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))

     ("w" "weekly" plain (file "~/Documents/OrgFiles/templates/dailies-weekly.template")
      :target (file+head "weekly/%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))

     ("m" "monthly" plain (file "~/Documents/OrgFiles/templates/dailies-monthly.template")
      :target (file+head "monthly/%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))

  :bind (:map global-map
          (("C-c n i" . org-roam-node-insert)
           ("C-c n f" . org-roam-node-find)
           ("C-c n g" . org-roam-graph)
           ("C-c n n" . org-roam-capture)
           ("C-c n d" . org-roam-dailies-capture-today)
           ("C-c n s" . consult-org-roam-search)))
  :hook (after-init . org-roam-db-autosync-mode))

;; Belongs from the org-contrib pkg?
(use-package org-annotate-file
  :ensure nil
  :load-path "lisp/org"
  :defer
  :custom
  (org-annotate-file-add-search t)
  :bind (:map prog-mode-map ("C-c C-s" . gopar/org-annotate-file))
  :init
  (defun gopar/org-annotate-file (&optional arg)
    "Annotate current line.
When called with a prefix aurgument, it will open annotations file."
    (interactive "P")
    (require 'org-annotate-file)
    (let* ((root (projectile-project-root))
       (org-annotate-file-storage-file (format "%s.org-annotate.org" root)))
      (if arg
      (find-file org-annotate-file-storage-file)
    (org-annotate-file)))))

(defun gopar/daily-log ()
  "Insert a new daily log entry with the current date."
  (interactive)
  (goto-char (point-max))
  (org-insert-heading-respect-content)
  (insert (format-time-string "[%Y-%m-%d %a]") "\n")
  (insert "- Accomplishments:\n")
  (insert "  - Task 1\n")
  (insert "  - Task 2\n")
  (insert "- Challenges:\n")
  (insert "  - Issue 1\n")
  (insert "  - Issue 2\n")
  (insert "- Learnings:\n")
  (insert "  - Insight 1\n")
  (insert "  - Insight 2\n")
  (insert "- Plans for Tomorrow:\n")
  (insert "  - Task 1\n")
  (insert "  - Task 2\n"))

(use-package eshell
  :ensure nil
  :hook ((eshell-directory-change . gopar/sync-dir-in-buffer-name)
     (eshell-mode . gopar/eshell-specific-outline-regexp)
     (eshell-mode . gopar/eshell-setup-keybinding)
     (eshell-mode . (lambda () (setq-local completion-at-point-functions '(cape-file)))))
  :custom
  (eshell-buffer-maximum-lines 10000)
  (eshell-scroll-to-bottom-on-input t)
  (eshell-highlight-prompt nil)
  (eshell-history-size 1024)
  (eshell-hist-ignoredups t)
  (eshell-input-filter 'gopar/eshell-input-filter)
  (eshell-cd-on-directory t)
  (eshell-list-files-after-cd nil)
  (eshell-pushd-dunique t)
  (eshell-last-dir-unique t)
  (eshell-last-dir-ring-size 32)
  (eshell-list-files-after-cd nil)
  :init
  (defun gopar/eshell-setup-keybinding ()
    ;; Workaround since bind doesn't work w/ eshell??
    (define-key eshell-mode-map (kbd "C-c >") 'gopar/eshell-redirect-to-buffer)
    (define-key eshell-hist-mode-map (kbd "M-r") 'consult-history))

  (defun gopar/eshell-input-filter (input)
    "Do not save empty lines, commands that start with a space or 'l'/'ls'"
    (and
     (not (string-prefix-p "ls" input))
     (not (or (string-prefix-p "l " input) (string-equal "l" input)))
     (not (string-prefix-p "cd" input))
     (eshell-input-filter-default input)
     (eshell-input-filter-initial-space input)))

  (defun eshell/ff (&rest args)
    "Open files in emacs.
Stolen form aweshell"
    (if (null args)
    ;; If I just ran "emacs", I probably expect to be launching
    ;; Emacs, which is rather silly since I'm already in Emacs.
    ;; So just pretend to do what I ask.
    (bury-buffer)
      ;; We have to expand the file names or else naming a directory in an
      ;; argument causes later arguments to be looked for in that directory,
      ;; not the starting directory
      (mapc #'find-file (mapcar #'expand-file-name (eshell-flatten-list (reverse args)))))
    )

  (defun eshell/clear ()
    "Clear the eshell buffer.
This overrides the built in eshell/clear cmd in esh-mode."
    (interactive)
    (eshell/clear-scrollback))

  (defun eshell/z (&optional regexp)
    "Navigate to a previously visited directory in eshell.
Similar to `cd =`"
    (let ((eshell-dirs (delete-dups
            (mapcar 'abbreviate-file-name
                (ring-elements eshell-last-dir-ring)))))
      (eshell/cd (if regexp (eshell-find-previous-directory regexp)
           (completing-read "cd: " eshell-dirs)))))

  (defun eshell/jj ()
    "Jumpt to Root."
    (eshell/cd (projectile-project-root)))

  (defun eshell/cat (filename)
    "Like cat(1) but with syntax highlighting.
Stole from aweshell"
    (let ((existing-buffer (get-file-buffer filename))
      (buffer (find-file-noselect filename)))
      (eshell-print
       (with-current-buffer buffer
     (if (fboundp 'font-lock-ensure)
         (font-lock-ensure)
       (with-no-warnings
         (font-lock-fontify-buffer)))
     (let ((contents (buffer-string)))
       (remove-text-properties 0 (length contents) '(read-only nil) contents)
       contents)))
      (unless existing-buffer
    (kill-buffer buffer))
      nil))

  (defun gopar/sync-dir-in-buffer-name ()
    "Update eshell buffer to show directory path.
Stolen from aweshell."
    (let* ((root (projectile-project-root))
       (root-name (projectile-project-name root)))
      (if root-name
      (rename-buffer (format "*eshell %s* %s" root-name (s-chop-prefix root default-directory)) t)
    (rename-buffer (format "*eshell %s*" default-directory) t))))

  (defun gopar/eshell-redirect-to-buffer (buffer)
    "Auto create command for redirecting to buffer."
    (interactive (list (read-buffer "Redirect to buffer: ")))
    (insert (format " >>> #<%s>" buffer)))

(defun gopar/eshell-specific-outline-regexp ()
  (setq-local outline-regexp eshell-prompt-regexp)))

(use-package eshell-syntax-highlighting
  :ensure t
  :config
  (eshell-syntax-highlighting-global-mode +1)
  :init
  (defface eshell-syntax-highlighting-invalid-face
    '((t :inherit diff-error))
    "Face used for invalid Eshell commands."
    :group 'eshell-syntax-highlighting))

(use-package eshell-git-prompt
  :after eshell
  :ensure t)

(use-package powerline-with-venv
  :ensure nil
  :after eshell-git-prompt
  :load-path "lisp/themes/powerline-with-venv"
  :config
  (add-to-list 'eshell-git-prompt-themes
           '(powerline-plus eshell-git-prompt-powerline-venv eshell-git-prompt-powerline-regexp))
  (eshell-git-prompt-use-theme 'powerline-plus))

;; (use-package powerline-with-pyvenv
;;   :ensure nil
;;   :after eshell-git-prompt
;;   :load-path "lisp/themes/powerline-with-venv"
;;   :config
;;   (add-to-list 'eshell-git-prompt-themes
;;                '(powerline-plus eshell-git-prompt-powerline-pyvenv eshell-git-prompt-powerline-regexp))
;;   (eshell-git-prompt-use-theme 'powerline-plus))

(use-package eshell-vterm
  :ensure
  :after eshell
  :bind (:map vterm-mode-map
     ("C-q" . vterm-send-next-key))
  :config
  (eshell-vterm-mode)
  :init
  (defalias 'eshell/v 'eshell-exec-visual))

(use-package eshell-info-banner
  :ensure t
  :defer t
  :hook (eshell-banner-load . eshell-info-banner-update-banner))

(use-package python
  :ensure nil
  :bind (:map python-mode-map
          ("C-c C-p" . nil)
          ("C-c C-e" . nil)
          ("C-c C-z" . gopar/run-python))
  :hook ((python-mode . (lambda ()
              (setq-local forward-sexp-function nil)
              (make-local-variable 'python-shell-virtualenv-root)
              (setq-local comment-inline-offset 2)
              (setq-local completion-at-point-functions '(cape-file python-completion-at-point cape-dabbrev cape-keyword))))
     (inferior-python-mode . (lambda ()
                   (setq-local completion-at-point-functions '(t)))))

  :init
  (defun gopar/run-python ()
    "Wrapper function for `run-python` that checks if the current project is a Django project."
    (interactive)
    (let* ((manage-directory (locate-dominating-file default-directory "manage.py"))
       (default-directory (or manage-directory default-directory)))
      (if manage-directory
      (run-python (format "python manage.py shell_plus" manage-directory) python-shell-dedicated 0)
    (run-python (python-shell-calculate-command) python-shell-dedicated 0))))
  :custom
  (python-shell-dedicated 'project)
  (python-shell-interpreter "python")
  (python-shell-interpreter-args "")
  (python-forward-sexp-function nil)
  (python-shell-completion-native-disabled-interpreters '("python" "pypy")))

(use-package virtualenvwrapper
  :ensure t
  :init
  (venv-initialize-eshell))

(use-package pyvenv
  :ensure t
  :defer
  :commands (pyvenv-create)
  )

(use-package ruff-format
  :ensure t
  :defer
  :hook (python-mode . gopar/enable-ruff-if-found)
  :init
  (defun gopar/enable-ruff-if-found ()
    "Format the current buffer using the 'ruff` program, if available."
    (interactive)
    (if (executable-find "ruff")
    (ruff-format-on-save-mode))))

(use-package importmagic
  :ensure t
  :defer
  :custom
  (importmagic-be-quiet t)
  :hook (python-mode . gopar/enable-importmagic-if-found)
  ;; :hook (python-mode . (lambda () (run-at-time "3 sec" nil 'gopar/enable-importmagic-if-found)))
  :init
  (defun gopar/enable-importmagic-if-found ()
    "Format the current buffer using the 'importmagic` program, if available."
    (interactive)
    (if (zerop (shell-command "python -c 'import importmagic'"))
    (importmagic-mode))))

(use-package pydoc
  :ensure t
  :defer
  :bind (:map python-mode-map
          ("C-c C-d" . gopar/pydoc-at-point))
  :init
  (add-to-list 'display-buffer-alist
        '("^\\*pydoc" display-buffer-in-side-window
          (slot . 1)
          (side . right)
          (window-parameters . ((no-delete-other-windows . t)))
          (dedicated . t)
          ;; (window-width . 80)
          ))

  (defun gopar/pydoc-at-point ()
    "Display pydoc in a dedicated window.
Calling `gopar/pydoc-at-point' displays the pydoc in a new dedicated window.
Calling `C-u gopar/pydoc-at-point' closes the dedicated window."
    (interactive)
    (let ((default-directory (file-name-directory (buffer-file-name))))
      (if (not (eq current-prefix-arg nil))
      (when (get-buffer-window "*pydoc*")
        (delete-window (get-buffer-window "*pydoc*")))
    (pydoc-at-point)
    (set-window-dedicated-p (get-buffer-window "*pydoc*") t)))))

(use-package jedi
  :ensure t
  :defer
  :commands (jedi-mode)
  :hook (python-mode . jedi-mode)
  :custom
  (jedi:tooltip-method nil)
  (jedi:mode-function nil)
  (jedi:setup-function nil))

(use-package kotlin-mode :ensure t :defer)

(use-package flycheck-kotlin
  :ensure t
  :defer
  :hook (kotlin-mode . (lambda () (flycheck-mode 1) (flycheck-kotlin-setup))))

(use-package gud
  :ensure nil
  :defer
  :custom
  (gud-pdb-command-name "PYTHONBREAKPOINT=pdb.set_trace python -m pdb"))

(use-package compile
  :ensure nil
  :defer
  :custom
  (compilation-scroll-output 'first-error)
  (compilation-always-kill t)
  (compilation-max-output-line-length nil)
  :hook (compilation-mode . hl-line-mode)
  :init
  ; from enberg on #emacs
  (add-hook 'compilation-finish-functions
        (lambda (buf str)
          (if (null (string-match ".*exited abnormally.*" str))
          ;;no errors, make the compilation window go away in a few seconds
          (progn
            (run-at-time
             "1 sec" nil 'delete-windows-on
             (get-buffer-create "*compilation*"))
            (message "No Compilation Errors!")))))

  )

(use-package fancy-compilation
  :ensure t
  :defer 3
  :config
  (fancy-compilation-mode)
  :custom
  (fancy-compilation-scroll-output 'first-error))

(use-package recompile-on-save
  :ensure t
  ;; Kill the buffer message that pops up after running advice on compile
  :hook (after-init . (lambda () (run-at-time 1 nil
     (lambda ()
    (when (get-buffer "*Compile-Log*")
       (kill-buffer "*Compile-Log*"))
    (delete-other-windows)))))

  :init
  (recompile-on-save-advice compile))

(use-package winner
  :ensure nil
  :hook after-init
  :commands (winner-undo winnner-redo)
  :custom
  (winner-boring-buffers '("*Completions*" "*Help*" "*Apropos*"
               "*Buffer List*" "*info*" "*Compile-Log*")))

(use-package window
  :ensure nil
  :defer
  :custom
  (recenter-positions '(middle top bottom)))

(use-package midnight
  :ensure nil
  :hook (after-init . midnight-mode)
  :custom
  (clean-buffer-list-delay-general 0)
  (clean-buffer-list-delay-special 0)
  (clean-buffer-list-kill-regexps '("\\`\\*Man " "\\`\\*helpful" "\\`\\magit")))

(use-package executable
  :ensure nil
  :hook (after-save . executable-make-buffer-file-executable-if-script-p))

;;;(use-package ispell
;;;  :ensure nil
;;;  :custom
;;;  (ispell-program-name "aspell")
;;;  (ispell-personal-dictionary (concat user-emacs-directory "etc/.aspell.lang.pws"))
;;;  (ispell-dictionary nil)
;;;  (ispell-local-dictionary nil)
;;;  (ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"
;;;               "--run-together" "--run-together-limit=16"
;;;               "--camel-case"))
;;;  :init
;;;  (defun gopar/add-word-to-dictionary ()
;;;    (interactive)
;;;    (let ((word (word-at-point)))
;;;      (append-to-file (concat word "\n") nil ispell-personal-dictionary)
;;;      (message "Added '%s' to %s" word ispell-personal-dictionary))))
;;;
;;;(use-package flyspell
;;;  :ensure nil
;;;  :defer
;;;  :hook ((prog-mode . flyspell-prog-mode)
;;;     (org-mode . flyspell-mode)
;;;     (text-mode . flyspell-mode)
;;;     (flyspell-mode . (lambda ()
;;;                (set-face-attribute 'flyspell-incorrect nil :underline '(:style wave :color "Red1"))
;;;                (set-face-attribute 'flyspell-duplicate nil :underline '(:style wave :color "DarkOrange")))))
;;;  :bind (:map flyspell-mode-map
;;;          ("C-;" . nil)
;;;          ("C-," . flyspell-goto-next-error)
;;;          ("C-." . flyspell-auto-correct-word)))
;;;
;;;(use-package dictionary
;;;  :defer
;;;  :ensure nil
;;;  :bind (:map text-mode-map
;;;          ("M-." . dictionary-lookup-definition)
;;;     :map org-mode-map
;;;          ("M-." . dictionary-lookup-definition)
;;;     :map dictionary-mode-map
;;;          ("M-." . dictionary-lookup-definition))
;;;  :init
;;;  (add-to-list 'display-buffer-alist
;;;           '("^\\*Dictionary\\*" display-buffer-in-side-window
;;;         (side . left)
;;;         (window-width . 50)))
;;;  :custom
;;;  (dictionary-server "dict.org"))

;; It may also be wise to raise gc-cons-threshold while the minibuffer is active,
;; so the GC doesn't slow down expensive commands (or completion frameworks, like
;; helm and ivy. The following is taken from doom-emacs
(use-package minibuffer
  :ensure nil
  :custom
  (completion-styles '(initials partial-completion flex)))

(use-package time
  :ensure nil
  :hook (after-init . display-time-mode)
  :custom
  (world-clock-time-format "%A %d %B %r %Z")
  (display-time-day-and-date t)
  (display-time-default-load-average nil)
  (display-time-mail-string "")
  (zoneinfo-style-world-list
  '(("America/Mazatlan" "Mazatlan")
    ("America/Los_Angeles" "Seattle")
    ("America/New_York" "New York")
    ("America/Halifax" "Nova Scotia")
    ("Asia/Tokyo" "Tokyo"))))

(use-package proced
  :ensure nil
  :defer t
  :custom
  (proced-enable-color-flag t)
  (proced-tree-flag t))

(use-package browse-url
  :ensure nil
  :custom
  ;; Emacs can't find browser binaries
  (browse-url-chrome-program "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
  (browse-url-firefox-program "/Applications/Firefox.app/Contents/MacOS/firefox")
  ;; Neat trick to open that route to different places
  (browse-url-firefox-new-window-is-tab t)
  :config
  (put 'browse-url-handlers 'safe-local-variable (lambda (x) t)))

(use-package eww
  :defer t
  :init
  (add-hook 'eww-after-render-hook #'shrface-mode)
  ;; (add-hook 'eww-mode-hook 'ewnium-mode)
  :config
  (require 'shrface))

(use-package ewnium
  :ensure nil
  :load-path "lisp/eww"
  :hook (eww-mode . ewnium-mode))

(use-package shrface
  :ensure t
  :defer t
  :config
  (shrface-basic)
  (shrface-trial)
  (shrface-default-keybindings) ; setup default keybindings
  (setq shrface-href-versatile t))

(use-package shr-tag-pre-highlight
  :ensure t
  :after shr
  :config
  (add-to-list 'shr-external-rendering-functions
           '(pre . shr-tag-pre-highlight)))

(use-package prog-mode
  :ensure nil
  :defer
  :hook ((prog-mode . subword-mode)
     (prog-mode . hl-line-mode)
     (prog-mode . (lambda () (setq-local fill-column 95)))))

(use-package which-func
  :ensure nil
  :defer
  :hook (prog-mode . which-function-mode))

(use-package projectile
  :ensure
  :load t
  :commands projectile-project-root
  :bind-keymap
  ("C-c p" . projectile-command-map)

  :custom
  (projectile-indexing-method 'hybrid)  ;; Not sure if this still needed?
  (projectile-per-project-compilation-buffer nil)
  :config
  (projectile-global-mode)
  (setq frame-title-format '(:eval (if (projectile-project-root) (projectile-project-root) "%b")))
  )

(use-package repeat
  :ensure nil
  :hook (after-init . repeat-mode)
  :custom
  (repeat-too-dangerous '(kill-this-buffer))
  (repeat-exit-timeout 5))

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :custom
  (savehist-additional-variables '(abbrev-minor-mode-table-alist)))

(use-package grep
  :ensure nil
  :defer
  :custom
  (grep-find-ignored-directories (append grep-find-ignored-directories '(".mypy_cache" ".pytest_cache" "htmlcov"))))

(use-package wgrep-ag :ensure t :defer)

(use-package vertico
  :ensure t
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :init
  (vertico-mode)
  :custom
  ;; Different scroll margin
  (setq vertico-scroll-margin 0)
  ;; Show more candidates
  (setq vertico-count 20)
  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)
  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t)
  (vertico-sort-function 'vertico-sort-history-alpha))

(use-package vertico-multiform
  :ensure nil
  :hook (after-init . vertico-multiform-mode)
  :init
  (setq vertico-multiform-commands
    '((consult-line (:not posframe))
      (gopar/consult-line (:not posframe))
      (consult-ag (:not posframe))
      (consult-grep (:not posframe))
      (consult-imenu (:not posframe))
      (xref-find-definitions (:not posframe))
      (t posframe))))

;; just for looks
(use-package vertico-posframe
  :ensure t
  :custom
  (vertico-posframe-parameters
   '((left-fringe . 8)
     (right-fringe . 8))))

(use-package dabbrev
  :custom
  (dabbrev-upcase-means-case-search t)
  (dabbrev-check-all-buffers nil)
  (dabbrev-check-other-buffers t)
  (dabbrev-friend-buffer-function 'dabbrev--same-major-mode-p)
  (dabbrev-ignored-buffer-regexps '("\\.\\(?:pdf\\|jpe?g\\|png\\)\\'")))

(use-package corfu
  :ensure t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-on-exact-match 'insert) ;; Insert when there's only one match
  (corfu-quit-no-match t)        ;; Quit when ther is no match
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary

  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.
  ;; This is recommended since Dabbrev can be used globally (M-/).
  ;; See also `corfu-excluded-modes'.
  :init
  (setq corfu-exclude-modes '(eshell-mode))
  (global-corfu-mode))

(use-package cape
  :ensure t
  :init
  (setq cape-dabbrev-min-length 2)
  (setq cape-dabbrev-check-other-buffers 'cape--buffers-major-mode)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  ;; (add-to-list 'completion-at-point-functions #'cape-history)
  ;;(add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  (defun corfu-enable-always-in-minibuffer ()
    "Enable Corfu in the minibuffer if Vertico/Mct are not active."
    (unless (or (bound-and-true-p mct--active)
        (bound-and-true-p vertico--input)
        (eq (current-local-map) read-passwd-map))
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
          corfu-popupinfo-delay nil)
      (corfu-mode 1)))

  (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)
  :bind ("C-c SPC" . cape-dabbrev)
  )

(use-package orderless
  :ensure t
  :after consult
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :ensure
  :after projectile
  :bind (("C-s" . consult-line)
     ("C-c M-x" . consult-mode-command)
     ("C-x b" . consult-buffer)
     ("C-x r b" . consult-bookmark)
     ("M-y" . consult-yank-pop)
     ;; M-g bindings (goto-map)
     ("M-g M-g" . consult-goto-line)
     ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
     ("M-g m" . consult-mark)
     ("M-g k" . consult-global-mark)
     ("C-z" . consult-theme)
     :map minibuffer-local-map
     ("M-s" . consult-history)                 ;; orig. next-matching-history-element
     ("M-r" . consult-history)
     :map projectile-command-map
     ("b" . consult-project-buffer)
     :map prog-mode-map
     ("M-g o" . consult-imenu))

  :init
  (defun remove-items (x y)
    (setq y (cl-remove-if (lambda (item) (memq item x)) y))
    y)

  ;; Any themes that are incomplete/lacking don't work with centaur tabs/solair mode
  (setq gopar/themes-blacklisted '(
                   ;; doom-tomorrow-night
                   ayu-dark
                   ayu-light
                   doom-acario-dark
                   doom-acario-light
                   doom-homage-black
                   doom-lantern
                   doom-manegarm
                   doom-meltbus
                   doom-rougue
                   light-blue
                   manoj-black
                   tao
                   ))
  (setq consult-themes (remove-items gopar/themes-blacklisted (custom-available-themes)))
  (setq consult-project-function (lambda (_) (projectile-project-root)))
  (setq xref-show-xrefs-function #'consult-xref
    xref-show-definitions-function #'consult-xref)
  (setq consult-narrow-key "<")
  (setq consult-line-start-from-top nil)

  (defun gopar/consult-line (&optional arg)
    "Start consult search with selected region if any.
If used with a prefix, it will search all buffers as well."
    (interactive "p")
    (let ((cmd (if current-prefix-arg '(lambda (arg) (consult-line-multi t arg)) 'consult-line)))
      (if (use-region-p)
      (let ((regionp (buffer-substring-no-properties (region-beginning) (region-end))))
        (deactivate-mark)
        (funcall cmd regionp))
    (funcall cmd "")))))

(use-package consult-ag
  :ensure
  :defer
  :bind (:map projectile-command-map
          ("s s" . consult-ag)
          ("s g" . consult-grep)))

(use-package consult-org-roam
  :ensure t
  :after org-roam
  :init
  (require 'consult-org-roam)
  ;; Activate the minor mode
  (consult-org-roam-mode 1)
  :custom
  (consult-org-roam-grep-func #'consult-ag)
  ;; Configure a custom narrow key for `consult-buffer'
  (consult-org-roam-buffer-narrow-key ?r)
  ;; Display org-roam buffers right after non-org-roam buffers
  ;; in consult-buffer (and not down at the bottom)
  (consult-org-roam-buffer-after-buffers nil)
  :config
  ;; Eventually suppress previewing for certain functions
  (consult-customize
   consult-org-roam-forward-links
   :preview-key (kbd "M-.")))

(use-package marginalia
  :ensure
  :init
  ;; Must be in the :init section of use-package such that the mode gets
  ;; enabled right away. Note that this forces loading the package.
  (marginalia-mode))

(use-package embark
  :ensure t
  :defer
  :bind (("C-." . embark-act)))

(use-package embark-consult
  :ensure t
  :after embark)

(use-package dumb-jump
  :ensure t
  :defer
  :custom
  (dumb-jump-prefer-searcher 'ag)
  (dumb-jump-force-searcher 'ag)
  (dumb-jump-selector 'completing-read)
  (dumb-jump-default-project "~/work")
  :init
  (defun gopar-filename/xref-filename-backend ()
    "Xref backend for jumping to HTML template definitions."
    (when (and (thing-at-point 'filename t) (string-suffix-p ".html" (thing-at-point 'filename t)))
      'gopar-filename))

  (cl-defmethod xref-backend-identifier-at-point ((_backend (eql gopar-filename)))
    (thing-at-point 'filename t))

  (cl-defmethod xref-backend-definitions ((_backend (eql gopar-filename)) identifier)
    (let ((path (cl-find-if (lambda (x) (string-match-p identifier x))
                (projectile-project-files (projectile-project-root)))))
      (when path
    (list (xref-make identifier (xref-make-file-location (format "%s%s" (projectile-project-root) path) 1 0))))))

  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (add-hook 'xref-backend-functions #'gopar-filename/xref-filename-backend))

(use-package web-mode
  :ensure t
  :defer
  :init
  (setq-default web-mode-code-indent-offset 2)
  (setq web-mode-engines-alist '(("django"    . "\\.html\\'")))
  (setq web-mode-content-types-alist '(("jsx"  . "\\.js[x]?\\'")))

  :hook (web-mode . (lambda ()
              (highlight-indentation-mode -1)
              (electric-pair-local-mode -1)))
  :custom
  (web-mode-script-padding 0)
  (web-mode-enable-html-entities-fontification t)
  (web-mode-enable-element-content-fontification t)
  (web-mode-enable-current-element-highlight t)
  (web-mode-enable-current-column-highlight t)
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-sql-indent-offset 2)
  :mode (("\\.vue\\'" . web-mode)
     ("\\.html\\'" . web-mode)
     ("\\.js[x]?\\'" . web-mode)
     ))

(use-package emmet-mode
  :ensure t
  :defer t
  :config
  (defun emmet-jsx-supported-mode? ()
    "Is the current mode we're on enabled for jsx class attribute expansion?"
    (or (member major-mode emmet-jsx-major-modes)
    (and (string= major-mode "web-mode") (string= web-mode-content-type "jsx"))))
  :hook (web-mode . emmet-mode))

(use-package typescript-mode
  :ensure t
  :defer
  :bind (:map typescript-mode-map
          (";" . easy-camelcase))
  :custom
  (typescript-indent-level 2))

(use-package markdown-mode
  :defer t
  :ensure t
  :bind (:map markdown-mode-map
          ("M-." . dictionary-lookup-definition)))

(use-package dockerfile-mode
  :ensure t
  :defer)

(use-package docker
  :ensure t
  :defer
  :bind ("C-c d" . docker))

(use-package ledger-mode
  :ensure t
  :defer
  :mode ("\\.dat\\'"
     "\\.ledger\\'")
  :bind (:map ledger-mode-map
          ("C-c C-n" . ledger-navigate-next-uncleared)
          ("C-c C-b" . ledger-navigate-previous-uncleared))
  :custom
  (ledger-clear-whole-transactions t)
  (ledger-report-use-native-highlighting nil)
  (ledger-accounts-file (expand-file-name "~/personal/finances/data/accounts.dat")))

(use-package yaml-mode
  :ensure t
  :defer)

(use-package rainbow-mode
  :defer
  :ensure t
  :hook (prog-mode . rainbow-mode))

(use-package alert
  :ensure t
  :defer
  :custom
  (alert-default-style 'message)
  (alert-fade-time 5))

(use-package which-key
  :ensure t
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 2))

(use-package helpful
  :ensure t
  :defer
  :bind (("C-h f" . helpful-callable)
     ("C-h v" . helpful-variable)
     ("C-h k" . helpful-key)))

(use-package corral
  :ensure t
  :defer
  :bind (("M-9" . corral-parentheses-backward)
     ("M-0" . corral-parentheses-forward)
     ("M-[" . corral-brackets-backward)
     ("M-]" . corral-brackets-forward)
     ("M-\"" . corral-single-quotes-backward)
     ("M-'" . corral-single-quotes-forward)))

(use-package highlight-indentation
  :ensure t
  :defer
  :hook ((prog-mode . highlight-indentation-mode)
     (prog-mode . highlight-indentation-current-column-mode)))

(use-package hl-todo
  :ensure t
  :defer t
  :hook (prog-mode . hl-todo-mode))

(use-package move-text
  :ensure t
  :defer
  :init (move-text-default-bindings))

(use-package iedit
  :ensure t
  :defer
  :bind (("C-c o" . iedit-mode))
  :custom
  (iedit-toggle-key-default nil))

(use-package expand-region
  :ensure t
  :defer
  :bind (("C-\\" . er/expand-region)))

(use-package so-long
  :ensure nil
  :hook (after-init . global-so-long-mode))

(use-package avy
  :ensure t
  :defer
  :bind (("M-g c" . avy-goto-char-2)
     ("M-g g" . avy-goto-line)
     ("M-g w" . avy-goto-word-1)))

(use-package all-the-icons
  :ensure t
  :defer
  :if (display-graphic-p))

(use-package all-the-icons-completion
  :ensure t
  :defer
  :hook (marginalia-mode . #'all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

;; Ibuffer Icons sets it's own local buffer format and overrides the =ibuffer-formats= variable.
;; So in order for ibuffer-vc to work, i have to include it in the icons-buffer format -_-
(use-package all-the-icons-ibuffer
  :ensure t
  :defer
  :custom
  (all-the-icons-ibuffer-formats
   `((mark modified read-only locked vc-status-mini
       ;; Here you may adjust by replacing :right with :center or :left
       ;; According to taste, if you want the icon further from the name
       " " ,(if all-the-icons-ibuffer-icon
            '(icon 2 2 :left :elide)
          "")
       ,(if all-the-icons-ibuffer-icon
        (propertize " " 'display `(space :align-to 8))
          "")
       (name 18 18 :left :elide)
       " " (size-h 9 -1 :right)
       " " (mode+ 16 16 :left :elide)
       " " (vc-status 16 16 :left)
       " " vc-relative-file)
     (mark " " (name 16 -1) " " filename)))

  :hook (ibuffer-mode . all-the-icons-ibuffer-mode))

;; Quick recap of what =vc-status-mini=
;; https://github.com/purcell/ibuffer-vc/blob/master/ibuffer-vc.el#L204
(use-package ibuffer-vc
  :ensure t
  :hook (ibuffer . (lambda ()
             (ibuffer-vc-set-filter-groups-by-vc-root)
             (unless (eq ibuffer-sorting-mode 'alphabetic)
               (ibuffer-do-sort-by-vc-status)
               ;; (ibuffer-do-sort-by-alphabetic)
               )
             )))

(use-package webjump
  :defer
  :ensure nil
  :bind ("C-x /" . webjump)
  :config
  (setq webjump-sites
    '(("DuckDuckGo" . [simple-query "www.duckduckgo.com" "www.duckduckgo.com/?q=" ""])
      ("Google" . [simple-query "www.google.com" "www.google.com/search?q=" ""])
      ("YouTube" . [simple-query "www.youtube.com/feed/subscriptions" "www.youtube.com/results?search_query=" ""])
      ("CCBV" . [simple-query "https://ccbv.co.uk/" "https://ccbv.co.uk/" ""]))))

(use-package rfc-mode
  :defer
  :ensure t)

(use-package elec-pair
  :ensure nil
  :defer
  :hook (after-init . electric-pair-mode))

(use-package magit
  :ensure t
  :commands magit-get-current-branch
  :defer
  :bind ("C-x g" . magit)
  :hook (magit-mode . magit-wip-mode)
  :custom
  (magit-diff-refine-hunk 'all)
  (magit-process-finish-apply-ansi-colors t)
  :init
  (defun magit/undo-last-commit (number-of-commits)
    "Undoes the latest commit or commits without loosing changes"
    (interactive "P")
    (let ((num (if (numberp number-of-commits)
           number-of-commits
         1)))
      (magit-reset-soft (format "HEAD^%d" num)))))

;; Part of magit
(use-package git-commit
  :after magit
  :hook (git-commit-setup . gopar/auto-insert-jira-ticket-in-commit-msg)
  :custom
  (git-commit-summary-max-length 80)
  :init
  (defun gopar/auto-insert-jira-ticket-in-commit-msg ()
    (let ((has-ticket-title (string-match "^[A-Z]+-[0-9]+" (magit-get-current-branch)))
      (has-ss-ticket (string-match "^[A-Za-Z]+/[A-Z]+-[0-9]+" (magit-get-current-branch)))
      (words (s-split-words (magit-get-current-branch))))
      (if has-ticket-title
      (insert (format "[%s-%s] " (car words) (car (cdr words)))))
      (if has-ss-ticket
      (insert (format "[%s-%s] " (nth 1 words) (nth 2 words)))))))

(use-package git-gutter
  :ensure t
  :hook (after-init . global-git-gutter-mode))

(use-package paren
  :ensure nil
  :hook (after-init . show-paren-mode)
  :custom
  (show-paren-style 'mixed)
  (show-paren-context-when-offscreen t))

(use-package battery
  :ensure nil
  :hook (after-init . display-battery-mode))

;; After adding or updating a snippet run:
;; =M-x yas-recompile-all=
;; =M-x yas-reload-all=
(use-package yasnippet
  :ensure t
  :defer
  :hook ((prog-mode . yas-minor-mode)
     (org-mode . yas-minor-mode)
     (fundamental-mode . yas-minor-mode)
     (text-mode . yas-minor-mode)
     (after-init . yas-reload-all))
  :bind (:map yas-minor-mode-map
          ("C-c C-SPC" . yas-insert-snippet)))

(use-package yasnippet-snippets
  :ensure t
  :defer)

(use-package dashboard
  :ensure t
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-show-shortcuts nil)
  (dashboard-set-heading-icons t)
  (dashboard-icon-type 'all-the-icons)
  (dashboard-set-file-icons t)
  (dashboard-projects-backend 'projectile)
  ;; (dashboard-agenda-sort-strategy '(priority-down))
  (dashboard-items '(
             (vocabulary)
             (recents . 5)
             (bookmarks . 5)
             (projects . 5)
             (agenda . 5)
             ;; (monthly-balance)
             ))
  (dashboard-item-generators '(;; (monthly-balance . gopar/dashboard-ledger-monthly-balances)
                  (vocabulary . gopar/dashboard-insert-vocabulary)
                  (recents . dashboard-insert-recents)
                  (bookmarks . dashboard-insert-bookmarks)
                  (projects . dashboard-insert-projects)
                  (agenda . dashboard-insert-agenda)
                  (registers . dashboard-insert-registers)))
  :init
  (defun gopar/dashboard-insert-vocabulary (list-size)
    (dashboard-insert-heading "Word of the Day:"
                  nil
                  (all-the-icons-faicon "newspaper-o"
                            :height 1.2
                            :v-adjust 0.0
                            :face 'dashboard-heading))
    (insert "\n")
    (let ((random-line nil)
      (lines nil))
      (with-temp-buffer
    (insert-file-contents (concat user-emacs-directory "words"))
    (goto-char (point-min))
    (setq lines (split-string (buffer-string) "\n" t))
    (setq random-line (nth (random (length lines)) lines))
    (setq random-line (string-join (split-string random-line) " ")))
      (insert "    " random-line)))

  (defun gopar/dashboard-ledger-monthly-balances (list-size)
    (interactive)
    (dashboard-insert-heading "Monthly Balance:"
                  nil
                  (all-the-icons-faicon "money"
                            :height 1.2
                            :v-adjust 0.0
                            :face 'dashboard-heading))
    (insert "\n")
    (let* ((categories '("Expenses:Food:Restaurants"
             "Expenses:Food:Groceries"
             "Expenses:Misc"))
       (current-month (format-time-string "%Y/%m"))
       (journal-file (expand-file-name "~/personal/finances/main.dat"))
       (cmd (format "ledger bal --flat --monthly --period %s %s -f %s"
            current-month
            (mapconcat 'identity categories " ")
            journal-file)))

      (insert (shell-command-to-string cmd))))
  :config
  (dashboard-setup-startup-hook))

(use-package display-fill-column-indicator
  :ensure nil
  :hook (;; (python-mode . display-fill-column-indicator-mode)
     (org-mode . display-fill-column-indicator-mode))
  )

(use-package dired
  :ensure nil
  :defer
  :hook ((dired-mode . dired-hide-details-mode)
     (dired-mode . hl-line-mode))
  :custom
  (dired-do-revert-buffer t)
  (dired-auto-revert-buffer t)
  (delete-by-moving-to-trash t)
  (dired-mouse-drag-files t)
  (dired-dwim-target t)
  ;; (dired-guess-shell-alist-user)
  (dired-listing-switches "-AlhoF --group-directories-first"))

(use-package all-the-icons-dired
  :ensure t
  :defer
  :hook (dired-mode . all-the-icons-dired-mode)
  :custom
  (all-the-icons-dired-monochrome nil))

(use-package files
  :ensure nil
  :custom
  (insert-directory-program "gls") ; Will not work if system does not have GNU gls installed
  ;; Don't have backup
  (backup-inhibited t)
  ;; Don't save anything.
  (auto-save-default nil)
  ;; If file doesn't end with a newline on save, automatically add one.
  (require-final-newline t)
  :config
  (add-to-list 'auto-mode-alist '("Pipfile" . conf-toml-mode)))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
          ("<tab>" . dired-subtree-toggle)
          ("<C-tab>" . dired-subtree-cycle)
          ("<backtab>" . dired-subtree-remove) ;; Shift + Tab
          ))

(use-package replace
  :ensure nil
  :defer
  :hook (occur-mode . (lambda () (setq-local window-size-fixed 'width)))
  :custom
  (list-matching-lines-default-context-lines 0)
  :bind (("C-c C-o" . gopar/occur-definitions)
     ;; :map occur-mode-map
     ;; ("RET" . gopar/jump-to-defintion-and-kill-all-other-windows)
     ;; ("<C-return>" . occur-mode-goto-occurrence)
     )
  :init
  (add-to-list 'display-buffer-alist
           '("^\\*Occur\\*"
         display-buffer-in-side-window
         (side . left)
         (window-width . 40)))

  (defun gopar/occur-definitions ()
    "Show all the function/method/class definitions for the current language."
    (interactive)
    (cond
     ((eq major-mode 'emacs-lisp-mode)
      (occur "\(defun"))
     ((or (eq major-mode 'python-mode) (eq major-mode 'python-ts-mode))
      (occur "^\s*\\(\\(async\s\\|\\)def\\|class\\)\s"))
     ;; If no matching, then just do regular occur
     (t (call-interactively 'occur)))

    ;; Lets switch to that new occur buffer
    (let ((window (get-buffer-window "*Occur*")))
      (if window
      (select-window window)
    (switch-to-buffer "*Occur*"))))

  (defun gopar/jump-to-defintion-and-kill-all-other-windows ()
    (interactive)
    (occur-mode-goto-occurrence)
    (kill-buffer "*Occur*")
    (delete-other-windows)))

(use-package ansi-color
  :ensure nil
  :defer
  :hook (compilation-filter . gopar/colorize-compilation-buffer)
  :init
  (defun gopar/compilation-nuke-ansi-escapes ()
    (toggle-read-only)
    (gopar/nuke-ansi-escapes (point-min) (point-max))
    (toggle-read-only))

  ;; https://stackoverflow.com/questions/3072648/cucumbers-ansi-colors-messing-up-emacs-compilation-buffer
  (defun gopar/colorize-compilation-buffer ()
    "Colorize the output from compile buffer"
    (read-only-mode -1)
    (ansi-color-apply-on-region (point-min) (point-max))
    (read-only-mode 1)))

(use-package js
  :defer
  :bind (:map js-mode-map
          (";" . easy-camelcase)

          :map js-jsx-mode-map
          (";" . easy-camelcase))
  :custom
  (js-indent-level 2)
  (js-jsx-indent-level 2))

(use-package pulse
  :ensure nil
  :defer
  :init
  (defun pulse-line (&rest _)
    "Pulse the current line."
    (pulse-momentary-highlight-one-line (point)))

  (dolist (command '(scroll-up-command
             scroll-down-command
             windmove-left
             windmove-right
             windmove-up
             windmove-down
             move-to-window-line-top-bottom
             recenter-top-bottom
             other-window))
    (advice-add command :after #'pulse-line)))

(use-package mwheel
  :ensure nil
  :custom
  (mouse-wheel-tilt-scroll t)
  (mouse-wheel-scroll-amount-horizontal 2)
  (mouse-wheel-flip-direction t))

(use-package whitespace
  :ensure nil
  :defer
  :hook (before-save . whitespace-cleanup))

(use-package autorevert
  :ensure nil
  :custom
  ;; auto refresh files when changed from disk
  (global-auto-revert-mode t))

(use-package simple
  :ensure nil
  :defer
  :hook ((makefile-mode . indent-tabs-mode)
     (fundamental-mode . delete-selection-mode)
     (fundamental-mode . auto-fill-mode)
     (org-mode . auto-fill-mode))
  :custom
  (save-interprogram-paste-before-kill t)
  )

(use-package neotree
  :ensure t
  :bind ("<f5>" . neotree-toggle)
  :custom
  (neo-theme 'icons)
  (neo-smart-open t)
  (neo-autorefresh t)
  ;; takes too long to update on first try
  ;; (neo-vc-integration '(face char))
  (neo-show-hidden-files t))

(use-package dizzee
  :ensure t
  :defer
  :config
  (dz-defservice bfd-runserver "python"
         :args ("manage.py" "runserver")
         :cd "/Users/gopar/work/fiagents/")
  (dz-defservice bfd-flower "flower"
         :args ("-A" "core" "--host=127.0.0.1" "--port=9002")
         :cd "/Users/gopar/work/fiagents/")
  (dz-defservice bfd-bot-run "python"
         :args ("manage.py" "bot" "run")
         :cd "/Users/gopar/work/fiagents/")
  (dz-defservice bfd-celery-downloader-queue "celery"
         :args ("-A" "core" "worker" "-n" "Downloader" "-Q" "Downloader" "--concurrency=8" "--purge" "-l" "info")
         :cd "/Users/gopar/work/fiagents/")
  (dz-defservice bfd-celery-slow-downloader-queue "celery"
         :args ("-A" "core" "worker" "-n" "SlowDownloader" "-Q" "SlowDownloader" "--concurrency=2" "--purge" "-l" "info")
         :cd "/Users/gopar/work/fiagents/")
  (dz-defservice bfd-celery-diffbot-queue "celery"
         :args ("-A" "core" "worker" "-n" "Diffbot" "-Q" "Diffbot" "--concurrency=8" "--purge" "-l" "info")
         :cd "/Users/gopar/work/fiagents/")
  (dz-defservice bfd-celery-launcher-queue "celery"
         :args ("-A" "core" "worker" "-n" "Launcher" "-Q" "Launcher" "--concurrency=8" "--purge" "-l" "info")
         :cd "/Users/gopar/work/fiagents/")
  (dz-defservice-group bfd-celerys-flower-and-server (bfd-celery-diffbot-queue
                              bfd-celery-downloader-queue
                              bfd-celery-slow-downloader-queue
                              bfd-celery-launcher-queue
                              bfd-flower
                              bfd-runserver)))

(use-package string-inflection
  :ensure t
  :defer
  :commands string-inflection-insert
  :bind (("C-;" . gopar/string-inflection-cycle-auto))
  :init
  (defun gopar/string-inflection-cycle-auto ()
    "Switching by major mode."
    (interactive)
    (cond
     ((eq major-mode 'emacs-lisp-mode)
      (string-inflection-all-cycle))

     ((eq major-mode 'python-mode)
      (string-inflection-python-style-cycle))

     ((or (eq major-mode 'js-mode)
      (eq major-mode 'vue-mode)
      (eq major-mode 'java-mode)
      (eq major-mode 'typescript-mode))
      (string-inflection-java-style-cycle))

     ((eq major-mode 'nxml-mode)
      (string-inflection-java-style-cycle))

     ((eq major-mode 'hy-mode)
      (string-inflection-kebab-case))

     (t
      (string-inflection-ruby-style-cycle)))))

(use-package string-edit
  :ensure nil
  :defer
  :init
  (defun gopar/replace-str-at-point (new-str)
    (let ((bounds (bounds-of-thing-at-point 'string)))
      (when bounds
    (delete-region (car bounds) (cdr bounds))
    (insert new-str))))

  (defun gopar/edit-string-at-point ()
    (interactive)
    (let ((string (thing-at-point 'string t)))
      (string-edit "String at point:" string 'gopar/replace-str-at-point :abort-callback (lambda ()
             (exit-recursive-edit)
             (message "Aborted edit"))))))

(use-package compact-docstrings
  :ensure t
  :defer
  :hook (prog-mode . compact-docstrings-mode))

(use-package transient
  :ensure t
  :defer
  :bind ("C-M-o" . windows-transient-window)
  :init
  (transient-define-prefix windows-transient-window ()
   "Display a transient buffer showing useful window manipulation bindings."
    [["Resize"
     ("}" "h+" enlarge-window-horizontally :transient t)
     ("{" "h-" shrink-window-horizontally :transient t)
     ("^" "v+" enlarge-window :transient t)
     ("V" "v-" shrink-window :transient t)]
     ["Split"
    ("v" "vertical" (lambda ()
       (interactive)
       (split-window-right)
       (windmove-right)) :transient t)
    ("x" "horizontal" (lambda ()
       (interactive)
       (split-window-below)
       (windmove-down)) :transient t)
    ("wv" "win-vertical" (lambda ()
       (interactive)
       (select-window (split-window-right))
       (windows-transient-window)) :transient nil)
    ("wx" "win-horizontal" (lambda ()
       (interactive)
       (select-window (split-window-below))
       (windows-transient-window)) :transient nil)]
    ["Misc"
     ("B" "switch buffer" (lambda ()
                (interactive)
                (consult-buffer)
                (windows-transient-window)))
     ("z" "undo" (lambda ()
          (interactive)
          (winner-undo)
          (setq this-command 'winner-undo)) :transient t)
    ("Z" "redo" winner-redo :transient t)]]
    [["Move"
    ("h" "←" windmove-left :transient t)
    ("j" "↓" windmove-down :transient t)
    ("l" "→" windmove-right :transient t)
    ("k" "↑" windmove-up :transient t)]
    ["Swap"
    ("sh" "←" windmove-swap-states-left :transient t)
    ("sj" "↓" windmove-swap-states-down :transient t)
    ("sl" "→" windmove-swap-states-right :transient t)
    ("sk" "↑" windmove-swap-states-up :transient t)]
    ["Delete"
    ("dh" "←" windmove-delete-left :transient t)
    ("dj" "↓" windmove-delete-down :transient t)
    ("dl" "→" windmove-delete-right :transient t)
    ("dk" "↑" windmove-delete-up :transient t)
    ("D" "This" delete-window :transient t)]
    ["Transpose"
    ("tt" "↜" (lambda ()
        (interactive)
        (transpose-frame)
        (windows-transient-window)) :transient nil)
    ("ti" "↕" (lambda ()
        (interactive)
        (flip-frame)
        (windows-transient-window)) :transient nil)
    ("to" "⟷" (lambda ()
        (interactive)
        (flop-frame)
        (windows-transient-window)) :transient nil)
    ("tc" "⟳" (lambda ()
        (interactive)
        (rotate-frame-clockwise)
        (windows-transient-window)) :transient nil)
    ("ta" "⟲" (lambda ()
        (interactive)
        (rotate-frame-anticlockwise)
        (windows-transient-window)) :transient nil)]]))

(use-package transpose-frame :after transient :ensure t)

(use-package vterm
  :ensure t
  :defer
  :bind (:map vterm-mode-map
          ("<f6>" . vterm-toggle ))
  :custom
  (vterm-max-scrollback 100000))

(use-package vterm-toggle
  :ensure t
  :bind ("<f6>" . vterm-toggle )
  :custom
  (vterm-toggle-scope 'project)
  (vterm-toggle-project-root t)
  )

(use-package devdocs
  :ensure t
  :defer
  :bind ("C-c M-d" . gopar/devdocs-lookup)
  :init
  (add-to-list 'display-buffer-alist
           '("\\*devdocs\\*"
         display-buffer-in-side-window
         (side . right)
         (slot . 3)
         (window-parameters . ((no-delete-other-windows . t)))
         (dedicated . t)))

  (defun gopar/devdocs-lookup (&optional ask-docs)
    "Light wrapper around `devdocs-lookup` which pre-populates the function input with thing at point"
    (interactive "P")
    (let ((query (thing-at-point 'symbol t)))
      (devdocs-lookup ask-docs query)))


  :hook ((python-mode . (lambda () (setq-local devdocs-current-docs
                      '("django~4.2" "django_rest_framework" "python~3.11" "postgresql~11" "sqlite" "flask~3.0"))))
     (web-mode . (lambda () (setq-local devdocs-current-docs '("vue~3"
                                   "vue_router~4"
                                   "javascript"
                                   "typescript"
                                   "vitest"
                                   "moment"
                                   "tailwindcss"
                                   "html"
                                   "css"))))
     (typescript-mode . (lambda () (setq-local devdocs-current-docs '("vue~3"
                                      "vue_router~4"
                                      "javascript"
                                      "typescript"
                                      "vitest"
                                      "moment"))))))

(use-package link-hint
  :ensure t
  :defer)

(use-package flycheck
  :ensure
  :defer
  :hook ((python-mode . flycheck-mode))
  :bind (:map flycheck-mode-map
          ("C-c C-n" . flycheck-next-error)
          ("C-c C-p" . flycheck-previous-error))
  :custom
  (flycheck-flake8rc '(".flake8" "setup.cfg" "tox.ini" "pyproject.toml")))

(use-package chatgpt-shell
  :ensure t
  :commands (chatgpt-shell--primary-buffer chatgpt-shell chatgpt-shell-prompt-compose)
  :bind (("C-x m" . chatgpt-shell)
     ("C-c C-e" . chatgpt-shell-prompt-compose))
  :hook (chatgpt-shell-mode . (lambda () (setq-local completion-at-point-functions nil)))
  :init
  (setq shell-maker-history-path (concat user-emacs-directory "var/"))
  (add-to-list 'display-buffer-alist
           '("\\*chatgpt\\*"
         display-buffer-in-side-window
         (side . right)
         (slot . 0)
         (window-parameters . ((no-delete-other-windows . t)))
         (dedicated . t)))

  :bind (:map chatgpt-shell-mode-map
           (("RET" . newline)
           ("M-RET" . shell-maker-submit)
           ("M-." . dictionary-lookup-definition)))
  :custom
  (shell-maker-prompt-before-killing-buffer nil)
  (chatgpt-shell-openai-key
   (auth-source-pick-first-password :host "api.openai.com"))
  (chatgpt-shell-transmitted-context-length 5)
  (chatgpt-shell-model-versions '("gpt-4" "gpt-3.5-turbo-16k" "gpt-3.5-turbo"  "gpt-4-32k")))

(use-package dall-e-shell
  :ensure t
  :defer
  :bind (:map dall-e-shell-mode-map
           (("RET" . newline)
           ("M-RET" . shell-maker-submit)))
  :custom
  (dall-e-shell-openai-key
      (auth-source-pick-first-password :host "api.openai.com"))
  (dall-e-shell-image-size "1024x1024")
  (dall-e-shell-image-output-directory "~/Downloads/dall_e_output/"))

(use-package org-present
  :ensure t
  :defer
  :hook ((org-present-mode . gopar/org-present-start)
     (org-present-mode-quit . gopar/org-present-end))
  :config
  (defun gopar/org-present-start ()
    ; Tweak font sizes
    (setq-local face-remapping-alist '((default (:height 1.5) default)
                       (header-line (:height 4.0) header-line)
                       (org-document-title (:height 1.75) org-document-title)
                       (org-code org-verbatim)
                       (org-verbatim (:height 1.55) org-verbatim)
                       (org-block (:height 1.25) org-block)
                       (org-block-begin-line (:height 0.7) org-block)))

    ;; Set a blank header line string to create blank space at the top
    (setq header-line-format " ")

    ;; Display inline images automatically
    (org-display-inline-images)
    (visual-fill-column-mode 1)
    (visual-line-mode 1)
    (read-only-mode))

  (defun gopar/org-present-end ()
    ;; Reset font customizations
    (setq-local face-remapping-alist '((default variable-pitch default)))

    ;; Clear the header line string so that it isn't displayed
    (setq header-line-format nil)

    ;; Stop displaying inline images
    (org-remove-inline-images)
    (visual-fill-column-mode -1)
    (visual-line-mode -1)
    (read-only-mode -1))

  (defun my/org-present-prepare-slide (buffer-name heading)
    ;; Show only top-level headlines
    (org-overview)

    ;; Unfold the current entry
    (org-show-entry)

    ;; Show only direct subheadings of the slide but don't expand them
    (org-show-children))

  (add-hook 'org-present-after-navigate-functions 'my/org-present-prepare-slide))

(use-package visual-fill-column
  :ensure t
  :defer
  :custom
  (visual-fill-column-width 140)
  (visual-fill-column-center-text t))

(use-package spacious-padding
  :ensure t
  :defer
  :hook (after-init . spacious-padding-mode)
  )

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config (column-number-mode 1)
  :custom
  (doom-modeline-height 30)
  (doom-modeline-window-width-limit nil)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-minor-modes nil)
  (doom-modeline-enable-word-count nil)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-env-python-executable "python")
  ;; needs display-time-mode to be one
  (doom-modeline-time t)
  (doom-modeline-vcs-max-length 50)
  )

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
    doom-themes-enable-italic t) ; if nil, italics is universally disabled

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package leuven-theme
  :ensure t
  :custom-face
  (doom-modeline-buffer-file ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal))))
  (doom-modeline-buffer-path ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal))))
  (which-func ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal :foreground "gray29"))))
  (doom-modeline-buffer-major-mode ((t (:inherit (doom-modeline font-lock-doc-face) :weight normal :slant normal)))))

(use-package tao-theme
  :ensure t
  :custom
  (tao-theme-use-boxes t)
  (tao-theme-use-height nil)
  (tao-theme-use-sepia nil)
  :init
  (defvar after-load-theme-hook nil
    "Hook run after a color theme is loaded using `load-theme'.")

  (defadvice load-theme (after run-after-load-theme-hook activate)
    "Run `after-load-theme-hook'."
    (run-hooks 'after-load-theme-hook))

  (defun update-doom-modeline-battery-faces ()
  "Customize battery faces for tao-yin and tao-yang themes."
  (cond
   ((member 'tao-yin custom-enabled-themes)
    ;; Customizations for tao-yin theme
    (custom-set-faces
     '(doom-modeline-battery-warning ((t (:foreground "black" :background "orange"))))
     '(doom-modeline-battery-critical ((t (:foreground "black" :background "red"))))
     ))
   ((member 'tao-yang custom-enabled-themes)
    ;; Customizations for tao-yang theme
    (custom-set-faces
     '(doom-modeline-battery-warning ((t (:foreground "black" :background "orange"))))
     '(doom-modeline-battery-critical ((t (:foreground "black" :background "red"))))
     ))))

  (add-hook 'after-load-theme-hook 'update-doom-modeline-battery-faces))

(use-package stimmung-themes :ensure t)

(use-package eziam-themes :ensure t)

(use-package monochrome-theme :ensure t)

(use-package almost-mono-themes :ensure t)

(use-package sexy-monochrome-theme :ensure t)

(use-package grayscale-theme :ensure t)

(use-package adwaita-dark-theme :ensure t)

(use-package solaire-mode
  :ensure t
  :hook (after-init . solaire-global-mode))

(use-package fill-function-arguments
  :ensure t
  :defer
  :bind (:map prog-mode-map
          ("M-q" . fill-function-arguments-dwim)))

(use-package golden-ratio
  :ensure t
  :hook (after-init . golden-ratio-mode)
  :custom
  (golden-ratio-auto-scale t)
  (golden-ratio-exclude-modes '(treemacs-mode occur-mode chatgpt-shell-mode)))

(use-package ssh-config-mode
  :ensure t
  :defer)

(use-package auto-dark
  :ensure t
  :hook (after-init . auto-dark-mode)
  :init
  (setq auto-dark-dark-theme 'doom-dracula)
  (setq auto-dark-light-theme 'doom-solarized-light))

(use-package hide-mode-line
  :ensure t
  :defer
  :hook (;; (eshell-mode . hide-mode-line-mode)
     ;; (vterm-mode . hide-mode-line-mode)
     (occur-mode . hide-mode-line-mode)
     (treemacs-mode . hide-mode-line-mode)))

(use-package sqlite-mode
  :ensure nil
  :defer
  :bind (:map sqlite-mode-map
          ("n" . next-line)
          ("p" . previous-line)))

(use-package sql
  :ensure nil
  :defer
  :custom
  (sql-sqlite-options '("-header" "-box")))

(use-package keycast
  :ensure t
  :defer
  :custom
  (keycast-mode-line-format "%k%c%R ")
  (keycast-substitute-alist
   '((keycast-log-erase-buffer nil nil)
     (transient-update         nil nil)
     (self-insert-command "." "Typing…")
     (org-self-insert-command "." "Typing…")
     (mwheel-scroll nil nil)
     (mouse-movement-p nil nil)
     (mouse-event-p nil nil))))

(use-package gcmh
:ensure t
:hook (after-init . gcmh-mode)
:custom
(gc-cons-percentage .9))

(defvar gopar-pair-programming nil)
(defun gopar/pair-programming ()
  "Poor mans minor mode for setting up things that i like to make pair programming easier."
  (interactive)
  (if gopar-pair-programming
      (progn
    ;; Don't use global line numbers mode since it will turn on in other modes that arent programming
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (derived-mode-p 'prog-mode)
          (display-line-numbers-mode -1))))
    (remove-hook 'prog-mode-hook 'display-line-numbers-mode)

    ;; disable all themes change to a friendlier theme
    (mapcar 'disable-theme custom-enabled-themes)
    (setq gopar-pair-programming nil))

    (progn
      ;; display line numbers
      (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'prog-mode)
        (display-line-numbers-mode 1))))
      (add-hook 'prog-mode-hook 'display-line-numbers-mode)

      ;; disable all themes change to a friendlier theme
      (mapcar 'disable-theme custom-enabled-themes)
      (load-theme 'doom-shades-of-purple)
      (treemacs)
      (setq gopar-pair-programming t))))

(use-package boolcase
  :load-path "lisp/modes/boolcase"
  :hook (python-mode . boolcase-mode))

(defvar gopar/orginal-font-height nil)
(defvar gopar/youtube-font-height 220)
(defun gopar/youtube-setup ()
  (when (null gopar/orginal-font-height)
    (setq gopar/orginal-font-height (face-attribute 'default :height)))

  (set-face-attribute 'default nil :height gopar/youtube-font-height)

  (delete-other-windows)
  (display-time-mode -1)
  (type-break-mode -1)
  (keycast-header-line-mode)
  (let ((dashboard-items '((vocabulary) (bookmarks . 5))))
    (dashboard-open)))

(defun gopar/youtube-setup-emacs-goodies-series ()
  (interactive)
  (consult-theme 'doom-shades-of-purple)
  (gopar/youtube-setup))

(defun gopar/youtube-setup-python-series ()
  (interactive)
  (consult-theme 'doom-nord-aurora)
  (gopar/youtube-setup))

(defun gopar/youtube-setup-refactor-series ()
  (interactive)
  (consult-theme 'haki)
  (gopar/youtube-setup))

(defun gopar/youtube-setup-design-patterns-series ()
  (interactive)
  (consult-theme 'manoj-dark)
  (gopar/youtube-setup))

(progn
  (add-to-list 'default-frame-alist `(font . "Hack 20"))
  (set-face-attribute 'default nil :font "Hack 20"))


(use-package ox-hugo
  :ensure t)

;; global set key
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)

;; Guardar el histórico
(use-package savehist
  :init
  (savehist-mode))

;; Auto oackage update
(use-package auto-package-update
  :ensure t
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-delete-old-versions t)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

;; Corrector ortográfico
(use-package flyspell
  :config
  (setq ispell-program-name "hunspell"
        ispell-default-dictionary "es_MX")
  :hook (text-mode . flyspell-mode)
  :bind (("M-<f7>" . flyspell-buffer)
         ("<f7>" . flyspell-word)))

(use-package flyspell-correct
  :after (flyspell)
  :bind (("C-;" . flyspell-auto-correct-previous-word)
         ("<f7>" . flyspell-correct-wrapper)))

;; Autorevert
;; Recarga los archivos al ser modificados
(use-package autorevert
  :ensure nil
  :diminish
  :hook (after-init . global-auto-revert-mode))

;; Lectura Ebooks
;; nov modo principal para leer EPUBs en  Emacs
(use-package nov
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))
(use-package doc-view
  :custom
  (doc-view-resolution 300)
  (doc-view-mupdf-use-svg t)
  (large-file-warning-threshold (* 50 (expt 2 20))))

;; Lectura PDF
;; Emacs  puede mostrar archivos PDF con el modo principal DocView. Sin embargo, necesitas algún
;; software externo para que DocView funcione. GhostScript o MUPDF convierten archivos PDF en
;; imágenes y las proporcionan a DocView.
;; Si utilizas Emacs  29.1 o superior y tienes instalado MUPDF DocView convertirá las páginas PDF
;; en archivos SVG en lugar de archivos PNG, lo que proporciona una imagen más nítida y mejor para
;; hacer zoom a la imagen.
(use-package doc-view
  :custom
  (doc-view-resolution 300)
  (doc-view-mupdf-use-svg t)
  (large-file-warning-threshold (* 50 (expt 2 20))))

;; Visor de imágenes
(use-package emacs
  :bind
  ((:map image-mode-map
         ("k" . image-kill-buffer)
         ("<right>" . image-next-file)
         ("<left>"  . image-previous-file))
   (:map dired-mode-map
         ("C-<return>" . image-dired-dired-display-external))))


(with-eval-after-load 'ox-latex
(add-to-list 'org-latex-classes
             '("org-plain-latex"
               "\\documentclass{article}
           [NO-DEFAULT-PACKAGES]
           [PACKAGES]
           [EXTRA]"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

(setq org-latex-listings 't)

(with-eval-after-load 'org (global-org-modern-mode))


(setq org-preview-latex-process-alist
      '((dvipng :programs ("latex" "dvipng")
                :description "dvi > png"
                :message "You need to install the programs: latex and dvipng."
                :image-input-type "dvi"
                :image-output-type "png"
                :image-size-adjust (1.0 . 1.0)
                :latex-compiler ("latex -interaction nonstopmode -output-directory %o %f")
                :image-converter ("dvipng -D %D -T tight -o %o/%b.png %o/%b.dvi")))) ;; this is the only modified line

(defun my/org-latex-preview ()
  (let ((find-file-visit-truename t)
        (vc-follow-symlinks t))
    (org-latex-preview)))

(defun my/org-latex-preview-buffer ()
  (let ((find-file-visit-truename t)
        (vc-follow-symlinks t))
    (org-latex-preview-buffer)))

;; AucTeX
(use-package auctex
  :ensure t)

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debugging:
(defmacro print-args-and-ret (fun)
  "Prepare FUN for printing args and return value."
  `(advice-add (quote ,fun) :around
           (lambda (oldfun &rest args)
         (let ((ret (apply oldfun args)))
           (message ,(concat "Calling " (symbol-name fun) " with args %S returns %S.") args ret)
           ret))
           '((name "print-args-and-ret"))))

; (print-args-and-ret htmlize-faces-in-buffer)
; (print-args-and-ret htmlize-get-override-fstruct)
; (print-args-and-ret htmlize-face-to-fstruct)
; (print-args-and-ret htmlize-attrlist-to-fstruct)
; (print-args-and-ret face-foreground)
; (print-args-and-ret face-background)
; (print-args-and-ret face-attribute)
