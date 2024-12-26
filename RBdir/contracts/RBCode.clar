;; Cross-Realm Character Transfer System
;; Added portal and transfer mechanics without signature verification

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-TRANSFER-FAILED (err u3))
(define-constant ERR-PORTAL-USED (err u4))
(define-constant ERR-CHARACTER-NOT-FOUND (err u5))
(define-constant ERR-PORTAL-FEE-FAILED (err u6))
(define-constant ERR-INVALID-INPUT (err u7))
(define-constant ERR-CHARACTER-NOT-REGISTERED (err u8))
(define-constant ERR-INVALID-POWER-LEVEL (err u9))
(define-constant ERR-INVALID-PORTAL (err u10))
(define-constant ERR-INVALID-TARGET (err u11))
(define-constant MAX-CHARACTER-ID u1000000)
(define-constant MAX-PORTAL-ID u1000000)

;; Storage for tracking used portals
(define-map UsedPortals 
  { 
    player: principal,
    portal-id: uint
  }
  bool
)

;; Storage for game characters
(define-map GameCharacters
  {
    character-id: uint,
    player: principal
  }
  uint
)

;; Character information storage
(define-map CharacterInfo
  uint  ;; character-id
  {
    class: (string-ascii 32),
    realm: (string-ascii 10),
    level: uint
  }
)

;; Portal fee configuration
(define-data-var portal-fee uint u10)

;; Register a new character class
(define-public (register-character-class 
  (character-id uint)
  (class (string-ascii 32))
  (realm (string-ascii 10))
  (level uint)
)
  (begin
    ;; Only contract owner can register character classes
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    ;; Validate character-id
    (asserts! (<= character-id MAX-CHARACTER-ID) ERR-INVALID-INPUT)
    
    ;; Validate input data
    (asserts! (> (len class) u0) ERR-INVALID-INPUT)
    (asserts! (> (len realm) u0) ERR-INVALID-INPUT)
    (asserts! (and (>= level u1) (<= level u100)) ERR-INVALID-INPUT)
    
    ;; Store character information
    (ok (map-set CharacterInfo 
      character-id
      {
        class: class,
        realm: realm,
        level: level
      }
    ))
  )
)

;; Execute cross-realm character transfer
(define-public (execute-realm-transfer
  (character-id uint)
  (power-level uint)
  (target-player principal)
  (portal-id uint)
)
  (begin
    ;; Validate inputs
    (asserts! (<= character-id MAX-CHARACTER-ID) ERR-INVALID-INPUT)
    (asserts! (and (>= power-level u1) (<= power-level u100)) ERR-INVALID-POWER-LEVEL)
    (asserts! (<= portal-id MAX-PORTAL-ID) ERR-INVALID-PORTAL)
    (asserts! (not (is-eq target-player tx-sender)) ERR-INVALID-TARGET)

    (let 
      (
        (player tx-sender)
      )
      
      ;; Check if portal has been used
      (asserts! (not (default-to false (map-get? UsedPortals { player: player, portal-id: portal-id }))) ERR-PORTAL-USED)
      
      ;; Mark portal as used
      (map-set UsedPortals { player: player, portal-id: portal-id } true)
      
      ;; Check player's character ownership and sufficient power
      (let
        (
          (current-power (default-to u0 (map-get? GameCharacters { character-id: character-id, player: player })))
        )
        (asserts! (>= current-power power-level) ERR-CHARACTER-NOT-FOUND)
        
        ;; Remove character power from source player
        (map-set GameCharacters 
          { character-id: character-id, player: player }
          (- current-power power-level)
        )
        
        ;; Add character power to target player
        (map-set GameCharacters 
          { character-id: character-id, player: target-player }
          (+ (default-to u0 (map-get? GameCharacters { character-id: character-id, player: target-player }))
             power-level)
        )
      )
      
      ;; Pay portal fee
      (try! (pay-portal-fee player))
      (ok true)
    )
  )
)

;; Pay portal fee for realm transfer
(define-private (pay-portal-fee (player principal))
  (let ((fee (var-get portal-fee)))
    (if (is-eq player CONTRACT-OWNER)
      (ok true)
      (stx-transfer? fee player CONTRACT-OWNER)
    )
  )
)

;; Update portal fee (only by contract owner)
(define-public (update-portal-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= new-fee u1) (<= new-fee u1000000)) ERR-INVALID-INPUT)
    (ok (var-set portal-fee new-fee))
  )
)

;; Get character power level for a specific player and character
(define-read-only (get-character-power (character-id uint) (player principal))
  (default-to u0 
    (map-get? GameCharacters 
      {
        character-id: character-id,
        player: player
      }
    )
  )
)