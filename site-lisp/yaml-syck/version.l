;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/version.l
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

(export '(syck-xyzzy-binding-version
          syck-version
          syck-yaml-version
          syck-yaml-major-version
          syck-yaml-minor-version
          syck-yaml-domain
          ))

(defconstant *syck-xyzzy-binding-version* "0.1.0")

(defun syck-xyzzy-binding-version ()
  *syck-xyzzy-binding-version*)

(defun syck-version ()
  (unpack-c-string (%xyck-version)))

(defun syck-yaml-version ()
  (format nil "~A.~A"
          (syck-yaml-major-version)
          (syck-yaml-minor-version)))

(defun syck-yaml-major-version ()
  (%xyck-yaml-major))

(defun syck-yaml-minor-version ()
  (%xyck-yaml-minor))

(defun syck-yaml-domain ()
  (unpack-c-string (%xyck-yaml-domain)))


(provide "yaml-syck/version")

;;; End
