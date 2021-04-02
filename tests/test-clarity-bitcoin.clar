;; list of tests to run (also includes unit tests)
(define-public (list-tests)
    (begin
       (ok (list
           "unit-tests"
       ))
    )
)

(define-private (check-slices (expected-slice (buff 1024)) (test-data { slice-data: (buff 1024), offset: uint, result: bool }))
    (let (
        (slice-data (get slice-data test-data))
        (subslice (match (read-slice slice-data (get offset test-data) (len expected-slice))
            subs subs
            error
                (begin
                    (print "failed to read subslice")
                    (print expected-slice)
                    (print test-data)
                    (print error)
                    0xdeadbeef
                )
            )
        )
    )
    (begin
        (if (not (is-eq expected-slice subslice))
            (begin
                (print "subslice failure")
                (print expected-slice)
                (print subslice)
                { slice-data: slice-data, offset: (get offset test-data), result: false }
            )
            { slice-data: slice-data, offset: (get offset test-data), result: (get result test-data) }
        )
    ))
)
                

(define-private (read-slice-prefixes)
    (let (
        (test-slice 0x00112233445566778899aabbccddeeff)
        (outputs (list
            0x
            0x00
            0x0011
            0x001122
            0x00112233
            0x0011223344
            0x001122334455
            0x00112233445566
            0x0011223344556677
            0x001122334455667788
            0x00112233445566778899
            0x00112233445566778899aa
            0x00112233445566778899aabb
            0x00112233445566778899aabbcc
            0x00112233445566778899aabbccdd
            0x00112233445566778899aabbccddee
            0x00112233445566778899aabbccddeeff
        ))
    )
    (begin
        (print "read-slice-prefixes")
        (asserts! (get result (fold check-slices outputs { slice-data: test-slice, offset: u0, result: true }))
            (err u0))
        (ok u0)
    ))
)

(define-private (read-slice-middles)
    (let (
        (test-slice 0x00112233445566778899aabbccddeeff)
        (outputs (list
            0x
            0x66
            0x6677
            0x667788
            0x66778899
            0x66778899aa
            0x66778899aabb
            0x66778899aabbcc
            0x66778899aabbccdd
            0x66778899aabbccddee
            0x66778899aabbccddeeff
        ))
    )
    (begin
        (print "read-slice-middles")
        (asserts! (get result (fold check-slices outputs { slice-data: test-slice, offset: u6, result: true }))
            (err u0))
        (ok u0)
    ))
)

