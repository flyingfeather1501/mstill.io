#lang pollen
    Title: A newbie's attempt to explain lambdas
    Date: 2017-12-22T15:44:25
    Tags: category:Kisaragi, language:en, Programming

A lambda is a function.

A function is an ordinary value, just like numbers, lists, and characters.

Just like how a list can be created with `(list 'item 'item 'item)`, a function can be created with `(lambda (input) body-expr)`.

`(lambda (x y) (+ x y))` produces a function that takes two arguments and sends them to the + function. In a typical environment:

```
((lambda (x y) (+ x y)) 2 3)
; => 5
```

## Arguments
The way the argument list is given depends on the language. In Scheme-based languages, the first argument to lambda is:

- a list, each element in the list is bound to a local variable: `(lambda (x y) (+ x y))`
- an "improper list" (like `(a b . c)`) behaves like the above, but the last element is the rest argument, bound to a list containing arguments not bound by the positional arguments:`(lambda (a b . c) (string-append a b (string-join c)))`
- a symbol; it becomes the rest argument: `(lambda input (string-join input))`

## Binding to an identifier
`define` is used to assign an identifier to a value: `(define x 9)` binds `x` to 9. In the same way, `(define my-add (lambda (x y z) (+ x y z)))` binds `my-add` to the value `(lambda (x y z) (+ x y z))`. Now `my-add` can be used like the lambda itself.

```
((lambda (x y z) (+ x y z)) 1 2 3)
; => 6

(define my-add
  (lambda (x y z) (+ x y z)))
(my-add 1 2 3)
; => 6
```

## Shorthand for defining functions
`define` has a shorthand for creating functions:
```
(define my-add (lambda (x y) (+ x y)))
```
can be written as:
```
(define (my-add x y) (+ x y))
```