;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GATEWAY
;;;; © Michał "phoe" Herda 2016
;;;; protocol.lisp

(in-package #:gateway)

(defprotocol identifiable ()
  (defun identify (type key)
    (%identify type key)))

(defprotocol cache ()
  (defun cache (type key)
    (%cache type key))
  (defun (setf cache) (new-value type key)
    (setf (%cache type key) new-value)))

(defprotocol messagable ()
  (defgeneric send-message (message recipient)))

(defprotocol crown
    (crown () ())
  ;; LIBRARY
  (defgeneric lookup (crown key))
  (defgeneric (setf lookup) (new-value crown key))
  ;; EVENT QUEUE
  (defgeneric event-queue (object))
  (defgeneric gems (object))
  ;; N-CONNECTIONS
  (defgeneric n-acceptor (object))
  (defgeneric n-connections (object))
  (defgeneric n-lock (object))
  (defgeneric n-listener (object))
  ;; E-CONNECTIONS
  (defgeneric e-connections (object))
  (defgeneric e-lock (object))
  (defgeneric e-listener (object))
  ;; I-CONNECTIONS
  (defgeneric i-acceptor (object))
  (defgeneric i-connections (object))
  (defgeneric i-lock (object))
  (defgeneric i-listener (object))
  ;; METHODS
  (defgeneric kill (object))
  (defgeneric alivep (object)))

(defprotocol player
    (player () ()
      (:documentation "Must be SEXPABLE, IDENTIFIABLE and MESSAGABLE.

Constructor arguments:
:NAME - a STRING.
:EMAIL (optional) - a STRING.
:PASSWORD - a PASSWORD or a passphrase (a STRING).
"))
  (defgeneric name (object))
  (defgeneric email (object))
  (defgeneric password (object))
  (defgeneric connection (object))
  (defgeneric personas (object))
  (defgeneric add-persona (persona object))
  (defgeneric delete-persona (persona object))
  (defgeneric find-player (name)))

(defprotocol persona
    (persona () ()
      (:documentation "Must be SEXPABLE, IDENTIFIABLE and MESSAGABLE.

Constructor arguments:
:NAME - a STRING.
:PLAYER - a PLAYER.
:CHAT - a CHAT."))
  (defgeneric name (object))
  (defgeneric player (object))
  (defgeneric chat (object))
  (defgeneric find-persona (name)))

(defprotocol message
    (message () ()
      (:documentation "Must be SEXPABLE and IMMUTABLE.

Constructor arguments:
:SENDER - the sender of the message.
:RECIPIENT - the recipient of the message.
:DATE - object of type DATE.
:CONTENTS - contents of the message (a STRING)."))
  (defgeneric sender (object))
  (defgeneric recipient (object))
  (defgeneric date (object))
  (defgeneric contents (object))
  (defgeneric msg (sender recipient contents &key date))
  (defgeneric message= (message-1 message-2)))

(defprotocol chat
    (chat () ()
      (:documentation "Must be SEXPABLE, IDENTIFIABLE and MESSAGABLE.

Constructor arguments:
:NAME - a STRING."))
  (defgeneric name (object))
  (defgeneric messages (object))
  (defgeneric personas (object))
  (defgeneric add-persona (persona object))
  (defgeneric delete-persona (persona object))
  (defgeneric find-chat (name)))

(defprotocol shard
    (shard () ())

  (defgeneric players (object))
  (defgeneric chats (object))
  (defgeneric add-persona (persona object))
  (defgeneric delete-persona (persona object)))

(defprotocol gem
    (gem () ()
      (:documentation "Constructor arguments:
:OWNER - a CROWN or a JEWEL.
"))
  (defgeneric owner (gem))
  (defgeneric thread (gem)))

(defprotocol timer
    (timer () ()
      (:documentation "Constructor arguments:
:DELAY - delay between each timer ticks,
:QUEUE - event queue to set updates to,
:OWNER - a CROWN or a JEWEL.
"))
  (defgeneric delay (timer))
  (defgeneric (setf delay) (timer)))

(defprotocol connector
    (connector () ()
      (:documentation "Constructor arguments:
:HOST - host to try to connect to,
:PORT - port to try to connect to,
:COOKIE - magic cookie to expect from the crown.
"))
  (defgeneric alivep (object))
  (defgeneric kill (object)))

(defprotocol jewel
    (jewel () ())
  ;; EVENT QUEUE
  (defgeneric event-queue (object))
  (defgeneric gems (object))
  (defgeneric timer (object))
  ;; CONNECTION
  (defgeneric connection (object))
  (defgeneric connector (object))
  ;; SHARDS
  (defgeneric shards (object))
  (defgeneric shards-lock (object))
  (defgeneric add-shard (jewel shard))
  (defgeneric remove-shard (jewel shard))
  ;; METHODS
  (defgeneric kill (object))
  (defgeneric alivep (object)))



