;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: yaml-syck/ffi.l
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
  (require "yaml-syck/ffi/macros")
  (require "yaml-syck/ffi/memory")
  (require "yaml-syck/ffi/util")
  (require "yaml-syck/ffi/dll")
  (require "yaml-syck/ffi/callable")
  (require "yaml-syck/ffi/msvcrt")
  (require "yaml-syck/ffi/syck")
  (require "yaml-syck/ffi/xyck")
  )

(provide "yaml-syck/ffi")

;;;; End
