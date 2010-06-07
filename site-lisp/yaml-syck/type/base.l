;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/type/base.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   yaml-syck is released under an MIT license.
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package")
  (require "yaml-syck/conditions")
  (require "yaml-syck/ffi"))

(in-package :yaml-syck)


(defstruct c-pointer-wrapper
  ptr)

(defmacro define-c-pointer-wrapper (name &rest rest)
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (defstruct (,name
                 (:include c-pointer-wrapper))
       ,@rest)
     (defun ,(intern (format nil "check-~A" name)) (arg)
       (check-type arg ,name))))
(setf (get 'define-c-pointer-wrapper 'ed:lisp-indent-hook) 'defstruct)


(defun nullp (p)
  (or (null p)
      (and (numberp p) (zerop p))))


(provide "yaml-syck/type/base")

;;; End
