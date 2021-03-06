//
//  PrivateKey.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

enum PrivateKeyType {
    case hd
    case nonHd
}

public struct PrivateKey {
    public let raw: Data
    public let chainCode: Data
    public let index: UInt32
    public let coin: Coin
    private var keyType: PrivateKeyType
    
    public init(seed: Data, coin: Coin) {
        let output = Crypto.HMACSHA512(key: coin.masterSecret.data(using: .ascii)!, data: seed)
        self.raw = output[0..<32]
        self.chainCode = output[32..<64]
        self.index = 0
        self.coin = coin
        self.keyType = .hd
    }
    
    public init(pk: String, coin: Coin) throws {
        switch coin {
        case .zilliqa: fallthrough
        case .ethereum:
            self.raw = Data(hex: pk)
        default:
            let decodedPk = Base58.bytesFromBase58(pk)
            guard decodedPk.count > 4 else {throw HDWalletKitError.cryptoError(HDWalletKitError.CryptoError.failedToEncode(element: pk))}
            let checksumDropped = decodedPk.prefix(decodedPk.count - 4)
            guard checksumDropped.count == (1 + 32) || checksumDropped.count == (1 + 32 + 1) else {
                throw HDWalletKitError.cryptoError(HDWalletKitError.CryptoError.failedToEncode(element: pk))
            }
            let wifData = Data(decodedPk).dropLast(4).dropFirst()
            self.raw = wifData.prefix(32)
        }
        self.chainCode = Data(capacity: 32)
        self.index = 0
        self.coin = coin
        self.keyType = .nonHd
    }
    
    private init(privateKey: Data, chainCode: Data, index: UInt32, coin: Coin) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.index = index
        self.coin = coin
        self.keyType = .hd
    }
    
    public var publicKey: PublicKey {
        return PublicKey(privateKey: raw, coin: coin)
    }
    
    private func wif() -> String {
        var data = Data()
        data += coin.wifPreifx
        data += raw
        data += UInt8(0x01)
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }
    
    public func get() -> String {
        switch self.coin {
        case .bitcoin: fallthrough
        case .litecoin: fallthrough
        case .dash: fallthrough
        case .neo: fallthrough
        case .zcoin: fallthrough
        case .divi: fallthrough
        case .bitcoinCash:
            return self.wif()
        case .zilliqa: fallthrough
        case .ethereum:
            return self.raw.toHexString()
        }
    }
    
    public func derived(at node:DerivationNode) -> PrivateKey {
        guard keyType == .hd else { fatalError() }
        
        if coin == .neo { ECDSA.chosenCurve = ECDSA.secp256r1 }
        defer {
            ECDSA.chosenCurve = ECDSA.secp256k1
        }
        
        let edge: UInt32 = 0x80000000
        guard (edge & node.index) == 0 else { fatalError("Invalid child index") }
        
        var data = Data()
        switch node {
        case .hardened:
            data += UInt8(0)
            data += raw
        case .notHardened:
            data += Crypto.generatePublicKey(data: raw, compressed: true)
        }
        
        let derivingIndex = CFSwapInt32BigToHost(node.hardens ? (edge | node.index) : node.index)
        data += derivingIndex
        
        let digest = Crypto.HMACSHA512(key: chainCode, data: data)
        let factor = BInt(data: digest[0..<32])
        
        let curveOrder = BInt(hex: ECDSA.chosenCurve.chosenCurveN())!
        let derivedPrivateKey = ((BInt(data: raw) + factor) % curveOrder).data
        let derivedChainCode = digest[32..<64]
        return PrivateKey(
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            index: derivingIndex,
            coin: coin
        )
    }
    
    public func sign(hash: Data) throws -> Data {
        return try Crypto.sign(hash, privateKey: raw)
    }
}

