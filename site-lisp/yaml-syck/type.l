;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: yaml-syck/type.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   yaml-syck is released under an MIT license.
;;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;;

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/type/base")
  (require "yaml-syck/type/parser")
  )

(provide "yaml-syck/type")

;;;; End
