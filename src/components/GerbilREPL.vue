<template>
  <!-- <script src="/codemirror/lib/codemirror.js"></script> -->
  <!-- <script src="/codemirror/keymap/emacs.js"></script> -->

  <!-- <script src="UI.js"></script> -->
  <!-- <script src="VM.min.js"></script> -->
  <!-- <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script> -->
  <div>
  <!-- <link rel="stylesheet" href="/codemirror/lib/codemirror.css"> -->

  <!-- <link rel="stylesheet" href="/UI.css"> -->

  Foo? REPL?
    <div id="ui"></div>

    <pre>
    Keybindings:
      Enter  send the current line to the interpreter
      ^D     end-of-file when line is empty
      ^C     interrupt execution
      ^L     clear transcript
      ^P/^N  move back/forward in history
    </pre>
  </div>
</template>

<script>
// import BrowserFS from "browserfs"
// globalThis.BrowserFS = BrowserFS

import axios from 'axios';
globalThis.$axios = axios;

import UI from "gambit-scheme/UI.js"
import "gambit-scheme/UI.css"
globalThis.GambitUI = UI

const GerbilVM = globalThis.GerbilScheme
GerbilVM.runProcedure = '##repl-debug-main'
globalThis.GerbilVM = GerbilVM

export default {
  name: "GerbilREPL",
  mounted: function () {

    _os_uri_encode = function (uri) {

      function encode(c) {
        switch (c) {
        case '#': return '';
        default: return c;
        }
      }

      const pth = uri.split('').map(encode).join('');
     // console.warn('path', pth);
      return pth
    };
    GerbilVM.init(GambitUI, '#ui');
  }
}

</script>
