;;; -*- mode: lisp; package: yaml-syck-util -*-
;;;
;;; File: yaml-syck/util/string.l
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package"))

(in-package :yaml-syck-util)
(use-package :editor)

(export '(gsub
          ))

(defun gsub (str re fn)
  (when (and re str)
    (let ((result))
      (labels ((gsub-internal (re str fn start)
                 (if (string-match re str start)
                     (progn
                       (push (substring str start (match-beginning 0)) result)
                       (if fn (push (funcall fn (match-string 0)) result))
                       (gsub-internal re str fn (match-end 0)))
                   (push (substring str start) result))))
        (gsub-internal re str fn 0))
      (format nil "~{~A~}" (reverse result)))))


(provide "yaml-syck/util/string")

;;; End
