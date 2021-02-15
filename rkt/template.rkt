#lang racket

(provide script-analytics)

;; emit javascript for analytics on my own fathom instance
;; https://github.com/usefathom/fathom
(define (script-analytics id)
  `(script
    ,(format
      "
let dnt = navigator.doNotTrack || navigator.msDoNotTrack || null;
if (dnt !== \"yes\" && dnt !== \"1\") {
  (function (f, a, t, h, o, m) {
    a[h] =
      a[h] ||
      function () {
        (a[h].q = a[h].q || []).push(arguments);
      };
    (o = f.createElement(\"script\")),
      (m = f.getElementsByTagName(\"script\")[0]);
    o.async = 1;
    o.src = t;
    o.id = \"fathom-script\";
    m.parentNode.insertBefore(o, m);
  })(document, window, \"//fathom.kisaragi-hiu.com/tracker.js\", \"fathom\");
  fathom(\"set\", \"siteId\", \"~a\");
  fathom(\"trackPageview\");
}"
      id)))