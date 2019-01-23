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
        performTest(dataTest: expectedVectors, coin: .zcoin)
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
        performTest(dataTest: expectedVectors, coin: .divi)
    }
    
    func testZilliqa() {
        let expectedVectors = """
            [
                    [
                        "0xeA5108634A593dD58371F4291D6ad66Bb5370049",
                        "ad16821790b4db11f93a5532f4c2df6361bfd406730863581263141108b56109"
                    ],
                    [
                        "0xDb245DA0267efb87AEF5986a2730249d66A02784",
                        "0cdf0b5a630d30cfee3b7b4f7457b8c061659d4fc248c3e7d4872109807bd556"
                    ]
            ]
            """
        performTest(dataTest: expectedVectors, coin: .zilliqa)
    }
    
    
    func performTest(dataTest:String, coin:Coin) {
        let vectors = try! JSONSerialization.jsonObject(with: dataTest.data(using: .utf8)!, options: []) as! [[String]]
        for i in 0 ..< mnemonics.count {
            let vector = vectors[i]
            let expected = (address: vector[0], key: vector[1])
            let seed = Mnemonic.createSeed(mnemonic: "able matrix tornado mix elephant issue jeans nice glue physical foster jacket")
            let wallet = Wallet.init(seed: seed, coin: coin)
            let account = wallet.generateAccount()
            XCTAssertEqual(account.address, expected.address)
            XCTAssertEqual(account.rawPrivateKey, expected.key)
            let pkFromWif = try! PrivateKey.init(pk: account.rawPrivateKey, coin: coin)
            XCTAssertEqual(pkFromWif.raw, account.privateKey.raw)
        }
    }
}
