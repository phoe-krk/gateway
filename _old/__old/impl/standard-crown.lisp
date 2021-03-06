;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GATEWAY
;;;; © Michał "phoe" Herda 2016
;;;; standard-crown.lisp

(in-package #:gateway)

(defclass standard-crown (crown)
  (;; LIBRARY
   (%library :accessor library
             :initform (make-instance 'standard-library))
   ;; EVENT QUEUE
   (%event-queue :accessor event-queue
                 :initform (make-synchro-queue))
   (%gems :accessor gems
          :initform nil)
   ;; N-CONNECTIONS
   (%n-acceptor :accessor n-acceptor
                :initarg :n-acceptor
                :initform nil)
   (%n-connections :accessor n-connections
                   :initform nil)
   (%n-lock :accessor n-lock
            :initform (make-lock))
   (%n-listener :accessor n-listener
                :initform nil)
   ;; E-CONNECTIONS
   (%e-connections :accessor e-connections
                   :initform nil)
   (%e-lock :accessor e-lock
            :initform (make-lock))
   (%e-listener :accessor e-listener
                :initform nil)
   ;; I-CONNECTIONS
   (%i-acceptor :accessor i-acceptor
                :initarg :i-acceptor
                :initform nil)
   (%i-connections :accessor i-connections
                   :initform nil)
   (%i-lock :accessor i-lock
            :initform (make-lock))
   (%i-listener :accessor i-listener
                :initform nil)))

(defconstructor (standard-crown full
                                (n-host "127.0.0.1") (n-port 0)
                                (i-host "127.0.0.1") (i-port 0))
  (macrolet ((make (class &rest keys)
               `(make-instance ,class :owner standard-crown ,@keys)))
    (when full
      (let ((n-acceptor (make 'standard-acceptor :port n-port :host n-host :type :n))
            (i-acceptor (make 'standard-acceptor :port i-port :host i-host :type :i))
            (n-listener (make 'standard-listener :type :n))
            (e-listener (make 'standard-listener :type :e))
            (i-listener (make 'standard-listener :type :i))
            (gem (make-instance 'standard-gem :owner standard-crown)))
        (setf (n-acceptor standard-crown) n-acceptor
              (i-acceptor standard-crown) i-acceptor
              (n-listener standard-crown) n-listener
              (e-listener standard-crown) e-listener
              (i-listener standard-crown) i-listener
              (gems standard-crown) (list gem))))))

(defmethod lookup ((crown standard-crown) key)
  (lookup (library crown) key))

(defmethod (setf lookup) (new-value (crown standard-crown) key)
  (setf (lookup (library crown) key) new-value))

(defmethod kill ((crown standard-crown))
  (mapc #'kill (gems crown))
  (flet ((ckill (object) (when object (kill object)))
         (mapckill (lock-fn conn-fn)
           (with-lock-held ((funcall lock-fn crown))
             (mapc #'kill (remove-if-not #'alivep (funcall conn-fn crown))))))
    (mapcar #'ckill (list (n-acceptor crown) (i-acceptor crown)
                          (n-listener crown) (e-listener crown) (i-listener crown)))
    (mapckill #'n-lock #'n-connections)
    (mapckill #'e-lock #'e-connections)
    (mapckill #'i-lock #'i-connections)))

(defmethod alivep ((crown standard-crown))
  (and (gems crown) (some #'alivep (gems crown))))
