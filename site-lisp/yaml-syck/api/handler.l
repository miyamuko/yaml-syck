;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/api/handler.l
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
  (require "yaml-syck/ffi")
  (require "yaml-syck/type")
  )

(in-package :yaml-syck)


(defun syck-install-handler-stub (parser)
  (check-syck-parser-t-must-be-open parser)
  (%syck-parser-handler (syck-parser-t-ptr parser)
                        #'syck-node-handler-c-callable)
  (%syck-parser-error-handler (syck-parser-t-ptr parser)
                              #'syck-error-handler-c-callable)
  (%syck-parser-bad-anchor-handler (syck-parser-t-ptr parser)
                                   #'syck-bad-anchor-handler-c-callable))

(defun set-syck-node-handler (fn)
  (check-type fn function)
  (set-syck-node-handler-c-callable-impl
   #'(lambda (parser-ptr node-ptr)
       (funcall fn
                (or (syck-get-parser parser-ptr)
                    (make-syck-parser-t :ptr parser-ptr))
                (make-SyckNode-chunk node-ptr)))))

(defun set-syck-error-handler (fn)
  (check-type fn function)
  (set-syck-error-handler-c-callable-impl
   #'(lambda (parser-ptr str)
       (funcall fn
                (or (syck-get-parser parser-ptr)
                    (make-syck-parser-t :ptr parser-ptr))
                str))))

(defun set-syck-bad-anchor-handler (fn)
  (check-type fn function)
  (set-syck-bad-anchor-handler-c-callable-impl
   #'(lambda (parser-ptr anchor)
       (funcall fn
                (or (syck-get-parser parser-ptr)
                    (make-syck-parser-t :ptr parser-ptr))
                anchor))))


(provide "yaml-syck/api/handler")

;;; End
