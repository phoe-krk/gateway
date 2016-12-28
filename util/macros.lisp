;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GATEWAY
;;;; © Michał "phoe" Herda 2016
;;;; gateway.lisp

(in-package #:gateway)

;;;; DEFTEST
(defmacro deftest (name &body body)
  `(test ,name ,@body))

;;;; DEFINE-PROTOCOL-CLASS
(defmacro define-protocol-class (name super-classes &optional slots &rest options)
  (let* ((sym-name (symbol-name name))
         (protocol-predicate
           (intern (concatenate 'string sym-name
                                (if (find #\- sym-name) "-" "") (symbol-name '#:p))))
         (predicate-docstring
           (concatenate 'string "Returns T if object is of class " sym-name
                        ", otherwise returns NIL.")))
    `(progn
       (defclass ,name ,super-classes ,slots ,@options)
       (let ((the-class (find-class ',name)))
         (setf (documentation the-class 'type) "Gateway protocol class")
         (defmethod initialize-instance :after ((object ,name) &key &allow-other-keys)
           (when (eq (class-of object) the-class)
             (error "~S is a protocol class and thus can't be instantiated." ',name))))
       (defgeneric ,protocol-predicate (object)
         (:method ((object t)) nil)
         (:method ((object ,name)) t)
         (:documentation ,predicate-docstring))
       ',name)))

;;;; DEFPROTOCOL
(defmacro defprotocol (protocol-name (&optional class-name class-args class-slots
                                      &body class-options)
                       &body body)
  (declare (ignore protocol-name))
  `(progn
     ,(when class-name
        `(define-protocol-class ,class-name ,class-args ,class-slots ,@class-options))
     ,@body))

;;;; DEFCONSTRUCTOR
(defmacro defconstructor ((class . keys) &body body)
  `(defmethod initialize-instance :after ((,class ,class) &key ,@keys &allow-other-keys)
     ,@body))

;;;; DEFPRINT
(defmacro defprint (object &body body)
  `(defmethod print-object ((obj ,object) stream)
     ,@body))

;;;; WAIT
(defmacro wait ((&optional (timeout 0.5) (step 0.01)) &body body)
  (with-gensyms (begin-time end-time temp)
    `(let* ((,begin-time (get-internal-real-time))
            (,end-time (+ ,begin-time (* ,timeout internal-time-units-per-second))))
       (loop
         (let (,temp)
           (cond ((progn (setf ,temp (progn ,@body))
                         ,temp)
                  (return ,temp))
                 ((> (get-internal-real-time) ,end-time)
                  (return nil))
                 (t
                  (sleep ,step))))))))

;;;; WAIT-UNTIL
(defmacro wait-until (form &optional (step 0.01))
  (with-gensyms (result)
    `(loop for ,result = ,form
           if ,result return ,result
             else (sleep ,step))))

;;;; FINALIZED-LET
(defmacro finalized-let* ((&rest bindings) &body body)
  (if bindings
      `(let (,(first (first bindings)))
         (unwind-protect
              (progn (setf ,(first (first bindings))
                           ,(second (first bindings)))
                     (finalized-let* ,(rest bindings) ,@body))
           (when ,(first (first bindings))
             (progn ,@(cddr (first bindings))))))
      `(progn ,@body)))

;;;; DEFCONFIG / WITH-CLEAN-CONFIG
;; (eval-when (:compile-toplevel :load-toplevel :execute)
;;   (defvar *config-vars* nil)
;;   (defvar *cache-vars* nil)
;;   (defmacro defconfig (var val &key cache doc)
;;     `(progn (pushnew (list ',var ',val) *config-vars* :test #'equal)
;; 	    (defvar ,var ,val ,doc)
;; 	    ,@(when cache
;; 		`((pushnew (list ',cache ',var) *cache-vars*)
;; 		  (setf (gethash ,cache *cache-list*) ,var)))))
;;   (defmacro with-clean-config (&body body)
;;     `(let ,*config-vars*
;;        ;; TODO: use PROGV for dynamic binding
;;        ;; reconstruct *CACHE-LIST*
;;        (mapc (lambda (x) (setf (gethash (first x) *cache-list*) (second x)))
;; 	     (list ,@(mapcar (lambda (x) `(list ',(first x) ,(second x))) *cache-vars*)))
;;        ,@body)))

;;;; WITH-CONNECTIONS
;; (defmacro with-connections (connections &body body)
;;   `(let* ,connections
;;      (unwind-protect
;;           ,@body
;;        (mapcar #'kill (list ,@(mapcar #'first connections))))))

;;;; TESTING
;; (defun begin-tests ()
;;   (make-thread (lambda () (format t "~%[~~] Begin running tests.~%"))))

;; (defun finish-tests ()
;;   (make-thread (lambda () (format t "[~~] Finished running tests.~%"))))

;;;; DEFCOMMAND
;; (eval-when (:compile-toplevel :load-toplevel :execute)
;;   (defun %defcommand-map (args)
;;     (when args
;;       (destructuring-bind (first . rest) args
;;         (let ((elt (ecase first
;;                      (:n '*gem-n-handlers*)
;;                      (:e '*gem-e-handlers*)
;;                      (:i '*gem-i-handlers*))))
;;           (cons elt (%defcommand-map rest))))))
;;   (defmacro defcommand (command types (crown-var connection-var &rest arguments)
;;                         &body body)
;;     `(let* ((command-name (symbol-name ,command))
;;             (function (compile nil (lambda (,crown-var ,connection-var ,@arguments) ,@body))))
;;        (flet ((hash-push (hash-table) (setf (gethash command-name hash-table) function)))
;;          (mapcar #'hash-push (list ,@(%defcommand-map types)))))))
