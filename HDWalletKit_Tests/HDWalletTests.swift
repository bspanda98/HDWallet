//
//  HDWalletTests.swift
//  HDWalletKit_Tests
//
//  Created by LamND on 1/17/19.
//  Copyright © 2019 Essentia. All rights reserved.
//

import XCTest
@testable import HDWalletKit

var mnemonics = [
    "transfer stomach dream float clip inside february resemble champion copper draft enact",
    "puppy coral eternal great alcohol elite humble fitness key dawn circle area"
]
class MidasWalletTests: XCTestCase {
    
    func testZcoinAddressGeneration() {
        let expectedVectors = """
            [
                    [
                        "aLUADhxq9uhiyhBMTonDYrkFQoQifmXpJS",
                        "Y7wtJNT46mX1fMPYhPiXQTkNwcJqpHrki3h7AqFRGtdNnp175L6a"
                    ],
                    [
                        "aLZBCqFXBvS1aN2WhLQKfU2YMVNK6D9GPx",
                        "Y6FXnZ2vf93K1zhC3F8utBi5bUg71ExL71ZmRaFRDYtb2qpR2G71"
                    ]
            ]
            """
        let vectors = try! JSONSerialization.jsonObject(with: expectedVectors.data(using: .utf8)!, options: []) as! [[String]]
        for i in 0 ..< mnemonics.count {
            let vector = vectors[i]
            let expected = (address: vector[0], key: vector[1])
            let seed = Mnemonic.createSeed(mnemonic: mnemonics[i])
            let wallet = Wallet.init(seed: seed, coin: .zcoin)
            let account = wallet.generateAccount()
            XCTAssertEqual(account.address, expected.address)
            XCTAssertEqual(account.rawPrivateKey, expected.key)
            let pkFromWif = try! PrivateKey.init(pk: account.rawPrivateKey, coin: .zcoin)
            XCTAssertEqual(pkFromWif.raw, account.privateKey.raw)
        }
    }
    
    func testDIVI() {
        let expectedVectors = """
            [
                    [
                        "DCD3AM3wS3ZMb7Fi72KEcvRJFBwmhMwZwB",
                        "YQWzf4MHMuZ3Zjpvr2VvHZJC75oS8bp2XakJcdD3Ru9tzyQo8Z7c"
                    ],
                    [
                        "DHs9s7uMWR6R4WjLC8FAu7Qyzg4aWGyVTT",
                        "YVUY7X836izQacPrGvLSPeopTPaZyBS7rzMyQ6oJHbsNnk4m5rg2"
                    ]
            ]
            """
        let vectors = try! JSONSerialization.jsonObject(with: expectedVectors.data(using: .utf8)!, options: []) as! [[String]]
        for i in 0 ..< mnemonics.count {
            let vector = vectors[i]
            let expected = (address: vector[0], key: vector[1])
            let seed = Mnemonic.createSeed(mnemonic: mnemonics[i])
            let wallet = Wallet.init(seed: seed, coin: .divi)
            let account = wallet.generateAccount()
            XCTAssertEqual(account.address, expected.address)
            XCTAssertEqual(account.rawPrivateKey, expected.key)
            let pkFromWif = try! PrivateKey.init(pk: account.rawPrivateKey, coin: .zcoin)
            XCTAssertEqual(pkFromWif.raw, account.privateKey.raw)
        }
    }
    
//    func testZilliqa() {
//        let pk = try! PrivateKey.init(pk: "95F661DC7CE2E4886AE8BAD1B2E7315B78A94DD09C43755F07D4A1BAE0B2A929", coin: .zilliqa)
//        let account = Account.init(privateKey: pk)
//        print(account.address)
//        print(account.rawPublicKey)
//        print(account.rawPrivateKey)
//    }
}
