;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/api/constructor.l
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package")
  (require "yaml-syck/conditions")
  (require "yaml-syck/api/convert")
  )

(in-package :yaml-syck)

(defstruct syck-recursive-alias
  symid)

(defun syck-construct-sexp-from-symtbl (parser rootid symtbl option)
  (let ((*parser* parser)
        (*option* option)
        (*mapcon* (syck-constructor-function-map option))
        (*seqcon* (syck-constructor-function-sequence option))
        (*anchor* (make-hash-table)))
    (declare (special *parser* *option* *mapcon* *seqcon* *anchor*))
    (let ((r (syck-build rootid symtbl '())))
      (compose! r *anchor*)
      r)))

(defun compose! (node symtbl)
  (macrolet ((replace-anchor! (place node symtbl)
               `(cond ((syck-recursive-alias-p ,place)
                       (setf ,place (gethash (syck-recursive-alias-symid ,place) ,symtbl)))
                      (t
                       (compose! ,place ,symtbl)))))
    (cond ((null node)
           )
          ((simple-vector-p node)
           (dotimes (i (length node))
             (replace-anchor! (aref node i) node symtbl)))
          ((hash-table-p node)
           (maphash #'(lambda (k v)
                        (replace-anchor! (gethash k node) node symtbl))
                    node))
          ((listp node)
           (replace-anchor! (car node) node symtbl)
           (replace-anchor! (cdr node) node symtbl)))))

(defun syck-build (symid symtbl parents)
  (if (find symid parents)
      (make-syck-recursive-alias :symid symid)
    (syck-build0 symid symtbl parents)))

(defun syck-build0 (symid symtbl parents)
  (let ((obj (syck-build1 symid symtbl parents)))
    (when (syck-parser-context-get-anchor *parser* symid)
      (setf (gethash symid *anchor*) obj))
    obj))

(defun syck-build1 (symid symtbl parents)
  (let ((obj (gethash symid symtbl)))
    (case (car obj)
      (:map
       (funcall *mapcon* obj symid symtbl parents))
      (:sequence
       (funcall *seqcon* obj symid symtbl parents))
      (:scalar
       (syck-convert (cadr obj) (cddr obj) *option*))
      (:badalias
       (raise-syck-bad-alias-error
        (format nil "found undefined alias `~A'." (cdr obj))))
      ((nil)
       (raise-syck-runtime-error "parse error (Internal error or Quit-ed)."))
      (t
       (raise-syck-runtime-error (format nil "[BUG] unknown node: ~S" obj))))))

(defun syck-symbol-type (symid symtbl)
  (car (gethash symid symtbl)))

(defun syck-symbol-value (symid symtbl)
  (cdr (gethash symid symtbl)))

(defun syck-construct-map-sexp (obj symid symtbl parents)
  (labels ((merge-map (lst)
             (reverse (uniq-by-key (reverse lst))))
           (uniq-by-key (lst)
             (cond ((null lst)
                    nil)
                   (t
                    (cons (car lst)
                          (uniq-by-key (remove (caar lst) lst
                                               :test #'equal :key #'car)))))))
    (syck-construct-map-hashtable0 obj symid symtbl parents
                                   :accumulator '()
                                   :setter #'(lambda (acc k v)
                                               (merge-map (append acc (list (cons k v)))))
                                   :merger #'(lambda (acc merge-value)
                                               (merge-map (append merge-value acc))))))

(defun syck-construct-map-hashtable (obj symid symtbl parents)
  (let ((r (make-hash-table :test (or (syck-parser-option-hash-table-test *option*)
                                      #'equal)
                            :size (length (cdr obj)))))
    (syck-construct-map-hashtable0 obj symid symtbl parents
                                   :accumulator r
                                   :setter #'(lambda (acc k v)
                                               (setf (gethash k acc) v)
                                               acc)
                                   :merger #'(lambda (acc merge-value)
                                               (maphash #'(lambda (kk vv)
                                                            (unless (hash-key-exist kk acc)
                                                              (setf (gethash kk acc) vv)))
                                                        merge-value)
                                               acc))
    r))

(defun syck-construct-map-hashtable0 (obj symid symtbl parents
                                          &key accumulator setter merger)
  (dolist (pair (cdr obj))
    (let ((k (syck-build (car pair) symtbl (cons symid parents)))
          (v (syck-build (cdr pair) symtbl (cons symid parents))))
      (case k
        ;; default は未サポート。
        (:default-key
         )
        (:merge-key
         (case (syck-symbol-type (cdr pair) symtbl)
           (:sequence
            (when (find-if #'(lambda (childtype)
                               (not (eq childtype :map)))
                           (syck-symbol-value (cdr pair) symtbl)
                           :key #'(lambda (e) (syck-symbol-type e symtbl)))
              (raise-syck-invalid-merge-node-error (format nil "~S" v)))
            (map 'list #'(lambda (e)
                           (setf accumulator (funcall merger accumulator e)))
                 v))
           (:map
            (setf accumulator (funcall merger accumulator v)))
           (t
            (raise-syck-invalid-merge-node-error (format nil "~S" v)))))
        (t
         (setf accumulator (funcall setter accumulator k v))))))
  accumulator)

(defun syck-construct-sequence-sexp (obj symid symtbl parents)
  (mapcar #'(lambda (id)
              (syck-build id symtbl (cons symid parents)))
          (cdr obj)))

(defun syck-construct-sequence-array (obj symid symtbl parents)
  (make-array (length (cdr obj))
              :initial-contents (syck-construct-sequence-sexp obj symid symtbl parents)))

(defun syck-constructor-function-sequence (option)
  (case (syck-parser-option-seq option)
    (:array
     'syck-construct-sequence-array)
    (t
     'syck-construct-sequence-sexp)))

(defun syck-constructor-function-map (option)
  (case (syck-parser-option-map option)
    (:hash-table
     'syck-construct-map-hashtable)
    (t
     'syck-construct-map-sexp)))


(provide "yaml-syck/api/constructor")

;;; End
