;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/api/date.l
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
  (require "yaml-syck/util")
  )

(in-package :yaml-syck)

(defparameter syck-time-format-regexp-list
  '((:sec  "%S" "[0-9]\\{1,2\\}\\(?:\\.[0-9]+\\)?" 0)
    (:min  "%M" "[0-9]\\{1,2\\}" 0)
    (:hour "%H" "[0-9]\\{1,2\\}" 0)
    (:day  "%d" "[0-9]\\{2\\}"   0)
    (:mon  "%m" "[0-9]\\{2\\}"   1)
    (:year "%Y" "[0-9]\\{4\\}"   0)
    (:tz   "%z" "\\(?:[zZ]\\|[+-]?[0-9]\\{1,2\\}\\(?::[0-9]\\{2\\}\\)?\\)" nil) ;; Ç¢Ç¢â¡å∏ÉoÅ[ÉWÉáÉì
    ))


(defun syck-encode-iso8601 (lst)
  (format-date-string "%Y-%m-%dT%H:%M:%S%Z" (syck-encode-universal-time lst)))

(defun syck-encode-universal-time (lst)
  (when lst
    (apply #'encode-universal-time
           (mapcar #'(lambda (v)
                       (and v (floor v)))
                   (if (nth 6 lst)
                       (append (subseq lst 0 6) (list (- (nth 6 lst))))
                     lst)))))

(defun syck-encode-list (lst)
  lst)

(defun syck-parse-datetime (timestr regexp-n-groupname)
  (let ((re (first regexp-n-groupname))
        (group (second regexp-n-groupname)))
    (when (string-match re timestr)
      (mapcar #'(lambda (key)
                  (let* ((n (position key group))
                         (m (and n (match-string (1+ n)))))
                    (cond ((and m (eq key :tz))
                           (if (or (equal m "z") (equal m "Z"))
                               0
                             (let* ((hhmm (split-string m #\: 2))
                                    (hh (parse-integer (car hhmm)))
                                    (mm (and (cadr hhmm) (parse-integer (cadr hhmm)))))
                               (float (funcall (if (< hh 0) #'- #'+)
                                               hh
                                               (if mm (/ mm 60) 0))))))
                          (m
                           (read-from-string m))
                          (t
                           (fourth (assoc key syck-time-format-regexp-list))))))
              '(:sec :min :hour :day :mon :year :tz)))))

(defun syck-compile-date-format (fmt)
  (let (group)
    (list (gsub fmt "%."
                #'(lambda (m)
                    (let ((spec (rassoc m syck-time-format-regexp-list :test #'equal :key #'car)))
                      (unless spec
                        (plain-error (format nil "unknown escape sequence: ~S" m)))
                      (push (first spec) group)
                      (concat "\\(" (third spec) "\\)"))))
          (reverse group))))


(provide "yaml-syck/api/date")
