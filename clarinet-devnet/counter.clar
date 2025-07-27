5
;; title: counter
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

(define-map counters principal uint)

(define-read-only (get-count (who principal))
    (default-to u0 (map-get? counters who))
)

(define-public (count-up)
    (begin
       (ok (map-set counters tx-sender (+ (get-count tx-sender) u1)))
    )
)
