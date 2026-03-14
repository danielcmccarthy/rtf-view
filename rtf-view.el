;;; rtf-view.el --- View Rich Text Format files -*- lexical-binding: t; -*-

;; Author: Dan McCarthy <daniel.c.mccarthy@gmail.com>
;; URL: https://github.com/danielcmccarthy/rtf-view.git
;; Keywords: files data
;; Package-Version: 1.0
;; Package-Requires: ((emacs "24.1"))
;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;; Display RTF documents in all of their formatted glory. Editing isn't possible yet.
;;
;; Requires GNU unrtf.

;;; Todo:
;; * keep source in a data buffer
;; * set background color?

(require 'shr)

;;; Code:

(defcustom rtf-view-unrtf-executable
  "unrtf"
  "Path to the unrtf executable used by `rtf-view'."
  :type '(string)
  :group 'rtf-view)

;;;###autoload
(defun rtf-view ()
  "Format the current buffer as an RTF document."
  (interactive)
  (unless (locate-file rtf-view-unrtf-executable exec-path)
    (error  "Could not find %s" rtf-view-unrtf-executable))
  (message "Formatting %s with unrtf..." (buffer-name))
  (let ((inhibit-read-only t)
        ;; Run unrtf in a temp directory so it doesn't create files
        ;; (e.g. extracted pictures) in the source file's directory.
        (default-directory temporary-file-directory))
    (shell-command-on-region (point-min)
                             (point-max)
                             (format "%s --nopict" rtf-view-unrtf-executable)
                             t
                             t)
    (let ((dom (libxml-parse-html-region (point-min)
                                         (point-max))))
      (erase-buffer)
      (shr-insert-document dom)
      (goto-char (point-min))))
  (set-buffer-modified-p nil)
  (setq buffer-read-only t))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.rtf\\'" . rtf-view))

(provide 'rtf-view)

;;; rtf-view.el ends here
