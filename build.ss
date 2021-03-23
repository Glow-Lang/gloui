#!/usr/bin/env gxi
;; -*- Gerbil -*-

(import :std/build-script)

(defbuild-script
  '("server/ftw" "server/json" "server/process"
    "server/identities" "server/contacts"
    "server/ethereum-networks" "server/erc20"
    "server"
    "file-server" "gloui"))