(define-private (read-ints)
    (begin
        (print "test-read-ints")
        (asserts! (is-eq u0 (get uint16 (try! (read-uint16 { txbuff: 0x0000, index: u0 })))) (err u0))
        (asserts! (is-eq u1 (get uint16 (try! (read-uint16 { txbuff: 0x0100, index: u0 })))) (err u1)) 
        (asserts! (is-eq u65535 (get uint16 (try! (read-uint16 { txbuff: 0xffff, index: u0 })))) (err u2))

        (asserts! (is-eq u0 (get uint32 (try! (read-uint32 { txbuff: 0x00000000, index: u0 })))) (err u3))
        (asserts! (is-eq u1 (get uint32 (try! (read-uint32 { txbuff: 0x01000000, index: u0 })))) (err u4))
        (asserts! (is-eq u256 (get uint32 (try! (read-uint32 { txbuff: 0x00010000, index: u0 })))) (err u5))
        (asserts! (is-eq u65536 (get uint32 (try! (read-uint32 { txbuff: 0x00000100, index: u0 })))) (err u6))
        (asserts! (is-eq u4294967295 (get uint32 (try! (read-uint32 { txbuff: 0xffffffff, index: u0 })))) (err u7))

        (asserts! (is-eq u0 (get uint64 (try! (read-uint64 { txbuff: 0x0000000000000000, index: u0 })))) (err u8))
        (asserts! (is-eq u1 (get uint64 (try! (read-uint64 { txbuff: 0x0100000000000000, index: u0 })))) (err u9))
        (asserts! (is-eq u65536 (get uint64 (try! (read-uint64 { txbuff: 0x0000010000000000, index: u0 })))) (err u10))
        (asserts! (is-eq u4294967296 (get uint64 (try! (read-uint64 { txbuff: 0x0000000001000000, index: u0 })))) (err u11))
        (asserts! (is-eq u18446744073709551615 (get uint64 (try! (read-uint64 { txbuff: 0xffffffffffffffff, index: u0 })))) (err u12))

        ;; ignores trailing suffixes
        (asserts! (is-eq u0 (get uint16 (try! (read-uint16 { txbuff: 0x0000ff, index: u0 })))) (err u20))
        (asserts! (is-eq u1 (get uint16 (try! (read-uint16 { txbuff: 0x0100ff, index: u0 })))) (err u21)) 
        (asserts! (is-eq u65535 (get uint16 (try! (read-uint16 { txbuff: 0xffff00, index: u0 })))) (err u22))

        (asserts! (is-eq u0 (get uint32 (try! (read-uint32 { txbuff: 0x00000000ff, index: u0 })))) (err u23))
        (asserts! (is-eq u1 (get uint32 (try! (read-uint32 { txbuff: 0x01000000ff, index: u0 })))) (err u24))
        (asserts! (is-eq u256 (get uint32 (try! (read-uint32 { txbuff: 0x00010000ff, index: u0 })))) (err u25))
        (asserts! (is-eq u65536 (get uint32 (try! (read-uint32 { txbuff: 0x00000100ff, index: u0 })))) (err u26))
        (asserts! (is-eq u4294967295 (get uint32 (try! (read-uint32 { txbuff: 0xffffffff00, index: u0 })))) (err u27))

        (asserts! (is-eq u0 (get uint64 (try! (read-uint64 { txbuff: 0x0000000000000000ff, index: u0 })))) (err u28))
        (asserts! (is-eq u1 (get uint64 (try! (read-uint64 { txbuff: 0x0100000000000000ff, index: u0 })))) (err u29))
        (asserts! (is-eq u65536 (get uint64 (try! (read-uint64 { txbuff: 0x0000010000000000ff, index: u0 })))) (err u30))
        (asserts! (is-eq u4294967296 (get uint64 (try! (read-uint64 { txbuff: 0x0000000001000000ff, index: u0 })))) (err u31))
        (asserts! (is-eq u18446744073709551615 (get uint64 (try! (read-uint64 { txbuff: 0xffffffffffffffff00, index: u0 })))) (err u32))

        ;; ignores prefixes
        (asserts! (is-eq u0 (get uint16 (try! (read-uint16 { txbuff: 0xff0000, index: u1 })))) (err u40))
        (asserts! (is-eq u1 (get uint16 (try! (read-uint16 { txbuff: 0xff0100, index: u1 })))) (err u41)) 
        (asserts! (is-eq u65535 (get uint16 (try! (read-uint16 { txbuff: 0x00ffff, index: u1 })))) (err u42))

        (asserts! (is-eq u0 (get uint32 (try! (read-uint32 { txbuff: 0xff00000000, index: u1 })))) (err u43))
        (asserts! (is-eq u1 (get uint32 (try! (read-uint32 { txbuff: 0xff01000000, index: u1 })))) (err u44))
        (asserts! (is-eq u256 (get uint32 (try! (read-uint32 { txbuff: 0xff00010000, index: u1 })))) (err u45))
        (asserts! (is-eq u65536 (get uint32 (try! (read-uint32 { txbuff: 0xff00000100, index: u1 })))) (err u46))
        (asserts! (is-eq u4294967295 (get uint32 (try! (read-uint32 { txbuff: 0x00ffffffff, index: u1 })))) (err u47))

        (asserts! (is-eq u0 (get uint64 (try! (read-uint64 { txbuff: 0xff0000000000000000, index: u1 })))) (err u48))
        (asserts! (is-eq u1 (get uint64 (try! (read-uint64 { txbuff: 0xff0100000000000000, index: u1 })))) (err u49))
        (asserts! (is-eq u65536 (get uint64 (try! (read-uint64 { txbuff: 0xff0000010000000000, index: u1 })))) (err u50))
        (asserts! (is-eq u4294967296 (get uint64 (try! (read-uint64 { txbuff: 0xff0000000001000000, index: u1 })))) (err u51))
        (asserts! (is-eq u18446744073709551615 (get uint64 (try! (read-uint64 { txbuff: 0x00ffffffffffffffff, index: u1 })))) (err u52))

        (ok true)
    )
)

