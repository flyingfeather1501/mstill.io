#lang rackjure
(require xml
         pollen/template/html
         txexpr
         "define-txexpr.rkt")

(provide (all-defined-out))

;;; widgets

(define/txexpr (link url [text url]
                     #:class [class ""]
                     #:target [target "_self"])
  `(a ([href ,url]
       [target ,target]
       [class ,class])
    ,text))

(define/txexpr (dropdown #:button-id button-id
                         #:button-extra-classes button-extra-classes
                         #:button-label button-label
                         .
                         elements)
  `(div ([class "dropdown"])
        (a ([class ,(~a "btn dropdown-toggle " button-extra-classes)]
            [href "#"]
            [role "button"]
            [id ,button-id]
            [data-toggle "dropdown"]
            [aria-haspopup "true"]
            [aria-expanded "false"])
           ,button-label)
        ;; add attrs to each element, then put them in a dropdown-menu div
        ,(~> (map
              (lambda (tx)
                (attr-set* tx 'class "dropdown-item" 'aria-labelledby button-id))
              elements)
             (txexpr 'div '([class "dropdown-menu"]) _))))


(define/txexpr (project url title description)
  `(li ([class "project"])
       (a ([class "project-link"]
           [href ,url])
          (p ([class "project-title"])
             ,title
             nbsp)
          (p ([class "project-description"])
             ,description))))

(define/txexpr (collapse #:button-classes button-classes
                         #:button-label button-label
                         #:div-id div-id
                         #:div-extra-classes [div-extra-classes ""]
                         .
                         elements)
  `(div (div (a ([class ,button-classes]
                 [data-toggle "collapse"]
                 [href ,(~a "#" div-id)]
                 [role "button"]
                 [aria-expanded "false"]
                 [aria-controls ,div-id])
                ,button-label))
        (div ([class ,(~a "collapse " div-extra-classes)]
              [id ,div-id])
             ,@elements)))

(define/txexpr (collapse-button #:button-class [button-class ""]
                                #:div-id [div-id ""]
                                .
                                elements)
  `(div (a ([class ,button-class]
            [data-toggle "collapse"]
            [href ,(~a "#" div-id)]
            [role "button"]
            [aria-expanded "false"]
            [aria-controls ,div-id])
           ,@elements)))

(define/txexpr (strike . text)
  `(s ,@text))

(define/txexpr (stylized-item text)
  (txexpr* 'div '()
           `(span ([style "font-weight: 700;"]) ,text)
           `(hr ([style
                     ,(string-append "height: 1px;"
                                     "width: 6rem;"
                                     "margin: 0.3rem auto 1.2rem;"
                                     "text-align: left;"
                                     "margin-right: 100%;"
                                     "background-color: #444;")]))))

(define/txexpr (rant . text)
  `(span ([style "color: #777;"]) "(" ,@text ")"))

(define/txexpr (image src [caption #f] #:width [width #f] #:class [class ""])
  (define image-style "max-width:100%;")
  (when width
    (set! image-style (~a image-style "width:" width ";")))
  `(div (img ([src ,src] [style ,image-style] [class ,class]))
        ,(if caption
             `(p ([class "image-caption"]) ,caption)
             "")))

(define/txexpr (R text ruby) `(ruby ,text (rt ,ruby)))

(define/txexpr (table . elements)
  `(table ,@elements))

(define (newline-decode . elements)
  (string-join
   (map (λ (x) (cond
                  [(not (string? x)) x]
                  [(regexp-match #rx"\n\n+" x)
                   (string-replace x #rx"\n\n+" "\n\n")]
                  [(regexp-match #rx">\n+" x) ">\n"
                   (string-replace x #rx">\n+" ">\n")]
                  [(regexp-match #rx"\n" x) "<br>\n"
                   (string-replace x #rx"\n" "<br>\n")]
                  [else x]))
        elements)
   ""))

(define/txexpr (video/gif-esque path #:controls? [controls? #f] . caption)
  ;; ignore caption for now
  (let ([result `(video ([autoplay "autoplay"]
                         [style "max-width: 100%;"]
                         [muted "muted"]
                         [loop "loop"]
                         [src ,path]))])
    (if controls?
        (attr-set result 'controls "")
        result)))

(define/txexpr (kbd . elements)
  `(kbd ,@elements))

(define/txexpr (youtube/embed video-id
                              #:class [class "ytembed-default"]
                              #:style [style ""])
  `(p ([class ,class]
       [style ,style])
      (iframe ([id "ytplayer"]
               [type "text/html"]
               [width "640"]
               [height "360"]
               [style "position: absolute;
                       top: 0;
                       left: 0;
                       width: 100%;
                       height: 100%;"]
               [src ,(string-append
                      "https://www.youtube.com/embed/"
                      video-id
                      "?autoplay=0"
                      "&origin="
                      "https://kisaragi-hiu.com")]
               [frameborder "0"]))))

(define/txexpr (youtube/image-link video-id #:class [class ""])
  (link #:return-txexpr? #t
        #:class (format "ytimglink ~a" class)
        (~a "https://youtu.be/" video-id)
        (image #:return-txexpr? #t
               (format "https://img.youtube.com/vi/~a/maxresdefault.jpg"
                       video-id))))

(define global-translation-dict
  {"Kisaragi Hiu"
   {'ja "如月飛羽"
    'zh "如月飛羽"
    'en "Kisaragi Hiu"}
   "Contact:"
   {'ja "連絡："
    'zh "聯絡："
    'en "Contact:"}})

(define (translate #:translation-dict [translation-dict global-translation-dict]
                   .
                   strings)
  (define str (string-join strings ""))
  (~> (translation-dict str) 'en))

(define ! translate)

;;; Link functions

(define/txexpr (image/link url src caption)
  `(div
     ,(link #:return-txexpr? #t url
            (image src #:return-txexpr? #t))
     (p ([class "image-caption"]) ,caption)))

(define/txexpr (link/date url date . text)
  `(p ,(string-append date " ")
      ,(link #:return-txexpr? #t url (string-join text))))

(define-syntax (define-link stx)
  (syntax-case stx ()
    [(_ linkname url-prefix)
     #'(begin
         (define/txexpr (linkname suburl [text suburl] #:class [class ""])
           (link (string-append url-prefix suburl)
                 text
                 #:class class
                 #:return-txexpr? #t)))]))

(define-link github "https://github.com/")
(define-link gitlab "https://gitlab.com/")
(define-link twitter "https://twitter.com/")
(define-link youtube "https://youtube.com/")
(define-link pixiv "https://pixiv.net/")
(define-link niconico "http://www.nicovideo.jp/")
(define-link osuwiki "http://osu.ppy.sh/help/wiki/")
(define-link transifex "https://www.transifex.com/user/profile/")
(define-link noichigo "https://www.no-ichigo.jp/read/book/book_id/")
(define-link site-crossref "https://kisaragi-hiu.com/")