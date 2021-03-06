;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GATEWAY
;;;; © Michał "phoe" Herda 2016
;;;; unknown-player.lisp

(in-package #:gateway)

#|
Error UNKNOWN-PLAYER

Should be signaled when a gem attempts to access a user which is not
present in the owner.

Arguments:
* USERNAME: the username referring to the unknown player.
|#

(define-gateway-error unknown-player
    ((username :reader unknown-player-username
               :initarg :username
               :initform (error "Must provide username.")))
    (owner connection condition)
    (((username (username (unknown-player-username condition))))
     ("Player ~S is not known on the system." username)
      (declare (ignore owner))
      (data-send connection `(:error :type :unknown-user :username ,username))))
