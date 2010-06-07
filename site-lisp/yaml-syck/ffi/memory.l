;;;; -*- mode: lisp; package: yaml-syck-ffi -*-
;;;;
;;;; File: yaml-syck/ffi/memory.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   yaml-syck is released under an MIT license.
;;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package")
  )

(in-package :yaml-syck-ffi)

(export '(free-protected-objects
          protect-from-xyzzy-gc
          ))

(defparameter *protect-objects* nil)

(defun protect-from-xyzzy-gc (type obj)
  (push (cons obj type) *protect-objects*))

(defun free-protected-objects ()
  (setf *protect-objects* nil)
  (gc))


(provide "yaml-syck/ffi/memory")

;;;; End
