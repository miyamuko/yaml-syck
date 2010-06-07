;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/loader.l
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
  (require "yaml-syck/util")
  (require "yaml-syck/api/parser")
  (require "yaml-syck/api/constructor")
  )

(in-package :yaml-syck)

(export '(syck-load
          syck-load-file
          syck-load-documents
          ))


(defun syck-load (str &rest options)
  (check-type str string)
  (syck-load-internal str
                      :option (process-parser-options options)
                      :porttype :string
                      :all nil))

(defun syck-load-file (filename &rest options)
  (check-type filename string)
  (syck-load-internal filename
                      :option (process-parser-options options)
                      :porttype :filename
                      :all nil))

(defun syck-load-documents (str-or-filename &key option callback (from :string))
  (check-type str-or-filename string)
  (syck-load-internal str-or-filename
                      :option (process-parser-options option)
                      :porttype from
                      :all t
                      :callback callback))

(defun syck-load-internal (port &key option porttype all callback)
  (check-type port string)
  (check-type porttype symbol)
  (if option
      (check-type option syck-parser-option)
    (setf option (make-syck-parser-option)))
  (with-syck-parser (parser option)
    (syck-setup-parser parser port option (syck-port-bind-fn porttype))
    (if (not all)
        (syck-load-internal0 parser)
      (let ((docs))
        (loop
          (let ((r (syck-load-internal0 parser)))
            (unless r (return))
            (if callback
                (funcall callback r)
              (push r docs))))
        (reverse docs)))))

(defun syck-load-internal0 (parser)
  (let ((rootid (syck-parse parser)))
    (cond ((syck-parser-context-get-exception parser)
           (error (syck-parser-context-get-exception parser)))
          ((syck-eof-p parser)
           nil)
          ((null rootid)
           (raise-syck-parse-error "parse error."))
          (t
           (syck-construct-sexp-from-symtbl
            parser
            rootid
            (syck-parser-context-get-symbol-table parser)
            (syck-parser-t-option parser))))))

(defun syck-port-bind-fn (porttype)
  (case porttype
    (:filename #'syck-parser-set-file)
    (:file #'syck-parser-set-file)
    (:string #'syck-parser-set-string)
    (t (raise-syck-argument-error
        (format nil "invalid porttype `~A' (or :filename :string)" porttype)))))

(defun syck-setup-parser (parser port option setupfn)
  (funcall setupfn parser port)
  (syck-parser-taguri-expansion parser t)
  (syck-parser-implicit-typing parser (syck-parser-option-implicit-typing-p option))
  (set-syck-node-handler #'syck-node-handler-impl)
  (set-syck-error-handler #'syck-error-handler-impl)
  (set-syck-bad-anchor-handler #'syck-bad-anchor-handler-impl))

(defun syck-node-handler-impl (parser node)
  (multiple-value-bind (type lvalue oldid anchor)
      (syck-yaml->sexp node)
    (let ((id (if (or (not oldid) (zerop oldid))
                  (syck-parser-context-next-symbol-id parser)
                oldid)))
      (syck-parser-context-put-anchor parser id anchor)
      (syck-parser-context-put-symbol parser id (cons type lvalue))
      id)))

(defun syck-error-handler-impl (parser msg)
  (syck-set-parse-error 'syck-parse-error parser msg)
  0)

(defun syck-bad-anchor-handler-impl (parser anchor)
  (let ((badanc (syck-new-map "name" anchor)))
    (setf (SyckNode-type-id badanc) (make-c-string *xyzzy-yaml-syck-badalias-type-id* :protect-gc t))
    badanc))

(defun syck-set-parse-error (condition parser msg)
  (let ((line (syck-current-line parser))
        (col (syck-current-column parser))
        (content (syck-current-content parser))
        (src (syck-source parser)))
    (syck-parser-context-set-exception
     parser
     (make-condition condition
                     :errmsg (format nil "~A at ~A, line ~D, column ~D."
                                     msg src line col)
                     :source src
                     :content content
                     :line line
                     :column col))))

(defun process-parser-options (options)
  (cond ((syck-parser-option-p options)
         options)
        ((syck-parser-option-p (car options))
         (car options))
        (t
         (check-parser-option options)
         (apply #'make-syck-parser-option options))))

(defun check-parser-option (options)
  (let ((slots (structure-slot-names 'syck-parser-option))
        (schema (syck-parser-option-schema)))
    (flet ((slot-member-p (opts)
             (member (car opts) slots))
           (restriction (opts)
             (cdr (assoc (car opts) schema)))
           (valid-value-p (opts restriction)
             (or (not restriction)
                 (member (cdr opts) restriction))))
    (dolist (opts (parse-keyword-list options))
      (unless (slot-member-p opts)
        (error (make-condition 'syck-argument-error
                               :errmsg (format nil "unknown option '~S':~%valid options are ~S"
                                               opts slots))))
      (unless (valid-value-p opts (restriction opts))
        (error (make-condition 'syck-argument-error
                               :errmsg (format nil "invalid option value '~S':~%valid values are ~S"
                                               opts (restriction opts)))))))))


(provide "yaml-syck/loader")

;;; End
