;;; -*- mode: lisp;package: yaml-syck-ffi -*-
;;;
;;; File: yaml-syck/ffi/msvcrt.l
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
  )

(in-package :yaml-syck-ffi)

(define-library define-msvcrt-api
                "msvcrt")

(c:*define-c-type c:void* FILE*)

(define-msvcrt-api
 FILE*
 fopen ((c:char* filename)
        (c:char* mode)))

(define-msvcrt-api
 c:void
 fclose ((FILE* file)))


(provide "yaml-syck/ffi/msvcrt")

;;;end
