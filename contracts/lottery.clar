;; Enhanced Lottery Contract

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
(define-constant err-timelock-active (err u109))
(define-constant err-max-withdrawal (err u110))

;; Data variables  
(define-data-var ticket-price uint u1000000) ;; 1 STX
(define-data-var lottery-balance uint u0)
(define-data-var lottery-open bool true)
(define-data-var last-draw-block uint u0)
(define-data-var draw-interval uint u144) 
(define-data-var min-players uint u2)
(define-data-var max-tickets-per-player uint u100)
(define-data-var contract-paused bool false)
(define-data-var admin-timelock uint u0)
(define-data-var progressive-jackpot uint u0)
(define-data-var last-random-seed uint u0)

;; Maps
(define-map tickets principal uint)
(define-map winners
  {block: uint}
  {winner: (optional principal), amount: uint, claimed: bool}
)

;; Private functions
(define-private (is-owner)
  (is-eq tx-sender contract-owner)
)

(define-private (check-timelock)
  (> (var-get admin-timelock) block-height)
)

(define-private (enhanced-random (salt uint))
  (let
    (
      (current-seed (var-get last-random-seed))
      (new-seed (xor 
        salt 
        (get-block-info? id-header-hash u0)
        current-seed
        (len block-coinbase)
      ))
    )
    (var-set last-random-seed new-seed)
    new-seed
  )
)

(define-private (random-winner (salt uint))
  (let
    (
      (total-tickets (var-get lottery-balance))
      (random (mod (enhanced-random salt) total-tickets))
    )
    (find-winner random u0 (unwrap! (map-get? tickets contract-owner) err-invalid-participant))
  )
)

;; Administrative functions
(define-public (set-timelock (blocks uint))
  (begin
    (asserts! (is-owner) err-owner-only)
    (var-set admin-timelock (+ block-height blocks))
    (print {event: "timelock-set", blocks: blocks})
    (ok true)
  )
)

(define-public (withdraw-balance (amount uint))
  (begin
    (asserts! (is-owner) err-owner-only)
    (asserts! (not (check-timelock)) err-timelock-active)
    (asserts! (<= amount (stx-get-balance (as-contract tx-sender))) err-not-enough-balance)
    (asserts! (<= amount u1000000000) err-max-withdrawal) ;; Max 1000 STX per withdrawal
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    (print {event: "balance-withdrawn", amount: amount, recipient: contract-owner})
    (ok true)
  )
)

;; [Rest of the contract remains unchanged but enhanced with progressive jackpot logic]
