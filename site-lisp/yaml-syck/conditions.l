;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/conditions.l
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
  (require "yaml-syck/util")
  )

(in-package :yaml-syck)

(define-condition syck-simple-error (simple-error)
  (errmsg)
  (:report (lambda (c s)
             (format s "yaml-syck: error: ~A"
                     (syck-simple-error-errmsg c)))))
(export-condition 'syck-simple-error)

(defmacro define-syck-error ((name base) msg &rest slots)
  (let ((raise (intern (format nil "raise-~A" (string name))))
        (errmsg (intern (format nil "~A-errmsg" (string name)))))
    `(progn
       (define-condition ,name (,base)
         (,@slots)
         (:report (lambda (c s)
                    (format s "yaml-syck: ~A: ~A"
                            ,msg (,errmsg c)))))

       (defun ,raise (msg)
         (error (make-condition ',name :errmsg msg)))

       (export-condition ',name))))

(setf (get 'define-syck-error 'ed:lisp-indent-hook) 'defun)

(define-syck-error (syck-runtime-error syck-simple-error)
  "runtime error")

(define-syck-error (syck-argument-error syck-simple-error)
  "argument error")

(define-syck-error (syck-parse-error syck-simple-error)
  "parse error"
  source line column content)

(define-syck-error (syck-compose-error syck-simple-error)
  "compose error")

(define-syck-error (syck-bad-alias-error syck-compose-error)
  "bad alias error")

(define-syck-error (syck-invalid-merge-node-error syck-compose-error)
  "invalid merge node, expected a mapping or list of mappings")


(provide "yaml-syck/conditions")

;;; End
