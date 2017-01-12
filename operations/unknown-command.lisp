;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GATEWAY
;;;; © Michał "phoe" Herda 2016
;;;; unknown-command.lisp

(in-package #:gateway)

#|
Operation UNKNOWN-COMMAND

This operation signals the UNKNOWN-COMMAND error.

Arguments:
* COMMAND: the command not found on the system.
* CONNECTION: the connection which sent the command.
|#

(defoperation unknown-command (:command :connection)
  (note "[!] Command ~A not found.~%" command)
  (let ((error (make-condition 'unknown-command :command command)))
    (handle-gateway-error nil connection error)))

(deftest test-operation-unknown-command
  (with-crown-and-connections crown (connection) ()
    (data-send connection `(:foo))
    (is (wait () (data-equal (data-receive connection)
                             `(:error :type :unknown-command :command :foo))))
    (data-send connection `(:unknown-command))
    (is (wait () (data-equal (data-receive connection)
                             `(:error :type :unknown-command :command :unknown-command))))))
