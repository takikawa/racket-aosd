#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define
         racket/draw/unsafe/cairo
         x11/x11
         (rename-in racket/contract [-> ->/c]))

(provide aosd_new
         aosd_destroy

         aosd_get_name
         aosd_get_names
         aosd_get_transparency
         aosd_get_geometry
         aosd_get_screen_size
         aosd_get_is_shown

         aosd_set_name
         aosd_set_names
         aosd_set_transparency
         aosd_set_geometry
         aosd_set_position
         aosd_set_position_offset
         ;aosd_set_position_with_offset
         aosd_set_renderer
         aosd_set_mouse_event_cb
         aosd_set_hide_upon_mouse_event

         aosd_render
         aosd_show
         aosd_hide
         
         aosd_loop_once)

(define-ffi-definer define-aosd
  (ffi-lib "libaosd" '("2" #f)))

(define-cpointer-type _Aosd)

(define _AosdTransparency
  (_enum '(none fake composite)))

(define-cstruct _AosdMouseEvent
  ([x _int] [y _int]
   [x_root _int] [y_root _int]
   [send_event _int]
   [button _uint]
   [time _long]))

;; typedef void (*AosdMouseEventCb)(AosdMouseEvent* event, void* user_data);
(define _AosdMouseEventCb
  (_fun _AosdMouseEvent-pointer _pointer -> _void))

;; typedef void (*AosdRenderer)(cairo_t* cr, void* user_data);
(define _AosdRenderer
  (_fun ;#:async-apply (λ (thunk) (thread thunk))
        _cairo_t _pointer -> _void))

;; Aosd* aosd_new(void)
(define-aosd aosd_new
  (_fun -> _Aosd))

;; void aosd_destroy(Asod*)
(define-aosd aosd_destroy
  (_fun _Aosd -> _void))

;;; object inspectors

;; void aosd_get_name(Aosd* aosd, XClassHint* result);
(define-aosd aosd_get_name
  (_fun _Aosd _XClassHint -> _void))

;; void aosd_get_names(Aosd* aosd, char** res_name, char** res_class);
(define-aosd aosd_get_names
  (_fun _Aosd
        (res_name : (_ptr i _string) = "")
        (res_class : (_ptr i _string) = "")
        -> _void
        -> (values res_name res_class)))

;; AosdTransparency aosd_get_transparency(Aosd* aosd);
(define-aosd aosd_get_transparency
  (_fun _Aosd -> _AosdTransparency))

;; void aosd_get_geometry(Aosd* aosd, int* x, int* y, int* width, int* height);
(define-aosd aosd_get_geometry
  (_fun _Aosd
        (x : (_ptr o _int))
        (y : (_ptr o _int))
        (width : (_ptr o _int))
        (height : (_ptr o _int))
        -> _void
        -> (values x y width height)))

;; void aosd_get_screen_size(Aosd* aosd, int* width, int* height);
(define-aosd aosd_get_screen_size
  (_fun _Aosd
        (width : (_ptr o _int))
        (height : (_ptr o _int))
        -> _void
        -> (values width height)))

;; Bool aosd_get_is_shown(Aosd* aosd);
(define-aosd aosd_get_is_shown
  (_fun _Aosd -> _bool))

;;; object configurators
;; void aosd_set_name(Aosd* aosd, XClassHint* name);
(define-aosd aosd_set_name
  (_fun _Aosd _XClassHint-pointer -> _void))

;; void aosd_set_names(Aosd* aosd, const char* res_name, const char* res_class);
(define-aosd aosd_set_names
  (_fun _Aosd
        (res_name : _string)
        (res_class : _string)
        -> _void))

;; void aosd_set_transparency(Aosd* aosd, AosdTransparency mode);
(define-aosd aosd_set_transparency
  (_fun _Aosd _AosdTransparency -> _void))

;; void aosd_set_geometry(Aosd* aosd, int x, int y, int width, int height);
(define-aosd aosd_set_geometry
  (_fun _Aosd _int _int _int _int -> _void))

;; void aosd_set_position(Aosd* aosd, unsigned pos, int width, int height);
(define-aosd aosd_set_position
  (_fun _Aosd _uint _int _int -> _void))

;; void aosd_set_position_offset(Aosd* aosd, int x_offset, int y_offset);
(define-aosd aosd_set_position_offset
  (_fun _Aosd _int _int -> _void))

;; void aosd_set_position_with_offset(Aosd* aosd,
;;     AosdCoordinate abscissa, AosdCoordinate ordinate, int width, int height,
;;     int x_offset, int y_offset);
#;
(define-aosd aosd_set_position_with_offset
  (_fun _Aosd _int _int -> _void))

;; void aosd_set_renderer(Aosd* aosd, AosdRenderer renderer, void* user_data);
(define-aosd aosd_set_renderer
  (_fun _Aosd _AosdRenderer _pointer -> _void))

;; void aosd_set_mouse_event_cb(Aosd* aosd, AosdMouseEventCb cb, void* user_data);
(define-aosd aosd_set_mouse_event_cb
  (_fun _Aosd _AosdMouseEventCb _pointer -> _void))

;; void aosd_set_hide_upon_mouse_event(Aosd* aosd, Bool enable);
(define-aosd aosd_set_hide_upon_mouse_event
  (_fun _Aosd _bool -> _void))

;;; object manipulators
;; void aosd_render(Aosd* aosd);
(define-aosd aosd_render
  (_fun _Aosd -> _void))

;; void aosd_show(Aosd* aosd);
(define-aosd aosd_show
  (_fun _Aosd -> _void))

;; void aosd_hide(Aosd* aosd);
(define-aosd aosd_hide
  (_fun _Aosd -> _void))

;;; X main loop processing
;;void aosd_loop_once(Aosd* aosd);
(define-aosd aosd_loop_once
  (_fun _Aosd -> _void))

;;void aosd_loop_for(Aosd* aosd, unsigned loop_ms);
;;
;;; automatic object manipulator
;;void aosd_flash(Aosd* aosd, unsigned fade_in_ms,
;;    unsigned full_ms, unsigned fade_out_ms);

