;;; -*- mode: lisp; package: yaml-syck-ffi -*-
;;;
;;; File: yaml-syck/ffi/callable.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   yaml-syck is released under an MIT license.
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package")
  (require "yaml-syck/ffi/syck")
  )

(in-package :yaml-syck-ffi)

(export '(syck-node-handler-c-callable
          syck-error-handler-c-callable
          syck-bad-anchor-handler-c-callable
          set-syck-node-handler-c-callable-impl
          set-syck-error-handler-c-callable-impl
          set-syck-bad-anchor-handler-c-callable-impl
          ))


(let (handler)
  (c:defun-c-callable
    SYMID
    syck-node-handler-c-callable ((SyckParser* parser-ptr)
                                  (SyckNode* node-ptr))
    (when (and handler (functionp handler))
      (funcall handler parser-ptr node-ptr)))

  (defun set-syck-node-handler-c-callable-impl (fn)
    (check-type fn function)
    (setf handler fn)))

(let (handler)
  (c:defun-c-callable
    c:void
    syck-error-handler-c-callable ((SyckParser* parser-ptr)
                                   (c:char* str))
    (when (and handler (functionp handler))
      (funcall handler parser-ptr (unpack-c-string str))))

  (defun set-syck-error-handler-c-callable-impl (fn)
    (check-type fn function)
    (setf handler fn)))

(let (handler)
  (c:defun-c-callable
    SyckNode*
    syck-bad-anchor-handler-c-callable ((SyckParser* parser-ptr)
                                        (c:char* anchor))
    (when (and handler (functionp handler))
      (funcall handler parser-ptr (unpack-c-string anchor))))

  (defun set-syck-bad-anchor-handler-c-callable-impl (fn)
    (check-type fn function)
    (setf handler fn)))


(provide "yaml-syck/ffi/callable")

;;; End