(define-private (read-varints)
    (begin
        (print "test-read-varints")
        (asserts! (is-eq u1 (get varint (try! (read-varint { txbuff: 0x01, index: u0 })))) (err u0))
        (asserts! (is-eq u252 (get varint (try! (read-varint { txbuff: 0xfc, index: u0 })))) (err u1))
        (asserts! (is-eq u253 (get varint (try! (read-varint { txbuff: 0xfdfd00, index: u0 })))) (err u2))
        (asserts! (is-eq u65535 (get varint (try! (read-varint { txbuff: 0xfdffff, index: u0 })))) (err u3))
        (asserts! (is-eq u65536 (get varint (try! (read-varint { txbuff: 0xfe00000100, index: u0 })))) (err u4))
        (asserts! (is-eq u4294967295 (get varint (try! (read-varint { txbuff: 0xfeffffffff, index: u0 })))) (err u5))
        (asserts! (is-eq u4294967296 (get varint (try! (read-varint { txbuff: 0xff0000000001000000, index: u0 })))) (err u6))
        (asserts! (is-eq u18446744073709551615 (get varint (try! (read-varint { txbuff: 0xffffffffffffffffff, index: u0 })))) (err u7))

        ;; index advances appropriately
        (asserts! (is-eq u1 (get index (get ctx (try! (read-varint { txbuff: 0x01, index: u0 }))))) (err u10))
        (asserts! (is-eq u1 (get index (get ctx (try! (read-varint { txbuff: 0xfc, index: u0 }))))) (err u11))
        (asserts! (is-eq u3 (get index (get ctx (try! (read-varint { txbuff: 0xfdfd00, index: u0 }))))) (err u12))
        (asserts! (is-eq u3 (get index (get ctx (try! (read-varint { txbuff: 0xfdffff, index: u0 }))))) (err u13))
        (asserts! (is-eq u5 (get index (get ctx (try! (read-varint { txbuff: 0xfe00000100, index: u0 }))))) (err u14))
        (asserts! (is-eq u5 (get index (get ctx (try! (read-varint { txbuff: 0xfeffffffff, index: u0 }))))) (err u15))
        (asserts! (is-eq u9 (get index (get ctx (try! (read-varint { txbuff: 0xff0000000001000000, index: u0 }))))) (err u16))
        (asserts! (is-eq u9 (get index (get ctx (try! (read-varint { txbuff: 0xffffffffffffffffff, index: u0 }))))) (err u17))
        (ok true)
    )
)

(define-private (read-varslices)
    (begin
        (print "test-read-varslices")
        (asserts! (is-eq 0x01020304 (get varslice (try! (read-varslice { txbuff: 0x040102030405060708, index: u0 })))) (err u0))
        (asserts! (is-eq u5 (get index (get ctx (try! (read-varslice { txbuff: 0x040102030405060708, index: u0 }))))) (err u1))

        (asserts! (is-eq 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff
                         (get varslice (try! (read-varslice { txbuff: 0xfd0001000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405, index: u0 }))))
                   (err u10))
        
        (asserts! (is-eq u259 (get index (get ctx
                         (try! (read-varslice { txbuff: 0xfd0001000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff000102030405, index: u0 })))))
                   (err u11))


        (ok true)
    )
)

(define-private (test-parse-tx (tx (buff 1024)) (expected {
                                                    version: uint,
                                                    locktime: uint,
                                                    ins: (list 8 { outpoint: { hash: (buff 32), index: uint }, scriptSig: (buff 256), sequence: uint }),
                                                    outs: (list 8 { value: uint, scriptPubKey: (buff 128) })
                                                }))
    (match (parse-tx tx)
        ok-tx
             (if (is-eq ok-tx expected)
                true
                (begin
                    (print "did not parse:")
                    (print tx)
                    (print "expected:")
                    (print expected)
                    (print "got:")
                    (print ok-tx)
                    false
                )
             )
        err-res
            (begin
                (print "failed to parse:")
                (print tx)
                (print "error code:")
                (print err-res)
                false
            )
    )
)

