;;; -*- mode: lisp; package: yaml-syck-ffi -*-
;;;
;;; File: yaml-syck/ffi/macros.l
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
  (require "yaml-syck/ffi/dll")
  (require "yaml-syck/ffi/memory")
  )

(in-package :yaml-syck-ffi)

(defmacro define-library (macroname dll &optional converter)
  `(progn
     (defmacro ,macroname (return-type export-name (&rest args-with-name))
       (let ((name (if ,converter
                       (funcall ,converter export-name)
                     export-name))
             (args (mapcar #'car args-with-name)))
         `(progn
            (c:*define-dll-entry ,return-type ,name ,args
              ,',dll ,(string export-name))
            (setf (get ',name 'dll-entry-point) t))))
     (setf (get ',macroname 'ed:lisp-indent-hook) 'defun)))

(defmacro define-chunk-maker (name)
  (let ((make (intern (format nil "make-~A-chunk" name)))
        (r (gensym)))
    `(progn
       (defun ,make (&optional source &key protect-gc)
         (let ((,r (si:make-chunk nil ,(c::ctypedef-size (c::expand-c-type name))
                                  nil source)))
           (protect-from-xyzzy-gc ',name ,r)
           ,r))
       (export '(,make)))))


(defun make-c-enum-helper (enum &optional (index 0))
  (let ((e (car enum)) (rst (cdr enum)))
    (cond ((null e) nil)
          ((symbolp e)
           (cons (cons e index) (make-c-enum-helper rst (1+ index))))
          ((and (listp e) (not (cdr e)))
           (cons (cons (car e) index) (make-c-enum-helper rst (1+ index))))
          ((and (listp e) (numberp (cadr e)))
           (cons e (make-c-enum-helper rst (1+ (cadr e)))))
          (t
           (error "不正な列挙体リストです。")))))

(defmacro define-c-enum (name &rest enum)
  (when (endp enum)
    (error "列挙体リストがありません: ~A" name))
  (let ((enum-fn (intern (concatenate 'string (string name) "-enum")))
        (name-fn (intern (concatenate 'string (string name) "-enum-name")))
        (value-fn (intern (concatenate 'string (string name) "-enum-value")))
        (list-fn (intern (concatenate 'string (string name) "-enum-list"))))
    `(progn
       (c:define-c-type c:int ,name)
       (setf (get ',name 'c-enum) ',(make-c-enum-helper enum))

       (defun ,enum-fn (&optional arg)
         (cond ((integerp arg)
                (,name-fn arg))
               ((keywordp arg)
                (,value-fn arg))
               (t
                (,list-fn))))
       (export ',enum-fn)

       (defun ,name-fn (value)
         (car (rassoc value (,enum-fn))))

       (defun ,value-fn (name)
         (cdr (assoc name (,enum-fn))))

       (defun ,list-fn ()
         (get ',name 'c-enum)))))
(setf (get 'define-c-enum 'ed:lisp-indent-hook) 'defstruct)


(provide "yaml-syck/ffi/macros")

;;;end
