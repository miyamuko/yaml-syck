;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/api/convert.l
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
  (require "yaml-syck/version")
  (require "yaml-syck/util")
  (require "yaml-syck/api/date")
  )

(in-package :yaml-syck)

(defparameter *syck-yaml-tag* (concatenate 'string "tag:" (syck-yaml-domain) ":"))

(defparameter *syck-datatype-handler-alist*
  '(("null"              . syck-convert-null)
    ("bool#yes"          . syck-convert-bool#yes)
    ("bool#no"           . syck-convert-bool#no)
    ("int"               . syck-convert-int)
    ("int#hex"           . syck-convert-int#hex)
    ("int#oct"           . syck-convert-int#oct)
    ("int#base60"        . syck-convert-int#base60)
    ("float#fix"         . syck-convert-float)
    ("float#exp"         . syck-convert-float)
    ("float#base60"      . syck-convert-float#base60)
    ("float#nan"         . syck-convert-float#nan)
    ("float#inf"         . syck-convert-float#inf)
    ("float#neginf"      . syck-convert-float#neginf)
    ("timestamp"         . syck-convert-timestamp)
    ("timestamp#iso8601" . syck-convert-timestamp#iso8601)
    ("timestamp#spaced"  . syck-convert-timestamp#spaced)
    ("timestamp#ymd"     . syck-convert-timestamp#ymd)
    ("str"               . syck-convert-str)
    ("merge"             . syck-convert-merge)
    ("default"           . syck-convert-default)
    ("binary"            . syck-convert-binary)
    ))


(defun syck-convert (type value option)
  (when (start-with *syck-yaml-tag* type)
    (setf type (subseq type (length *syck-yaml-tag*))))
  (let ((c (assoc type *syck-datatype-handler-alist* :test #'equal)))
    (if c
        (funcall (cdr c) value option)
      (syck-convert-str value option))))

(defun syck-convert-null (value option)
  (syck-parser-option-null option))

(defun syck-convert-bool#yes (value option)
  (syck-parser-option-true option))

(defun syck-convert-bool#no (value option)
  (syck-parser-option-false option))


(defun syck-convert-base60 (converter value option)
  (flet ((split-colon (v)
           (ed::split-string value #\:)))
    (reduce #'(lambda (acc e)
                (+ (* acc 60) e))
            (mapcar #'(lambda (e) (funcall converter e option)) (split-colon value))
            :initial-value 0)))

(defun syck-convert-int (value option &key (radix 10))
  (parse-integer (remove #\, value) :radix radix))

(defun syck-convert-int#oct (value option)
  (syck-convert-int value option :radix 8))

(defun syck-convert-int#hex (value option)
  (syck-convert-int value option :radix 16))

(defun syck-convert-int#base60 (value option)
  (syck-convert-base60 #'syck-convert-int value option))

(defun syck-convert-float (value option)
  (read-from-string (remove #\, value)))

(defun syck-convert-float#base60 (value option)
  (syck-convert-base60 #'syck-convert-float value option))

(defun syck-convert-float#nan (value option)
  (syck-parser-option-nan option))

(defun syck-convert-float#inf (value option)
  (syck-parser-option-inf option))

(defun syck-convert-float#neginf (value option)
  (syck-parser-option-neginf option))


;; canonical:        2001-12-15T02:59:43.1Z
(defparameter *syck-timestamp-pattern* (syck-compile-date-format "%Y-%m-%d[tT]%H:%M:%S%z?"))

;; valid iso8601:    2001-12-14t21:59:43.10-05:00
(defparameter *syck-timestamp#iso8601-pattern* *syck-timestamp-pattern*)

;; space separated:  2001-12-14 21:59:43.10 -05
;; no time zone (Z): 2001-12-15 2:59:43.10
(defparameter *syck-timestamp#spaced-pattern* (syck-compile-date-format "%Y-%m-%d %H:%M:%S\\(?: %z\\)?"))

;; date (00:00:00Z): 2002-12-14
(defparameter *syck-timestamp#ymd-pattern* (syck-compile-date-format "%Y-%m-%d%z?"))

(defun syck-convert-timestamp0 (value pattern option)
  (if (eq (syck-parser-option-timestamp option) :string)
      (copy-seq value)
    (funcall
     (case (syck-parser-option-timestamp option)
       (:sexp
        #'syck-encode-list)
       (:universal-time
        #'syck-encode-universal-time)
       (:iso8601
        #'syck-encode-iso8601)
       (t
        #'syck-encode-universal-time))
     (syck-parse-datetime value pattern))))

(defun syck-convert-timestamp (value option)
  (syck-convert-timestamp0 value *syck-timestamp-pattern* option))

(defun syck-convert-timestamp#iso8601 (value option)
  (syck-convert-timestamp0 value *syck-timestamp#iso8601-pattern* option))

(defun syck-convert-timestamp#spaced (value option)
  (syck-convert-timestamp0 value *syck-timestamp#spaced-pattern* option))

(defun syck-convert-timestamp#ymd (value option)
  (syck-convert-timestamp0 value *syck-timestamp#ymd-pattern* option))


(defun syck-convert-str (value option)
  (if (and (syck-parser-option-implicit-typing-p option)
           (syck-parser-option-implicit-keyword-p option)
           (start-with ":" value))
      (intern (subseq value 1) :keyword)
    (copy-seq value)))

(defun syck-convert-merge (value option)
  :merge-key)

(defun syck-convert-default (value option)
  :default-key)

(defun syck-convert-binary (value option)
  (si:base64-decode value))


(provide "yaml-syck/api/convert")
