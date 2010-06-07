;;; -*- mode: lisp; package: yaml-syck-ffi -*-
;;;
;;; File: yaml-syck/ffi/xyck.l
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
  (require "yaml-syck/ffi/macros")
  (require "yaml-syck/ffi/syck")
  )


(in-package :yaml-syck-ffi)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun xyck-map-c-function (name)
    (intern (concatenate 'string "%" (substitute #\- #\_ (string name))))))

(define-library define-xyck-api
                (xyck-dll)
                'xyck-map-c-function)


(define-xyck-api
 c:int
 xyck_yaml_major ())

(define-xyck-api
 c:int
 xyck_yaml_minor ())


(define-xyck-api
 c:char*
 xyck_version ())

(define-xyck-api
 c:char*
 xyck_yaml_domain ())


(define-xyck-api
 c:int
 xyck_eof ((SyckParser* parer)))

(define-xyck-api
 c:int
 xyck_linect ((SyckParser* parser)))

(define-xyck-api
 c:char*
 xyck_cursor ((SyckParser* parser)))

(define-xyck-api
 c:char*
 xyck_lineptr ((SyckParser* parser)))


(provide "yaml-syck/ffi/xyck")


;;; End
