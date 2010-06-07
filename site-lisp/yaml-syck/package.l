;;; -*- mode: lisp; package: user -*-
;;;
;;; File: yaml-syck/package.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   yaml-syck is released under an MIT license.
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")

  (unless (find-package :yaml-syck-util)
    (defpackage :yaml-syck-util
      (:use
       :lisp
       )))

  (unless (find-package :yaml-syck-ffi)
    (defpackage :yaml-syck-ffi
      (:use
       :lisp :foreign
       :yaml-syck-util
       )))

  (unless (find-package :yaml-syck)
    (defpackage :yaml-syck
      (:use
       :lisp :editor
       :yaml-syck-util :yaml-syck-ffi
       ))))

(provide "yaml-syck/package")

;;; End
