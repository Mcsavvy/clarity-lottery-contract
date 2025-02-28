;; Lottery Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-lottery-closed (err u102))
(define-constant err-no-winner (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-max-tickets (err u105))
(define-constant err-invalid-participant (err u106))
(define-constant err-contract-paused (err u107))
(define-constant err-withdrawal-failed (err u108))

;; Data variables  
(define-data-var ticket-price uint u1000000) ;; 1 STX
(define-data-var lottery-balance uint u0)
(define-data-var lottery-open bool true)
(define-data-var last-draw-block uint u0)
(define-data-var draw-interval uint u144) 
(define-data-var min-players uint u2)
(define-data-var max-tickets-per-player uint u100)
(define-data-var contract-paused bool false)

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
      (random (mod (+ 
        salt 
        block-height 
        (xor (len block-coinbase) (get-block-info? id-header-hash u0))
      ) total-tickets))
    )
    (find-winner random u0 (unwrap! (map-get? tickets contract-owner) err-invalid-participant))
  )
)

;; Previous private functions remain unchanged

;; Administrative functions
(define-public (pause-contract)
  (begin
    (asserts! (is-owner) err-owner-only)
    (var-set contract-paused true)
    (print {event: "contract-paused", sender: tx-sender})
    (ok true)
  )
)

(define-public (unpause-contract)
  (begin
    (asserts! (is-owner) err-owner-only)
    (var-set contract-paused false)
    (print {event: "contract-unpaused", sender: tx-sender})
    (ok true)
  )
)

(define-public (withdraw-balance (amount uint))
  (begin
    (asserts! (is-owner) err-owner-only)
    (asserts! (<= amount (stx-get-balance (as-contract tx-sender))) err-not-enough-balance)
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    (print {event: "balance-withdrawn", amount: amount, recipient: contract-owner})
    (ok true)
  )
)

;; Getter functions
(define-read-only (get-lottery-status)
  {
    is-open: (var-get lottery-open),
    is-paused: (var-get contract-paused),
    ticket-price: (var-get ticket-price),
    total-balance: (var-get lottery-balance),
    min-players: (var-get min-players),
    max-tickets: (var-get max-tickets-per-player)
  }
)

(define-read-only (get-player-tickets (player principal))
  (default-to u0 (map-get? tickets player))
)

;; Modified buy-ticket function
(define-public (buy-ticket (number-of-tickets uint))
  (let
    (
      (total-cost (* number-of-tickets (var-get ticket-price)))
      (current-tickets (default-to u0 (map-get? tickets tx-sender)))
    )
    (asserts! (not (var-get contract-paused)) err-contract-paused)
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
        (print {event: "tickets-purchased", buyer: tx-sender, amount: number-of-tickets})
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
