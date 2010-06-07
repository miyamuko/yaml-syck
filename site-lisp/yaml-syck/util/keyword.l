;;; -*- mode: lisp; package: yaml-syck-util -*-
;;;
;;; File: yaml-syck/util/keyword.l
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package"))

(in-package :yaml-syck-util)

(export '(parse-keyword-list
          ))

(defun parse-keyword-list (lst)
  (labels ((list->alist (lst)
             (if lst
                 (cons (cons (car lst) (cadr lst))
                       (list->alist (cddr lst)))
               nil)))
    (cond ((null lst)
           nil)
          ((oddp (length lst))
           (error (make-condition 'too-few-arguments :datum lst)))
          (t
           (list->alist lst)))))


(provide "yaml-syck/util/keyword")

;;; End
