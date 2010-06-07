;;; -*- mode: lisp; package: yaml-syck-ffi -*-
;;;
;;; File: yaml-syck/ffi/util.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   yaml-syck is released under an MIT license.
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package"))

(in-package :yaml-syck-ffi)

(export '(unpack-c-string
          make-c-string
          ))

(defun make-c-string (lstr &key protect-gc)
  (let ((r (si:make-string-chunk lstr)))
    (protect-from-xyzzy-gc :string r)
    r))

(defun unpack-c-string (ptr &key (size 255) (zero-terminating-p t))
  (if (and ptr (not (zerop ptr)))
      (si:unpack-string (si:make-chunk nil size nil ptr)
                        0 size zero-terminating-p)
    nil))


(provide "yaml-syck/ffi/util")

;;; End
