;;; -*- mode: lisp; package: yaml-syck-ffi -*-
;;;
;;; File: yaml-syck/ffi/syck.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   yaml-syck is released under an MIT license.
;;;   See yaml-syck/docs/MIT-LICENSE for full license.
;;;


(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "yaml-syck/package")
  (require "yaml-syck/ffi/macros")
  (require "yaml-syck/ffi/util")
  (require "yaml-syck/ffi/msvcrt")
  )


(in-package :yaml-syck-ffi)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun syck-map-c-function (name)
    (intern (concatenate 'string "%" (substitute #\- #\_ (string name))))))

(define-library define-syck-api
                (syck-dll)
                'syck-map-c-function)

(c:*define-c-type c:u_long SYMID)
(c:*define-c-type (SYMID *) SYMID*)
(c:*define-c-type c:long st_data_t)


(define-c-enum syck-kind-tag
  :syck-map-kind
  :syck-seq-kind
  :syck-str-kind)

(define-c-enum map-part
  :map-key
  :map-value)

(define-c-enum map-style
  :map-none
  :map-inline)

(define-c-enum seq-style
  :seq-none
  :seq-inline)

(define-c-enum scalar-style
  :scalar-none
  :scalar-1quote
  :scalar-2quote
  :scalar-fold
  :scalar-literal
  :scalar-plain)


(c:*define-c-struct SyckNode
  (SYMID id)
  (syck-kind-tag kind)
  (c:char* type-id)
  (c:char* anchor)
  (c:void* data)
  (c:void* shortcut))

(c:*define-c-struct SyckStr
  (scalar-style style)
  (c:char* ptr)
  (c:int length))

(c:*define-c-struct SyckMap
  (map-style style)
  (SYMID* keys)
  (SYMID* values)
  (c:long capa)
  (c:long idx))

(c:*define-c-struct SyckSeq
  (seq-style style)
  (SYMID* items)
  (c:long capa)
  (c:long idx))

(define-chunk-maker SyckNode)
(define-chunk-maker SyckStr)
(define-chunk-maker SyckMap)
(define-chunk-maker SyckSeq)

(c:*define-c-type (SyckNode *) SyckNode*)
(c:*define-c-type (SyckStr *) SyckStr*)
(c:*define-c-type (SyckMap *) SyckMap*)
(c:*define-c-type (SyckSeq *) SyckSeq*)

(c:*define-c-type c:void* SyckParser*)
(c:*define-c-type c:void* SyckEmitter*)
(c:*define-c-type c:void* st-data-t)

(c:*define-c-type c:void* SyckNodeHandler)
(c:*define-c-type c:void* SyckErrorHandler)
(c:*define-c-type c:void* SyckBadAnchorHandler)
(c:*define-c-type c:void* SyckOutputHandler)
(c:*define-c-type c:void* SyckEmitterHandler)

(c:*define-c-type c:void* SyckIoFileRead)
(c:*define-c-type c:void* SyckIoStrRead)


;;;; === Node API ===

(define-syck-api
  SyckNode*
  syck_alloc_str ())

(define-syck-api
  SyckNode*
  syck_alloc_seq ())

(define-syck-api
  SyckNode*
  syck_alloc_str ())

(define-syck-api
  c:void
  syck_free_node ((SyckNode* n)))

(define-syck-api
  SyckNode*
  syck_new_str ((c:char* str)
                (scalar-style style)))

(define-syck-api
  SyckNode*
  syck_new_str2 ((c:char* str)
                 (c:long len)
                 (scalar-style style)))

(define-syck-api
  c:void
  syck_replace_str ((SyckNode* n)
                    (c:char* str)
                    (scalar-style style)))

(define-syck-api
  c:void
  syck_replace_str2 ((SyckNode* n)
                     (c:char* str)
                     (c:long len)
                     (scalar-style style)))

(define-syck-api
  c:char*
  syck_str_read ((SyckNode* n)))

(define-syck-api
  SyckNode*
  syck_new_map ((SYMID key)
                (SYMID value)))

(define-syck-api
  c:void
  syck_map_empty ((SyckNode* n)))

(define-syck-api
  c:void
  syck_map_add ((SyckNode* n)
                (SYMID key)
                (SYMID value)))

(define-syck-api
  SYMID
  syck_map_read ((SyckNode* n)
                 (map-part p)
                 (c:long index)))

(define-syck-api
  c:void
  syck_map_assign ((SyckNode* n)
                   (map-part p)
                   (c:long index)
                   (SYMID id)))

(define-syck-api
  c:long
  syck_map_count ((SyckNode* n)))

(define-syck-api
  c:void
  syck_map_update ((SyckNode* n)
                   (SyckNode* n2)))

(define-syck-api
  SyckNode*
  syck_new_seq ((SYMID val)))

(define-syck-api
  c:void
  syck_seq_empty ((SyckNode* n)))

(define-syck-api
  c:void
  syck_seq_add ((SyckNode* n)
                (SYMID val)))

(define-syck-api
  c:void
  syck_seq_assign ((SyckNode* n)
                   (c:long index)
                   (SYMID val)))

(define-syck-api
  SYMID
  syck_seq_read ((SyckNode* n)
                 (c:long index)))

(define-syck-api
  c:long
  syck_seq_count ((SyckNode* n)))


;;;; === Parser API ===

(define-syck-api
  SyckParser*
  syck_new_parser ())

(define-syck-api
  c:void
  syck_free_parser ((SyckParser* p)))

(define-syck-api
  c:void
  syck_parser_implicit_typing ((SyckParser* p)
                               (c:int on)))

(define-syck-api
  c:void
  syck_parser_taguri_expansion ((SyckParser* p)
                                (c:int on)))

(define-syck-api
  c:void
  syck_parser_handler ((SyckParser* p)
                       (SyckNodeHandler h)))

(define-syck-api
  c:void
  syck_parser_error_handler ((SyckParser* p)
                             (SyckErrorHandler h)))

(define-syck-api
  c:void
  syck_parser_bad_anchor_handler ((SyckParser* p)
                                  (SyckBadAnchorHandler h)))

(define-syck-api
  c:void
  syck_parser_file ((SyckParser* p)
                    (FILE* f)
                    (SyckIoFileRead r)))

(define-syck-api
  c:void
  syck_parser_str ((SyckParser* p)
                   (c:char* ptr)
                   (c:long len)
                   (SyckIoStrRead r)))

(define-syck-api
  c:void
  syck_parser_str_auto ((SyckParser* p)
                        (c:char* ptr)
                        (SyckIoStrRead r)))

(define-syck-api
  SYMID
  syck_parse ((SyckParser* p)))


;;;; === Emitter API ===

(define-syck-api
  SyckEmitter*
  syck_new_emitter ())

(define-syck-api
  SYMID
  syck_emitter_mark_node ((SyckEmitter* e)
                          (st-data-t node)))

(define-syck-api
  c:void
  syck_output_handler ((SyckEmitter* e)
                       (SyckOutputHandler out)))

(define-syck-api
  c:void
  syck_emitter_handler ((SyckEmitter* e)
                        (SyckEmitterHandler h)))

(define-syck-api
  c:void
  syck_free_emitter ())


(provide "yaml-syck/ffi/syck")

;;; End
