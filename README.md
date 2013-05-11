Racket FFI bindings for libaosd
===============================

FFI bindings to [libaosd](https://github.com/atheme/libaosd) to allow
manipulation of the [on-screen display](http://en.wikipedia.org/wiki/On-screen_display).

For example, try something like the following:

```racket
#lang racket

(require aosd plot)

(with-aosd 0 0 300 300
  (λ (dc)
    (plot/dc (vector-field
              (λ (x y) (vector (+ x y) (- x y)))
              -2 2 -2 2)
     dc 0 0 300 300)))

(sleep 5)
```

---

Copyright (c) 2013 Asumu Takikawa

Licensed under the MIT license.

