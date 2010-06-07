;;; -*- mode: lisp; package: yaml-syck-util -*-
;;;
;;; File: yaml-syck/util/sequence.l
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package"))

(in-package :yaml-syck-util)

(export '(singlep
          doublep
          dotp
          group
          generate-range
          start-with))

(defun singlep (lst)
  (and (consp lst) (not (cdr lst))))

(defun doublep (lst)
  (and (consp lst)
       (consp (cdr lst))
       (not (cddr lst))))

(defun dotp (lst)
  (and (consp lst) (atom (cdr lst))))

(defun group (lst n)
  (labels ((group0 (lst)
             (let ((rst (nthcdr n lst)))
               (if rst
                   (append (list (subseq lst 0 n)) (group0 rst))
                 (list lst)))))
    (group0 lst)))

(defun generate-range (start end &optional (step 1))
  (let ((result))
    (do ((i start (+ i step)))
        ((not (< i end)))
      (push i result))
    (nreverse result)))

(defun start-with (subseq seq &key (test #'equal))
  (and (<= (length subseq) (length seq))
       (funcall test subseq (subseq seq 0 (length subseq)))))


(provide "yaml-syck/util/sequence")

;;; End
