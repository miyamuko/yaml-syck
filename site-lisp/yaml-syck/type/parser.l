;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/type/parser.l
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
  (require "yaml-syck/type/base")
  )

(in-package :yaml-syck)


;;;; parser context

(defstruct syck-parser-context
  (symbol-id 100)
  (symbol-table (make-hash-table))
  (anchor-table (make-hash-table))
  (exception nil)
  )

(defun syck-parser-context (parser-or-ctx)
  (let ((ctx (if (syck-parser-t-p parser-or-ctx)
                 (syck-parser-t-context parser-or-ctx)
               parser-or-ctx)))
    (check-type ctx syck-parser-context)
    ctx))


(defun syck-parser-context-next-symbol-id (parser-or-ctx)
  (let ((ctx (syck-parser-context parser-or-ctx)))
    (prog1
        (syck-parser-context-symbol-id ctx)
      (incf (syck-parser-context-symbol-id ctx)))))


(defun syck-parser-context-get-anchor-table (parser-or-ctx)
  (syck-parser-context-anchor-table (syck-parser-context parser-or-ctx)))

(defun syck-parser-context-get-anchor (parser-or-ctx id)
  (gethash id (syck-parser-context-anchor-table (syck-parser-context parser-or-ctx))))

(defun syck-parser-context-put-anchor (parser-or-ctx id value)
  (setf (gethash id (syck-parser-context-anchor-table (syck-parser-context parser-or-ctx)))
        value))


(defun syck-parser-context-get-symbol-table (parser-or-ctx)
  (syck-parser-context-symbol-table (syck-parser-context parser-or-ctx)))

(defun syck-parser-context-get-symbol (parser-or-ctx id)
  (gethash id (syck-parser-context-symbol-table (syck-parser-context parser-or-ctx))))

(defun syck-parser-context-put-symbol (parser-or-ctx id value)
  (setf (gethash id (syck-parser-context-symbol-table (syck-parser-context parser-or-ctx)))
        value))


(defun syck-parser-context-get-exception (parser-or-ctx)
  (syck-parser-context-exception (syck-parser-context parser-or-ctx)))

(defun syck-parser-context-set-exception (parser-or-ctx exception)
  (setf (syck-parser-context-exception (syck-parser-context parser-or-ctx)) exception))


;;;; parser option

(defstruct syck-parser-option
  (null nil)
  (true t)
  (false nil)
  (nan 0)
  (inf (symbol-value 'most-positive-long-float))
  (neginf (symbol-value 'most-negative-long-float))

  (seq :sexp)
  (map :sexp)
  (timestamp :universal-time)

  (hash-table-test #'equal)

  (implicit-keyword-p nil)
  (implicit-typing-p t)
  )
(export-structure 'syck-parser-option)

(defun syck-parser-option-schema ()
  '((:seq . (:sexp :array))
    (:map . (:sexp :hash-table))
    (:timestamp . (:sexp :universal-time :string :iso8601))))


;;;; parser

(define-c-pointer-wrapper syck-parser-t
  closed-p
  port
  finalizer
  (option (make-syck-parser-option))
  (context (make-syck-parser-context))
  )

(defun check-syck-parser-t-must-be-open (parser-t)
  (check-syck-parser-t parser-t)
  (when (syck-parser-t-closed-p parser-t)
    (raise-syck-runtime-error (format nil "parser already closed `~A'" parser-t))))


;;;; parser table

(defparameter *syck-parser-table* (make-hash-table))

(defun syck-get-parser (parser-ptr)
  (gethash parser-ptr *syck-parser-table*))

(defun syck-put-parser (parser)
  (check-syck-parser-t parser)
  (setf (gethash (syck-parser-t-ptr parser) *syck-parser-table*) parser))

(defun syck-remove-parser (parser)
  (check-syck-parser-t parser)
  (remhash (syck-parser-t-ptr parser) *syck-parser-table*))


(provide "yaml-syck/type/parser")

;;; End