(define-private (test-parse-simple-bitcoin-txs)
    (begin
        (print "test-parse-simple-bitcoin-txs 0")
        (asserts! (test-parse-tx
            0x02000000019b69251560ea1143de610b3c6630dcf94e12000ceba7d40b136bfb67f5a9e4eb000000006b483045022100a52f6c484072528334ac4aa5605a3f440c47383e01bc94e9eec043d5ad7e2c8002206439555804f22c053b89390958083730d6a66c1b711f6b8669a025dbbf5575bd012103abc7f1683755e94afe899029a8acde1480716385b37d4369ba1bed0a2eb3a0c5feffffff022864f203000000001976a914a2420e28fbf9b3bd34330ebf5ffa544734d2bfc788acb1103955000000001976a9149049b676cf05040103135c7342bcc713a816700688ac3bc50700
            {
                ins: (list
                    {
                        outpoint: {
                            hash: 0xebe4a9f567fb6b130bd4a7eb0c00124ef9dc30663c0b61de4311ea601525699b, 
                            index: u0
                        }, 
                        scriptSig: 0x483045022100a52f6c484072528334ac4aa5605a3f440c47383e01bc94e9eec043d5ad7e2c8002206439555804f22c053b89390958083730d6a66c1b711f6b8669a025dbbf5575bd012103abc7f1683755e94afe899029a8acde1480716385b37d4369ba1bed0a2eb3a0c5, 
                        sequence: u4294967294
                    }
                ),
                locktime: u509243, 
                outs: (list
                    {
                        scriptPubKey: 0x76a914a2420e28fbf9b3bd34330ebf5ffa544734d2bfc788ac, 
                        value: u66217000
                    }
                    {
                        scriptPubKey: 0x76a9149049b676cf05040103135c7342bcc713a816700688ac, 
                        value: u1429803185
                    }
                ),
                version: u2
            })
            (err u0))

        (print "test-parse-simple-bitcoin-txs 1")
        (asserts! (test-parse-tx
            0x01000000011111111111111111111111111111111111111111111111111111111111111112000000006b483045022100eba8c0a57c1eb71cdfba0874de63cf37b3aace1e56dcbd61701548194a79af34022041dd191256f3f8a45562e5d60956bb871421ba69db605716250554b23b08277b012102d8015134d9db8178ac93acbc43170a2f20febba5087a5b0437058765ad5133d000000000040000000000000000536a4c5069645b22222222222222222222222222222222222222222222222222222222222222223333333333333333333333333333333333333333333333333333333333333333404142435051606162637071fa39300000000000001976a914000000000000000000000000000000000000000088ac39300000000000001976a914000000000000000000000000000000000000000088aca05b0000000000001976a9140be3e286a15ea85882761618e366586b5574100d88ac00000000
            {
                version: u1,
                locktime: u0,
                ins: (list
                    {
                        outpoint: {
                            hash: 0x1211111111111111111111111111111111111111111111111111111111111111,
                            index: u0
                        },
                        scriptSig: 0x483045022100eba8c0a57c1eb71cdfba0874de63cf37b3aace1e56dcbd61701548194a79af34022041dd191256f3f8a45562e5d60956bb871421ba69db605716250554b23b08277b012102d8015134d9db8178ac93acbc43170a2f20febba5087a5b0437058765ad5133d0,
                        sequence: u0
                    }
                ),
                outs: (list
                    {
                        scriptPubKey: 0x6a4c5069645b22222222222222222222222222222222222222222222222222222222222222223333333333333333333333333333333333333333333333333333333333333333404142435051606162637071fa,
                        value: u0
                    }
                    {
                        scriptPubKey: 0x76a914000000000000000000000000000000000000000088ac,
                        value: u12345
                    }
                    {
                        scriptPubKey: 0x76a914000000000000000000000000000000000000000088ac,
                        value: u12345
                    }
                    {
                        scriptPubKey: 0x76a9140be3e286a15ea85882761618e366586b5574100d88ac,
                        value: u23456
                    }
                )
            })
            (err u1))

        (print "test-parse-simple-bitcoin-txs 2")
        (asserts! (test-parse-tx
            0x01000000011111111111111111111111111111111111111111111111111111111111111112000000006a473044022037d0b9d4e98eab190522acf5fb8ea8e89b6a4704e0ac6c1883d6ffa629b3edd30220202757d710ec0fb940d1715e02588bb2150110161a9ee08a83b750d961431a8e012102d8015134d9db8178ac93acbc43170a2f20febba5087a5b0437058765ad5133d000000000020000000000000000396a3769645e2222222222222222222222222222222222222222a366b51292bef4edd64063d9145c617fec373bceb0758e98cd72becd84d54c7a39300000000000001976a9140be3e286a15ea85882761618e366586b5574100d88ac00000000
            {
                version: u1,
                locktime: u0,
                ins: (list
                    {
                        outpoint: {
                            hash: 0x1211111111111111111111111111111111111111111111111111111111111111,
                            index: u0
                        }, 
                        scriptSig: 0x473044022037d0b9d4e98eab190522acf5fb8ea8e89b6a4704e0ac6c1883d6ffa629b3edd30220202757d710ec0fb940d1715e02588bb2150110161a9ee08a83b750d961431a8e012102d8015134d9db8178ac93acbc43170a2f20febba5087a5b0437058765ad5133d0, 
                        sequence: u0
                    }
                ),
                outs: (list
                    {
                        scriptPubKey: 0x6a3769645e2222222222222222222222222222222222222222a366b51292bef4edd64063d9145c617fec373bceb0758e98cd72becd84d54c7a, 
                        value: u0
                    } 
                    {
                        scriptPubKey: 0x76a9140be3e286a15ea85882761618e366586b5574100d88ac, 
                        value: u12345
                    }
                )
            })
            (err u2))
           
        (ok true)
    )
)

