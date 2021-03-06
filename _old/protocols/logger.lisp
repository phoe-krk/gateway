;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GATEWAY
;;;; © Michał "phoe" Herda 2016
;;;; logger.lisp

(in-package #:gateway)

#|
Protocol class LOGGER

Must be NAMED and KILLABLE.
|#

(defprotocol logger
    (logger () ())
  (defgeneric stream-of (object))
  (defun note (&rest args)
    (%note args)))
