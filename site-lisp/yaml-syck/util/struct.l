;;; -*- mode: lisp; package: yaml-syck-util -*-
;;;
;;; File: yaml-syck/util/struct.l
;;;
;;;   Copyright (c) 2007-2008 MIYAMUKO Katsuyuki.
;;;
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package")
  (require "yaml-syck/util/sequence"))

(in-package :yaml-syck-util)

(export '(export-structure
          export-condition
          structure-slot-names
          ))

(defun structure-definition (structure)
  (let ((def (cond ((si:*structure-definition-p structure)
                    structure)
                   ((si:*structurep structure)
                    (si:*structure-definition structure))
                   ((symbolp structure)
                    (get structure 'si::structure-definition)))))
    (unless def
      (error 'type-error
             :datum structure
             :expected-type 'structure))
    def))

(defun structure-slot-names (structure)
  (let ((def (structure-definition structure)))
    (mapcar #'(lambda (i)
                (si:*structure-definition-slot-description def i))
            (generate-range 0 (si:*structure-definition-nslots def)))))

(defun structure-accessors (structure)
  (let* ((def (structure-definition structure))
         (name (si:*structure-definition-name def))
         (slots (structure-slot-names def)))
    (mapcar #'(lambda (slot)
                (intern (concatenate
                         'string (string name) "-" (string slot))))
            slots)))

(defun structure-description (structure)
  (let ((def (structure-definition structure)))
    (list
     (cons :name (si:*structure-definition-name def))
     (cons :constructors (si:*structure-definition-constructors def))
     (cons :accessors (structure-accessors def)))))

(defun export-structure (condition)
  (export-structure0 condition '(:name :accessors :constructors)))

(defun export-condition (condition)
  (export-structure0 condition '(:name :accessors)))

(defun export-structure0 (structure tags)
  (let ((desc (structure-description structure)))
    (dolist (tag tags)
      (let ((syms (cdr (assoc tag desc))))
        (when syms
          (export syms))))))


(provide "yaml-syck/util/struct")

;;; End
