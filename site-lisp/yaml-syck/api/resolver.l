;;; -*- mode: lisp; package: yaml-syck -*-
;;;
;;; File: yaml-syck/api/resolver.l
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
  (require "yaml-syck/ffi")
  (require "yaml-syck/api/node")
  )

(in-package :yaml-syck)


(defconstant *xyzzy-yaml-syck-badalias-type-id*
  "tag:xyzzy.yaml.org,2002:object:yaml-syck:badalias")

(defun syck-yaml->sexp (node)
  (values-list (append (syck-yaml->sexp0 node)
                       (list (SyckNode-id node)
                             (unpack-c-string (SyckNode-anchor node))))))

(defun syck-yaml->sexp0 (node)
  (if (and (unpack-c-string (SyckNode-anchor node))
           (string= (unpack-c-string (SyckNode-type-id node))
                    *xyzzy-yaml-syck-badalias-type-id*))
      (list :badalias (unpack-c-string (SyckNode-anchor node)))
    (case (syck-kind-tag-enum (SyckNode-kind node))
      (:syck-map-kind
       (list :map (syck-map->sexp node)))
      (:syck-seq-kind
       (list :sequence (syck-seq->sexp node)))
      (:syck-str-kind
       (list :scalar
             (cons (unpack-c-string (SyckNode-type-id node))
                   (syck-string->sexp node))))
      (t
       (raise-syck-runtime-error
        (format nil "unknown node: ~S" (SyckNode-kind node)))))))

(defun syck-string->sexp (node)
  (let ((str (make-SyckStr-chunk (SyckNode-data node))))
    (unpack-c-string (SyckStr-ptr str)
                     :size (SyckStr-length str))))

(defun syck-seq->sexp (node)
  (let ((seq (make-SyckSeq-chunk (SyckNode-data node))))
    (mapcar #'(lambda (i)
                (syck-seq-read node i))
            (generate-range 0 (SyckSeq-idx seq)))))

(defun syck-map->sexp (node)
  (let ((map (make-SyckMap-chunk (SyckNode-data node))))
    (mapcar #'(lambda (i)
                (cons (syck-map-read node :map-key i)
                      (syck-map-read node :map-value i)))
            (generate-range 0 (SyckMap-idx map)))))


(provide "yaml-syck/api/resolver")

;;; End