(define-private (test-parse-header (header (buff 80)) (expected {
                                                         version: uint,
                                                         parent: (buff 32),
                                                         merkle-root: (buff 32),
                                                         timestamp: uint,
                                                         nbits: uint,
                                                         nonce: uint
                                                      }))
    (match (parse-block-header header)
        ok-header
             (if (is-eq ok-header expected)
                true
                (begin
                    (print "did not parse header:")
                    (print header)
                    (print "expected:")
                    (print expected)
                    (print "got:")
                    (print ok-header)
                    false
                )
             )
        err-res
            (begin
                (print "failed to parse header:")
                (print header)
                (print "error code:")
                (print err-res)
                false
            )
    )
)

(define-private (test-parse-bitcoin-headers)
    (begin
        (print "test-parse-bitcoin-headers 0")
        (asserts! (test-parse-header
            0x000000203c437224480966081c2b14afac79e58207d996c8ac9d32000000000000000000847a4c2c77c8ecf0416ca07c2dc038414f14135017e18525f85cacdeedb54244e0d6b958df620218c626368a
            {
                version: u536870912,
                parent: 0x000000000000000000329dacc896d90782e579acaf142b1c086609482472433c,
                merkle-root: 0x4442b5eddeac5cf82585e1175013144f4138c02d7ca06c41f0ecc8772c4c7a84,
                timestamp: u1488574176,
                nbits: u402809567,
                nonce: u2318804678
            })
            (err u0))

        (ok true)
    )
)

(define-private (test-get-txid)
    (begin
        (print "test-get-txid")
        (asserts! (is-eq
            0x74d350ca44c324f4643274b98801f9a023b2b8b72e8e895879fd9070a68f7f1f
            (get-txid 0x02000000019b69251560ea1143de610b3c6630dcf94e12000ceba7d40b136bfb67f5a9e4eb000000006b483045022100a52f6c484072528334ac4aa5605a3f440c47383e01bc94e9eec043d5ad7e2c8002206439555804f22c053b89390958083730d6a66c1b711f6b8669a025dbbf5575bd012103abc7f1683755e94afe899029a8acde1480716385b37d4369ba1bed0a2eb3a0c5feffffff022864f203000000001976a914a2420e28fbf9b3bd34330ebf5ffa544734d2bfc788acb1103955000000001976a9149049b676cf05040103135c7342bcc713a816700688ac3bc50700))
            (err u0))

        (ok true)
    )
)

