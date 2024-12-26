;; Basic Character Management System
;; Initial implementation with core character registration functionality

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INVALID-INPUT (err u7))
(define-constant ERR-CHARACTER-NOT-REGISTERED (err u8))
(define-constant MAX-CHARACTER-ID u1000000)

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