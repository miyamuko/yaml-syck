;;; -*- mode: lisp; package: yaml-syck-ffi -*-
;;;
;;; File: yaml-syck/ffi/dll.l
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package")
  (require "yaml-syck/util")
  )

(in-package :yaml-syck-ffi)

(export '(syck-reload-dll
          syck-unload-dll
          ))

(defparameter *load-directory* (relative-path-from
                                (si:system-root)
                                (directory-namestring *load-pathname*)))

(defun syck-dll-path-for (filename)
  (merge-pathnames filename (merge-pathnames *load-directory* (si:system-root))))

(defun syck-dll ()
  (syck-dll-path-for "syck.dll"))

(defun xyck-dll ()
  (syck-dll-path-for "xyck.dll"))

(defun syck-reload-dll ()
  (syck-unload-dll)
  (load-library "yaml-syck/ffi/syck")
  (load-library "yaml-syck/ffi/xyck")
  (load-library "yaml-syck/ffi/msvcrt")
  (load-library "yaml-syck/ffi/callable")
  )

(defun syck-unload-dll ()
  (do-external-symbols (sym 'yaml-syck-ffi)
    (when (get sym 'dll-entry-point) ;; dll-entry-point => macros.l
      (fmakunbound sym)))
  (gc))


(provide "yaml-syck/ffi/dll")

;;; End
