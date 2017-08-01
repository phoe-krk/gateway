;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GATEWAY
;;;; © Michał "phoe" Herda 2016
;;;; standard-connection.lisp

(in-package #:gateway)

;; (defclass standard-connection (connection)
;;   ((%socket :accessor socket)
;;    (%auth :accessor auth :initform nil)
;;    (%lock :accessor lock)))

;; (defconstructor (standard-connection (host "127.0.0.1") (port 65001) socket)
;;   (unless socket
;;     (check-type host string)
;;     (check-type port (unsigned-byte 16))
;;     (setf socket (change-class (socket-connect host port) 'standard-socket
;;                                :owner standard-connection)))
;;   (check-type socket usocket)
;;   (setf (socket standard-connection)
;;         (change-class socket 'standard-socket :owner standard-connection)
;;         (lock standard-connection)
;;         (make-lock (format nil "STANDARD-CONNECTION ~A:~D" host port))))

;; (defmethod stream-of ((connection standard-connection))
;;   (socket-stream (socket connection)))

;; (defprint standard-connection
;;   (print-unreadable-object (obj stream :type t :identity t)
;;     ;; (format stream "~{~D:~D:~D:~D~}:~D"
;;     ;;         (coerce (get-peer-address (socket obj)) 'list)
;;     ;;         (get-peer-port (socket obj)))
;;     ))

;; (defun %host-to-string (vector)
;;   (format nil "~{~D.~D.~D.~D~}" (coerce vector 'list)))

;; (defmacro with-connection ((connection &optional error-return-value) &body body)
;;   `(when (alivep ,connection)
;;      (handler-case
;;          (with-lock-held ((lock ,connection))
;;            ,@body)
;;        (error (e)
;;          (note "[!] Connection: ~A~%" e)
;;          (kill ,connection)
;;          ,error-return-value))))

;; (defmethod data-receive ((connection standard-connection))
;;   (with-connection (connection)
;;     (when (%connection-readyp connection)
;;     (safe-read (stream-of connection)))))

;; (defmethod data-send ((connection standard-connection) object)
;;   (with-connection (connection)
;;     (let ((sexp (sexp object)) (*print-pretty* nil))
;;       (fformat (stream-of connection) "~S~%" (unintern-all-symbols sexp)))))

;; (defmethod readyp ((connection standard-connection))
;;   (with-connection (connection)
;;     (%connection-readyp connection)))

;; (defun %connection-readyp (connection)
;;   (peek-char-no-hang (stream-of connection)))

;; (defmethod alivep ((connection standard-connection))
;;   (with-lock-held ((lock connection))
;;     (%alivep connection)
;;     (open-stream-p (stream-of connection))))

;; (defun %alivep (connection)
;;   (handler-case
;;       (peek-char-no-hang (stream-of connection))
;;     (error () (%connection-kill connection))))

;; (defmethod kill ((connection standard-connection))
;;   (with-lock-held ((lock connection))
;;     (%connection-kill connection))
;;   (values))

;; (defun %connection-kill (connection)
;;   (socket-close (socket connection)))

;; (defun %make-connection (host port)
;;   (make-instance 'standard-connection :host host :port port))

;; (defun %make-connection-pair ()
;;   (let* ((socket-listen (socket-listen "127.0.0.1" 0))
;;          (port (get-local-port socket-listen))
;;          (socket-connect (socket-connect "127.0.0.1" port))
;;          (socket-accept (socket-accept socket-listen)))
;;     (socket-close socket-listen)
;;     (values (make-instance 'standard-connection :socket socket-connect)
;;             (make-instance 'standard-connection :socket socket-accept))))

;; (deftest test-standard-connection-death
;;   (finalized-let* ((conns (multiple-value-list (make-connection-pair))
;;                           (mapc #'kill conns)))
;;     (is (alivep (first conns)))
;;     (is (alivep (second conns)))
;;     (kill (first conns))
;;     (is (deadp (first conns)))
;;     (is (deadp (second conns)))))

;; (define-test test-standard-connection
;;   (finalized-let*
;;       ((socket-listen (socket-listen "127.0.0.1" 0)
;;                       (socket-close socket-listen))
;;        (port (get-local-port socket-listen))
;;        (connection-1 (make-instance 'standard-connection :port port)
;;                      (kill connection-1))
;;        (socket-accept (socket-accept socket-listen))
;;        (connection-2 (make-instance 'standard-connection :socket socket-accept)
;;                      (kill connection-2)))
;;     (let ((test-cases '((1 2 3 4 5 6 7 8 9 0)
;;                         (#:a #:b #:c #:d #:e #:f (#:g)
;;                          ((((#:h #:i #:j #:k (#:l) #:m #:n)))))
;;                         (#:lorem #:ipsum #:dolor #:sit #:amet)
;;                         ("a" #:a "a" #:a "a" "b"))))
;;       (labels ((test (x y data)
;;                  (data-send x data)
;;                  (is (wait () (readyp y)))
;;                  (is (data-equal data (data-receive y))))
;;                (test-case (data)
;;                  (test connection-1 connection-2 data)
;;                  (test connection-2 connection-1 data)))
;;         (mapc #'test-case test-cases)
;;         (values)))))
