;; Lottery Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-lottery-closed (err u102))
(define-constant err-no-winner (err u103))

;; Data variables
(define-data-var ticket-price uint u1000000) ;; 1 STX
(define-data-var lottery-balance uint u0)
(define-data-var lottery-open bool true)
(define-data-var last-draw-block uint u0)
(define-data-var draw-interval uint u144) ;; Approximately daily (assuming 10-minute block times)

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

;; Public functions
(define-public (buy-ticket (number-of-tickets uint))
  (let
    (
      (total-cost (* number-of-tickets (var-get ticket-price)))
    )
    (if (and (var-get lottery-open) (>= (stx-get-balance tx-sender) total-cost))
      (begin
        (try! (stx-transfer? total-cost tx-sender (as-contract tx-sender)))
        (map-set tickets tx-sender (+ (default-to u0 (map-get? tickets tx-sender)) number-of-tickets))
        (var-set lottery-balance (+ (var-get lottery-balance) number-of-tickets))
        (ok true)
      )
      (if (not (var-get lottery-open))
        err-lottery-closed
        err-not-enough-balance
      )
    )
  )
)

(define-public (draw-lottery)
  (let
    (
      (current-block block-height)
      (last-draw (var-get last-draw-block))
      (interval (var-get draw-interval))
    )
    (if (and (>= (- current-block last-draw) interval) (> (var-get lottery-balance) u0))
      (let
        (
          (winner (random-winner current-block))
          (prize (var-get lottery-balance))
        )
        (var-set lottery-open false)
        (var-set last-draw-block current-block)
        (var-set lottery-balance u0)
        (try! (as-contract (stx-transfer? prize tx-sender winner)))
        (map-set winners {block: current-block} {winner: (some winner), amount: prize})
        (map-set tickets winner u0)
        (var-set lottery-open true)
        (ok winner)
      )
      err-no-winner
    )
  )
)

(define-public (change-ticket-price (new-price uint))
  (if (is-owner)
    (begin
      (var-set ticket-price new-price)
      (ok true)
    )
    err-owner-only
  )
)

(define-public (change-draw-interval (new-interval uint))
  (if (is-owner)
    (begin
      (var-set draw-interval new-interval)
      (ok true)
    )
    err-owner-only
  )
)

;; Read-only functions
(define-read-only (get-ticket-price)
  (ok (var-get ticket-price))
)

(define-read-only (get-lottery-balance)
  (ok (var-get lottery-balance))
)

(define-read-only (get-tickets (participant principal))
  (ok (default-to u0 (map-get? tickets participant)))
)

(define-read-only (get-last-winner (block uint))
  (map-get? winners {block: block})
)

