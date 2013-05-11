#lang racket/base

(require "aosd.rkt"
         racket/class
         racket/contract
         racket/draw/private/dc
         racket/draw/private/local
         racket/draw/unsafe/cairo
         ffi/unsafe/atomic
         x11/x11
         (for-syntax racket/base
                     syntax/parse))

(provide aosd%
         (contract-out
          [with-aosd
           (-> real? real? real? real?
               (-> (is-a?/c aosd-dc%) any)
               any)]))

(define-syntax (init-private stx)
  (syntax-parse stx
    [(_ fld ...)
     (with-syntax ([(_internal ...) (generate-temporaries #'(fld ...))])
       #'(begin (init ([_internal fld]) ...)
                (define fld _internal) ...))]))

(define aosd%
  (class object%
    (init-private callback dx dy width height)
    (super-new)
    (define aosd (aosd_new))

    (define/public (draw)
      (aosd_set_renderer
         aosd
         (λ (cairo_t _)
           (define dc (new aosd-dc%
                           [width width] [height height]
                           [cr cairo_t]))
           (callback dc))
         #f)
      (aosd_set_geometry aosd dx dy width height)
      (aosd_set_transparency aosd 'composite)
      (aosd_show aosd)
      (aosd_loop_once aosd)
      (aosd_render aosd))

    (define/public (destroy)
      (aosd_destroy aosd)
      (set! aosd (aosd_new)))))

(define (with-aosd dx dy w h f)
  (define aosd (aosd_new))
  (aosd_set_renderer
   aosd
   (λ (cairo_t _)
     (define dc (new aosd-dc% [width w] [height h] [cr cairo_t]))
     (f dc))
   #f)
  (aosd_set_geometry aosd dx dy w h)
  (aosd_set_transparency aosd 'composite)
  (aosd_show aosd)
  (aosd_loop_once aosd)
  (aosd_render aosd))

(define aosd-dc-backend%
  (class default-dc-backend%
    (init-field width height cr)

    (define/override (get-size)
      (values width height))

    (define/override (get-cr) cr)

    (super-new)))

(define aosd-dc%
  (class (dc-mixin aosd-dc-backend%)
    (super-new)))

