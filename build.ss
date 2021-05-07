#!/usr/bin/env gxi
;; -*- Gerbil -*-

(import :std/build-script :std/make :std/gambit-sharp)

(defbuild-script
  `("entity"
    "server/ftw" "server/json" "server/process"
    "server/identities" "server/contacts"
    "server/ethereum/network" "server/ethereum/balance"
    "server/ethereum/process"
    "server/ethereum/erc20"
    "server/ethereum"  "server/ethereum-networks" "server/erc20"
    "server"
    "file-server" "gloui"
    ))
