(import :gloui/server :std/net/httpd :std/srfi/13)
(export #t)

(def public_html #f)

(def (static-file-directory)
  (or public_html (current-directory)))

(def (static-file-request? req)
  (def path (http-request-path req))
  (when (string=? path "/") (set! path "/index.html"))
  (let ((file (path-expand
         (string-copy path 1)
         (static-file-directory))))
    (if (not (file-exists? file)) #f (list file))))

(define-endpoint static-file (cut static-file-request? <>))

(def (static-file/GET path)
  (http-response-file (current-http-response) [] path))
