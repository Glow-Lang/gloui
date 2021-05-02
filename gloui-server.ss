#!/usr/bin/env gxi
(import :mukn/gloui/gloui)
(start-server!)
(displayln "started GloUI Server")

(import :std/logger)
(std/logger#current-logger #f)
(def error-log-port (open-string))

(start-logger! error-log-port)

(def (string<-error-log-port (p error-log-port))
  (get-output-string p))

(import :drewc/gerbil-swank :std/sugar)

(def my-swank #f)

(def (swank-thread p)
  (let ((init-port-num p))
    (let stsw ((p init-port-num))
      (displayln "Trying swank on port " p "\n>")
      (try
       (set! my-swank (start-swank p))
       (catch (e)
         (displayln "error " (display-exception e))
         (if (< num (+ init-port-num 10))
           (stsw (+ 1 p))
           (display e))))))

  (display "here"))


(def (gloui-swank (port 4006))
  (thread-start! (make-thread (cut swank-thread port))))

; (gloui-swank)
;(_gx#gxi-init-interactive! "")

;(##repl-debug-main)
