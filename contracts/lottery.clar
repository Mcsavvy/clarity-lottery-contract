;; Lottery Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-lottery-closed (err u102))
(define-constant err-no-winner (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-max-tickets (err u105))

;; Data variables  
(define-data-var ticket-price uint u1000000) ;; 1 STX
(define-data-var lottery-balance uint u0)
(define-data-var lottery-open bool true)
(define-data-var last-draw-block uint u0)
(define-data-var draw-interval uint u144) ;; Approximately daily (assuming 10-minute block times)
(define-data-var min-players uint u2) ;; Minimum number of players required for a draw
(define-data-var max-tickets-per-player uint u100) ;; Maximum tickets per player

;; Maps
(define-map tickets principal uint)
(define-map winners
  {block: uint}
  {winner: (optional principal), amount: uint}
)

;; Private functions
(define-private (is-owner)
  (is-eq tx-sender contract-owner)
)

(define-private (random-winner (salt uint))
  (let
    (
      (total-tickets (var-get lottery-balance))
      (random (mod (+ salt block-height) total-tickets))
    )
    (find-winner random u0 (unwrap-panic (map-get? tickets contract-owner)))
  )
)

(define-private (find-winner (random uint) (current uint) (participant principal))
  (let
    (
      (participant-tickets (unwrap-panic (map-get? tickets participant)))
    )
    (if (<= random (+ current participant-tickets))
      participant
      (find-winner random (+ current participant-tickets) (+ participant u1))
    )
  )
)

(define-private (get-unique-players)
  (len (filter not-zero (map get-tickets (list-tickets))))
)

(define-private (not-zero (amount uint))
  (> amount u0)
)

;; Public functions
(define-public (buy-ticket (number-of-tickets uint))
  (let
    (
      (total-cost (* number-of-tickets (var-get ticket-price)))
      (current-tickets (default-to u0 (map-get? tickets tx-sender)))
    )
    (if (and 
          (> number-of-tickets u0) 
          (var-get lottery-open) 
          (>= (stx-get-balance tx-sender) total-cost)
          (<= (+ current-tickets number-of-tickets) (var-get max-tickets-per-player))
        )
      (begin
        (try! (stx-transfer? total-cost tx-sender (as-contract tx-sender)))
        (map-set tickets tx-sender (+ current-tickets number-of-tickets))
        (var-set lottery-balance (+ (var-get lottery-balance) number-of-tickets))
        (ok true)
      )
      (if (not (var-get lottery-open))
        err-lottery-closed
        (if (<= number-of-tickets u0)
          err-invalid-amount
          (if (> (+ current-tickets number-of-tickets) (var-get max-tickets-per-player))
            err-max-tickets
            err-not-enough-balance
          )
        )
      )
    )
  )
)

;; Rest of contract remains unchanged