(define-private (test-verify-merkle-proof)
    (begin
        (print "test-verify-merkle-proof")
        (asserts! (try! (verify-merkle-proof
            (reverse-buff32 0x25c6a1f8c0b5be2bee1e8dd3478b4ec8f54bbc3742eaf90bfb5afd46cf217ad9)      ;; txid (but big-endian)
            0xb152eca4364850f3424c7ac2b337d606c5ca0a3f96f1554f8db33d2f6f130bbe      ;; merkle root (from block 150000)
            {
                hashes: (list
                   0xae1e670bdbf8ab984f412e6102c369aeca2ced933a1de74712ccda5edaf4ee57  ;; sibling txid (in block 150000)
                   0xefc2b3db87ff4f00c79dfa8f732a23c0e18587a73a839b7710234583cdd03db9  ;; 3 intermediate double-sha256 hashes
                   0xf1b6fe8fc2ab800e6d76ee975a002d3e67a60b51a62085a07289505b8d03f149
                   0xe827331b1fe7a2689fbc23d14cd21317c699596cbca222182a489322ece1fa74
                ),
                tx-index: u6,                                                       ;; this transaction is at index 6 in the block (starts from 0)
                tree-depth: u4                                                      ;; merkle tree depth (must be given because we can't infer leaf/non-leaf nodes)
            }))
            (err u0))

        (asserts! (not (try! (verify-merkle-proof
            (reverse-buff32 0x25c6a1f8c0b5be2bee1e8dd3478b4ec8f54bbc3742eaf90bfb5aed46cf217ad9)      ;; CORRUPTED
            0xb152eca4364850f3424c7ac2b337d606c5ca0a3f96f1554f8db33d2f6f130bbe
            {
                hashes: (list
                   0xae1e670bdbf8ab984f412e6102c369aeca2ced933a1de74712ccda5edaf4ee57
                   0xefc2b3db87ff4f00c79dfa8f732a23c0e18587a73a839b7710234583cdd03db9
                   0xf1b6fe8fc2ab800e6d76ee975a002d3e67a60b51a62085a07289505b8d03f149
                   0xe827331b1fe7a2689fbc23d14cd21317c699596cbca222182a489322ece1fa74
                ),
                tx-index: u6,
                tree-depth: u4
            })))
            (err u1))

        (asserts! (not (try! (verify-merkle-proof
            (reverse-buff32 0x25c6a1f8c0b5be2bee1e8dd3478b4ec8f54bbc3742eaf90bfb5afd46cf217ad9)
            0xb152eca4364850f3424c7ac2b337d606c5ca0a3f96f1554f8db33d2e6f130bbe                      ;; CORRUPTED
            {
                hashes: (list
                   0xae1e670bdbf8ab984f412e6102c369aeca2ced933a1de74712ccda5edaf4ee57
                   0xefc2b3db87ff4f00c79dfa8f732a23c0e18587a73a839b7710234583cdd03db9
                   0xf1b6fe8fc2ab800e6d76ee975a002d3e67a60b51a62085a07289505b8d03f149
                   0xe827331b1fe7a2689fbc23d14cd21317c699596cbca222182a489322ece1fa74
                ),
                tx-index: u6,
                tree-depth: u4
            })))
            (err u2))

        (asserts! (not (try! (verify-merkle-proof
            (reverse-buff32 0x25c6a1f8c0b5be2bee1e8dd3478b4ec8f54bbc3742eaf90bfb5aed46cf217ad9)
            0xb152eca4364850f3424c7ac2b337d606c5ca0a3f96f1554f8db33d2f6f130bbe
            {
                hashes: (list
                   0xae1e670bdbf8ab984f412e6102c369aeca2ced933a1de74712ccda5edaf4ee58       ;; CORRUPTED
                   0xefc2b3db87ff4f00c79dfa8f732a23c0e18587a73a839b7710234583cdd03db9
                   0xf1b6fe8fc2ab800e6d76ee975a002d3e67a60b51a62085a07289505b8d03f149
                   0xe827331b1fe7a2689fbc23d14cd21317c699596cbca222182a489322ece1fa74
                ),
                tx-index: u6,
                tree-depth: u4
            })))
            (err u3))

        (asserts! (not (try! (verify-merkle-proof
            (reverse-buff32 0x25c6a1f8c0b5be2bee1e8dd3478b4ec8f54bbc3742eaf90bfb5aed46cf217ad9)
            0xb152eca4364850f3424c7ac2b337d606c5ca0a3f96f1554f8db33d2f6f130bbe
            {
                hashes: (list
                   0xae1e670bdbf8ab984f412e6102c369aeca2ced933a1de74712ccda5edaf4ee57
                   0xefc2b3db87ff4f00c79dfa8f732a23c0e18587a73a839b7710234583cdd03db9
                   0xf1b6fe8fc2ab800e6d76ee975a002d3e67a60b51a62085a07289505b8d03f149
                   0xe827331b1fe7a2689fbc23d14cd21317c699596cbca222182a489322ece1fa74
                ),
                tx-index: u7,                                                               ;; CORRUPTED
                tree-depth: u4
            })))
            (err u4))
        
        (asserts! (not (try! (verify-merkle-proof
            (reverse-buff32 0x25c6a1f8c0b5be2bee1e8dd3478b4ec8f54bbc3742eaf90bfb5aed46cf217ad9)
            0xb152eca4364850f3424c7ac2b337d606c5ca0a3f96f1554f8db33d2f6f130bbe
            {
                hashes: (list
                   0xae1e670bdbf8ab984f412e6102c369aeca2ced933a1de74712ccda5edaf4ee57
                   0xefc2b3db87ff4f00c79dfa8f732a23c0e18587a73a839b7710234583cdd03db9
                   0xf1b6fe8fc2ab800e6d76ee975a002d3e67a60b51a62085a07289505b8d03f149
                   0xe827331b1fe7a2689fbc23d14cd21317c699596cbca222182a489322ece1fa74
                ),
                tx-index: u6,
                tree-depth: u3                                                              ;; CORRUPTED
            })))
            (err u5))

        (asserts! (is-eq ERR-PROOF-TOO-SHORT (unwrap-err-panic (verify-merkle-proof
            (reverse-buff32 0x25c6a1f8c0b5be2bee1e8dd3478b4ec8f54bbc3742eaf90bfb5aed46cf217ad9)
            0xb152eca4364850f3424c7ac2b337d606c5ca0a3f96f1554f8db33d2f6f130bbe
            {
                hashes: (list
                   0xae1e670bdbf8ab984f412e6102c369aeca2ced933a1de74712ccda5edaf4ee57
                   0xefc2b3db87ff4f00c79dfa8f732a23c0e18587a73a839b7710234583cdd03db9
                   0xf1b6fe8fc2ab800e6d76ee975a002d3e67a60b51a62085a07289505b8d03f149
                   0xe827331b1fe7a2689fbc23d14cd21317c699596cbca222182a489322ece1fa74
                ),
                tx-index: u6,                                                               ;; too long
                tree-depth: u5
            })))
            (err u6))
        (ok true)
    )
)

(define-public (unit-tests)
    (begin
        (print "unit tests")
        (asserts! (is-ok (read-slice-prefixes))
            (err u0))
        (asserts! (is-ok (read-slice-middles))
            (err u1))
        (asserts! (is-ok (read-ints))
            (err u2))
        (asserts! (is-ok (read-varints))
            (err u3))
        (asserts! (is-ok (read-varslices))
            (err u4))
        (asserts! (is-ok (test-parse-simple-bitcoin-txs))
            (err u5))
        (asserts! (is-ok (test-parse-bitcoin-headers))
            (err u6))
        (asserts! (is-ok (test-get-txid))
            (err u7))
        (asserts! (is-ok (test-verify-merkle-proof))
            (err u8))
        (ok u0)
    )
)

