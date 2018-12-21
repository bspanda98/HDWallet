//
//  NeoTests.swift
//  HDWalletKit_Tests
//
//  Created by LamND on 11/28/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import XCTest
@testable import HDWalletKit
@testable import GMEllipticCurveCrypto

class NeoTests: XCTestCase {
    func testNEO() {
        ECDSA.chosenCurve = ECDSA.secp256r1
        let testVectors = """
            [
                    [
                        "online ramp onion faculty trap clerk near rabbit busy gravity prize employ exit horse found slogan effort dash siren buzz sport pig coconut element",
                        "AeKd54zJdgqXy41NgH1PicXTVcz3RdRFdh",
                        "KxGtKtYTsxCW997F762Zn62C2e72gQ9XMPkkL2231Rc4GuvSCuba",
                        "03991d28c31abfc7024e416008b61d291a65270e02ec460364a36692f6e9d795fa"
                    ],
                    [
                        "mother barrel fantasy gain boy secret month brave require fade manual yellow swamp cargo survey initial basic small because shine dream mixture pink doll",
                        "AeA32nf9UTdCzruPnSfUcLR5NP3g7iL7aM",
                        "L5bDrbDSwXR3uRazTBuVuV9wZYAHesJrUnkao8hmzT15LB4FDsK3",
                        "036dbaf6bb55139f71ba5cd4c9732654b3cfad23de9d9261f9db8e6c9476ca4dc7"
                    ]
            ]
            """
        
        let vectors = try! JSONSerialization.jsonObject(with: testVectors.data(using: .utf8)!, options: []) as! [[String]]
        for vector in vectors {
            let wallet = Wallet.init(seed: Mnemonic.createSeed(mnemonic: vector[0]), coin: .neo)
            let account = wallet.generateAccount()
            let expected = (address: vector[1], key: vector[2], pub: vector[3])
//            print(wallet.privateKey.publicKey.get())
            XCTAssertEqual(account.rawPublicKey, expected.pub)
            XCTAssertEqual(account.rawPrivateKey, expected.key)
            XCTAssertEqual(account.address, expected.address)
        }
    }
}
