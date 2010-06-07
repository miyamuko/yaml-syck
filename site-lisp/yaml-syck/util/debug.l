;;; -*- mode: lisp; package: yaml-syck-util -*-
;;;
;;; File: yaml-syck/util/debug.l
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package"))

(in-package :yaml-syck-util)

(export '(hash-to-alist
          dump-hash))

;;;; debug

(defun hash-to-alist (hsh)
  (let (r)
    (maphash #'(lambda (x y)
                 (push (cons x y) r))
             hsh)
    (reverse r)))

(defun dump-hash (hsh)
  (let (r)
    (maphash #'(lambda (x y)
                 (push (format nil "~S = ~S" x y) r))
             hsh)
    (format nil "~{~A~%~}" (reverse r))))




(provide "yaml-syck/util/debug")

;;; End
