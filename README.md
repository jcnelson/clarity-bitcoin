# clarity-bitcoin

Clarity library for parsing Bitcoin transactions and block headers, and
verifying that Bitcoin transactions were sent on the Bitcoin chain.

This code is lightly tested and should not be used in production.  It is meant
for educational purposes.  IT HAS NOT BEEN AUDITED.

## Top-level methods

### Parse a Bitcoin block header

```
;; Parse a Bitcoin block header.
;; Returns a tuple structured as folowed on success:
;; (ok {
;;      version: uint,                  ;; block version,
;;      parent: (buff 32),              ;; parent block hash,
;;      merkle-root: (buff 32),         ;; merkle root for all this block's transactions
;;      timestamp: uint,                ;; UNIX epoch timestamp of this block, in seconds
;;      nbits: uint,                    ;; compact block difficulty representation
;;      nonce: uint                     ;; PoW solution
;; })
;; Returns (err ERR-BAD-HEADER) if the header buffer isn't actually 80 bytes long.
(define-read-only (parse-block-header (headerbuff (buff 80)))
```

### Parse a Bitcoin transaction

```
;; Parse a Bitcoin transaction, with up to 8 inputs and 8 outputs, with scriptSigs of up to 256 bytes each, and with scriptPubKeys up to 128 bytes.
;; Returns a tuple structured as follows on success:
;; (ok {
;;      version: uint,                      ;; tx version
;;      ins: (list 8
;;          {
;;              outpoint: {                 ;; pointer to the utxo this input consumes
;;                  hash: (buff 32),
;;                  index: uint
;;              },
;;              scriptSig: (buff 256),      ;; spending condition script
;;              sequence: uint
;;          }),
;;      outs: (list 8
;;          {
;;              value: uint,                ;; satoshis sent
;;              scriptPubKey: (buff 128)    ;; parse this to get an address
;;          }),
;;      locktime: uint
;; })
;; Returns (err ERR-OUT-OF-BOUNDS) if we read past the end of txbuff.
;; Returns (err ERR-VARSLICE-TOO-LONG) if we find a scriptPubKey or scriptSig that's too long to parse.
;; Returns (err ERR-TOO-MANY-TXOUTS) if there are more than eight inputs to read.
;; Returns (err ERR-TOO-MANY-TXINS) if there are more than eight outputs to read.
(define-read-only (parse-tx (tx (buff 1024)))
```

### Determine whether or not a Bitcoin transaction was sent

```
;; Top-level verification code to determine whether or not a Bitcoin transaction was mined in a prior Bitcoin block.
;; It takes the block header and block height, the transaction, and a merkle proof, and determines that:
;; * the block header corresponds to the block that was mined at the given Bitcoin height
;; * the transaction's merkle proof links it to the block header's merkle root.
;; The proof is a list of sibling merkle tree nodes that allow us to calculate the parent node from two children nodes in each merkle tree level,
;; the depth of the block's merkle tree, and the index in the block in which the given transaction can be found (starting from 0).
;; The first element in hashes must be the given transaction's sibling transaction's ID.  This and the given transaction's txid are hashed to 
;; calculate the parent hash in the merkle tree, which is then hashed with the *next* hash in the proof, and so on and so forth, until the final
;; hash can be compared against the block header's merkle root field.  The tx-index tells us in which order to hash each pair of siblings.
;; Note that the proof hashes -- including the sibling txid -- must be _big-endian_ hashes, because this is how Bitcoin generates them.
;; This is the reverse of what you'd see in a block explorer!
;; Returns (ok true) if the proof checks out.
;; Returns (ok false) if not.
;; Returns (err ERR-PROOF-TOO-SHORT) if the proof doesn't contain enough intermediate hash nodes in the merkle tree.
(define-read-only (was-tx-mined? (block { header: (buff 80), height: uint }) (tx (buff 1024)) (proof { tx-index: uint, hashes: (list 12 (buff 32)), tree-depth: uint }))
```

## Testing

Install `clarity-cli` in your `$PATH` and do the following:

```
$ cd ./tests && ./run-tests.sh
```

Unit tests with examples are in `tests/test-clarity-bitcoin.clar`.
