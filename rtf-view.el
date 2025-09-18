;;; rtf-view.el --- View Rich Text Format files -*- lexical-binding: t; -*-

;; Author: Dan McCarthy <daniel.c.mccarthy@gmail.com>
;; Keywords: files data
;; Package-Version: 1.0

;;; Commentary:
;; Display RTF documents in all of their formatted glory. Editing isn't possible yet.
;;
;; Requires GNU unrtf.

;;; Todo:
;; * keep source in a data buffer
;; * set background color?

(require 'shr)

;;; Code:

(defcustom rtf-unrtf-executable
  "unrtf"
  "Path to the unrtf executable used by `rtf-view'."
  :type '(string)
  :group 'rtf-view)

(defun rtf-view ()
  "Format the current buffer as an RTF document."
  (interactive)
  (unless (locate-file rtf-unrtf-executable exec-path)
    (error  "Could not find %s" rtf-unrtf-executable))
  (message "Formatting %s with unrtf..." (buffer-name))
  (shell-command-on-region (point-min)
                           (point-max)
                           (format "%s --nopict" rtf-unrtf-executable)
                           t
                           t)
  (let ((dom (libxml-parse-html-region (point-min)
                                       (point-max))))
    (erase-buffer)
    (shr-insert-document dom)
    (goto-char (point-min))))

(add-to-list 'auto-mode-alist '("\\.rtf\\'" . rtf-view))

(provide 'rtf-view)

;;; rtf-view.el ends here
