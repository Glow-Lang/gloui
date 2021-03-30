(import :js)
(export #t define-entity)
(defsyntax (define-entity stx)
  (syntax-case stx ()
    ((macro (name self [supers ...] slots ...) defs ...)
     (let ((nm (syntax->datum #'name)))
       (with-syntax
           ((namestr (datum->syntax #'macro (symbol->string nm)))
            (namedef
             (datum->syntax
                 #'macro
               (string-append
                "const sup = (@1@);"
                "function " (symbol->string nm)
                " () { return sup.call(this, ...arguments) };"
                "const jso = (@2@); const slots = (@3@); const initJso = {};"
                "const pred = s => Object.keys(jso).includes(s);"
                "slots.forEach(s => { initJso[s] = (pred(s)) ? jso[s] : null });"
                                        ; "window.testEntity = { jso, slots }"
                "sup.create(" (symbol->string nm) ", initJso);"))))

       #'(begin
           (def name
             (let* ((sups (list supers ...))
                    (super
                     (cond ((null? sups) (js#js->foreign
                                          (js#expr "Entity")))
                           ((null? (cdr sups)) (car sups))
                           (else (let* ((mixsup (car sups)))
                                   (js#js->foreign
                                    (js#expr "((e, sups) => { return e.mix(...sups) })(@1@, @2@);"
                                             (js#scm->js mixsup)
                                             (js#scm->js sups)))))))
                    (jso (js#jso defs ...))
                    (sloties (map symbol->string '(slots ...))))
               (js#stmt namedef
                        (js#foreign->js super)
                        (js#scm->js jso)
                        (js#scm->js sloties))
               (js#js->foreign (js#expr namestr))))))))))
