;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/api/parser.l
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
  (require "yaml-syck/type")
  (require "yaml-syck/ffi")
  (require "yaml-syck/api/handler")
  (require "yaml-syck/api/resolver")
  )

(in-package :yaml-syck)


;;;; macro

(defmacro with-syck-parser ((parser &optional option) &body body)
  `(let ((,parser (syck-new-parser ,option)))
     (unwind-protect
         (progn ,@body)
       (syck-free-parser ,parser)
       (free-protected-objects))))
(setf (get 'with-syck-parser 'ed:lisp-indent-hook) 'with-open-stream)


;;;; base

(defun syck-new-parser (option)
  (check-type option syck-parser-option)
  (let ((parser (%syck-new-parser)))
    (when (nullp parser)
      (raise-syck-runtime-error "cannot create syck parser"))
    (let ((r (make-syck-parser-t :ptr parser
                                 :option option)))
      (syck-install-handler-stub r)
      (syck-put-parser r)
      r)))

(defun syck-free-parser (parser)
  (check-syck-parser-t parser)
  (when (and (not (syck-parser-t-closed-p parser))
             (not (zerop (syck-parser-t-ptr parser))))
    (%syck-free-parser (syck-parser-t-ptr parser))
    (syck-finalize-parser parser))
  (setf (syck-parser-t-closed-p parser) t)
  (syck-remove-parser parser))

(defun syck-finalize-parser (parser)
  (when (syck-parser-t-finalizer parser)
    (funcall (syck-parser-t-finalizer parser))
    (setf (syck-parser-t-finalizer parser) nil)))

;;;; config

(defun syck-parser-implicit-typing (parser on)
  (check-syck-parser-t-must-be-open parser)
  (%syck-parser-implicit-typing (syck-parser-t-ptr parser)
                                (if on 1 0)))

(defun syck-parser-taguri-expansion (parser on)
  (check-syck-parser-t-must-be-open parser)
  (%syck-parser-taguri-expansion (syck-parser-t-ptr parser)
                                 (if on 1 0)))


;;;; parser

(defun syck-parser-set-file (parser filename &optional (reader 0))
  (when (nullp filename)
    (raise-syck-argument-error "input filename is nil"))
  (unless (file-exist-p filename)
    (error 'file-not-found :datum "file not found" :pathname filename))
  (let ((fh (fopen (make-c-string filename)
                   (make-c-string "r"))))
    (when (nullp fh)
      (error 'file-error :datum "cannot open file" :pathname filename))
    (%syck-parser-file (syck-parser-t-ptr parser)
                       fh
                       reader)
    (setf (syck-parser-t-port parser) (cons :file filename))
    (setf (syck-parser-t-finalizer parser)
          #'(lambda () (and fh (fclose fh))))))

(defun syck-parser-set-string (parser str &optional (reader 0))
  (check-syck-parser-t-must-be-open parser)
  (when (nullp str)
    (raise-syck-argument-error "input string is nil"))
  (let ((cstr (make-c-string str :protect-gc t)))
    (%syck-parser-str (syck-parser-t-ptr parser)
                      cstr
                      (si:chunk-size cstr)
                      reader)
    (setf (syck-parser-t-port parser) (cons :string str))))

(defun syck-parse (parser)
  (check-syck-parser-t-must-be-open parser)
  (unless (syck-parser-t-port parser)
    (raise-syck-runtime-error "port not bind"))
  (%syck-parse (syck-parser-t-ptr parser)))


;;;; accessor

(defun syck-source (parser)
  (let ((port (syck-parser-t-port parser)))
    (case (car port)
      (:string
       "(string)")
      (:file
       (cdr port))
      (t
       "(unknown)"))))

(defun syck-eof-p (parser)
  (check-syck-parser-t parser)
  (not (zerop (%xyck-eof (syck-parser-t-ptr parser)))))

(defun syck-current-content (parser)
  (check-syck-parser-t parser)
  (unpack-c-string (syck-lineptr parser)))

(defun syck-current-column (parser)
  (check-syck-parser-t parser)
  (- (syck-cursor parser)
     (syck-lineptr parser)))

(defun syck-current-line (parser)
  (check-syck-parser-t parser)
  (1+ (%xyck-linect (syck-parser-t-ptr parser))))

(defun syck-lineptr (parser)
  (check-syck-parser-t parser)
  (%xyck-lineptr (syck-parser-t-ptr parser)))

(defun syck-cursor (parser)
  (check-syck-parser-t parser)
  (%xyck-cursor (syck-parser-t-ptr parser)))


(provide "yaml-syck/api/parser")

;;; End
