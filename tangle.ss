#!/usr/bin/env gxi
(import :std/misc/process)
  ;; # Change to where this file lives
  ;;  cd "$(dirname "$0")"

(def srcdir (path-normalize (path-directory (this-source-file))))

(def source-of-source
  '("README.org"
    ;;"doc/log/0000-Getting-Started.org"
    ;;"doc/log/0001-Static-File-Server.org"
    "doc/gerbil.org"
    "doc/ftw.org"
    "doc/process.org"
    "doc/json.org"
    "doc/identities.org"
    "doc/contacts.org"
    "doc/ethereum-networks.org"
    "doc/erc20.org"
    "doc/widgets.org"))

;; # Use Emacs to tangle the files.
;;    tangle() {
;;        emacs --batch -l org --eval "(org-babel-tangle-file \"$1\")"
;;    }

(def (tangle srcdir file)
  (display
   (run-process ["emacs" "--batch" "-l" "org" "--eval"
                 (string-append" (print (org-babel-tangle-file \""file"\"))")]
                directory: srcdir)))

;; # Tangle the files!

(for-each (cut tangle srcdir <>) source-of-source)
