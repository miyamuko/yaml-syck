;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/api/node.l
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
  (require "yaml-syck/ffi")
  )

(in-package :yaml-syck)


(defun syck-new-map (a b)
  (make-SyckNode-chunk
   (%syck-new-map (make-c-string a :protect-gc t)
                  (make-c-string a :protect-gc t))
   :protect-gc t))

(defun syck-map-read (node part index)
  (%syck-map-read (si:chunk-data node)
                  (map-part-enum part)
                  index))

(defun syck-seq-read (node index)
  (%syck-seq-read (si:chunk-data node)
                  index))


(provide "yaml-syck/api/node")

;;; End
