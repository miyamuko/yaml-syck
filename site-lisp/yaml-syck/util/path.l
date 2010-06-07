;;; -*- mode: lisp; package: yaml-syck-util -*-
;;;
;;; File: yaml-syck/util/path.l
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package"))

(in-package :yaml-syck-util)

(export '(relative-path-from
          ))

(defun path-join (path)
  (format nil "~{~A~^/~}" path))

(defun split-local-path (path &key include-file)
  (pathname-directory (if (or (equal "" (file-namestring path))
                              include-file)
                          (merge-pathnames "dummy" path)
                        path)))

(defun relative-path-from (from path)
  (labels ((make-relative-path-elems (from path)
             (append (make-list (length from) :initial-element "..")
                     path))
           (rec (from path)
             (if (and (car from) (car path)
                      (equalp (car from) (car path)))
                 (rec (cdr from) (cdr path))
               (path-join (make-relative-path-elems from path)))))
    (rec (split-local-path from :include-file nil)
         (split-local-path path :include-file t))))


(provide "yaml-syck/util/path")

;;; End
