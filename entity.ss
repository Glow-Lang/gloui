(import :clan/poo/mop :clan/poo/object :clan/poo/brace
        :std/text/json :std/sugar #;(for-syntax :std/gambit-sharp))
(export #t)
;; (declare (extended-bindings))
;; (include "~~lib/_gambit#.scm")

;; (macro-case-target
;;  ((js) (import :js))
;;  (else

(def (json<-entity e (t e))
  (call-with-output-string
   (cut write-json-alist (.entity-alist e t) <>)))

(def (entity<-json entity-type json)
  (def js (cond ((hash-table? json) json)
                ((string? json)
                 (with-input-from-string json (cut read-json)))
                (else (error "Not JSON:" json))))
  (def no (gensym))
  (def (jsref js ref)
    (let ((obj (hash-ref js ref no)))
      (if (not (eq? no obj)) obj
          (hash-ref js (symbol->string ref) #!void))))

  (.mix (object<-alist (map (lambda (s) (cons s (jsref js s)))
                            (.entity-slots entity-type)))
        entity-type))

(.def (Entity @ [])
  .entitySlots: '()
  .json<-: (cut json<-entity <> @)
  .<-json: (cut entity<-json @ <>)
  .new: (cut .mix <> @))

(def (.new-entity e (obj (.o))) ((.@ e .new) obj))
(def (.entity-slots e) (.@ e .entitySlots))

(def (prependEntitySlotLists x y) (append y x))

(defsyntax (define-entity stx)
  (syntax-case stx ()
    ((_ (name self [supers ...] slots ...) defs ...)
     #'(define-type (name self [supers ... Entity] slots ...)
         (.entitySlots => prependEntitySlotLists '(slots ...))
         defs ...))))

(defsyntax (.entity stx)
  (syntax-case stx ()
    ((_ name slots ...)
     #'(.o (:: @ name) slots ...))))

(def (.entity-alist e (entity-type e))
  (map (lambda (slot) (cons slot (try (.ref e slot) (catch (e) #!void))))
                  (.@ entity-type .entitySlots)))
;;))
