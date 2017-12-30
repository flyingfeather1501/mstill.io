#lang pollen
@; vim: filetype=scribble
@(local-require (only-in xml string->xexpr)
                txexpr threading racket/format racket/string)

@(struct tag-st (name url) #:transparent)

@(define (not-special? tag)
   ;; or here for adding more rules later
   (not (or (string-prefix? (tag-st-name tag) "language:"))))

@(define (taglist->comma-html taglist)
   ; listof tag-st -> string
   (~> (map (λ (x) (xexpr->html `(a ([href ,(tag-st-url x)]) ,(tag-st-name x))))
            taglist)
       (add-between _ ", ")
       (string-join _ "")))

@(define filtered-tags
   (~> (string-replace tags ", " "")
       string->xexpr
       get-elements ; strip away the top level span
       (filter txexpr? _) ; strip away the leftover newlines between each element
       (map (λ (x) (tag-st (last x) (attr-ref x 'href))) _)
       (filter not-special? _)
       taglist->comma-html
   ))

<article>
  <header class="post-header">
    <p class='date-and-tags'>@|date| :: @|filtered-tags|</p>
    <p class='title'><a href='@|full-uri|'>@|title|</a></p>
  </header>
  @|content|
  <footer>
    @twitter-share-button[full-uri]
    @google-plus-share-button[full-uri]
    @older/newer-links[older-uri older-title newer-uri newer-title]
    ◊google-adsense/responsive
    <br>
    @disqus-comments["kisaragi-hiu-blog"]
  </footer>
</article>
