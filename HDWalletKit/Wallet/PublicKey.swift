//
//  PublicKey.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation
import CryptoSwift
import secp256k1_swift

public struct PublicKey {
    public let rawPrivateKey: Data
    public let coin: Coin
    
    public init(privateKey: Data, coin: Coin) {
        self.rawPrivateKey = privateKey
        self.coin = coin
    }
    
    // NOTE: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
    public var address: String {
        switch coin {
        case .bitcoin: fallthrough
        case .bitcoinCash: fallthrough
        case .zcoin: fallthrough
        case .divi: fallthrough
        case .dash: fallthrough
        case .litecoin: return generateBtcAddress()
        case .neo: return generateNeoAddress()
        case .ethereum: return generateEthAddress()
        case .zilliqa: return generateZilAddress()
        }
    }
    
    func generateBtcAddress() -> String {
        let prefix = Data([coin.publicKeyHash])
        let publicKey = getPublicKey(compressed: true)
        let payload = RIPEMD160.hash(publicKey.sha256())
        let checksum = (prefix + payload).doubleSHA256.prefix(4)
        return Base58.encode(prefix + payload + checksum)
    }
    
    func generateNeoAddress() -> String {
        var publicKeyBytes = Data([coin.publicKeyHash])
        publicKeyBytes += getPublicKey(compressed: true)
        publicKeyBytes += Data([0xAC])
        let payload = RIPEMD160.hash(publicKeyBytes.sha256())
        let prefix = Data([0x17])
        let checksum = (prefix + payload).doubleSHA256.prefix(4)
        return Base58.encode(prefix + payload + checksum)
    }
    
    func generateEthAddress() -> String {
        let publicKey = getPublicKey(compressed: false)
        let formattedData = (Data(hex: coin.addressPrefix) + publicKey).dropFirst()
        let addressData = Crypto.sha3keccak256(data: formattedData).suffix(20)
        return coin.addressPrefix + EIP55.encode(addressData)
    }
    
    func generateZilAddress() -> String {
        let publicKey = getPublicKey(compressed: true)
        let addressData = publicKey.sha256().suffix(20)
        return coin.addressPrefix + EIP55.encode(addressData)
    }
    
    public func get() -> String {
        let publicKey = getPublicKey(compressed: true)
        return publicKey.toHexString()
    }
    
    public func getPublicKey(compressed: Bool) -> Data {
        return Crypto.generatePublicKey(data: rawPrivateKey, compressed: compressed)
    }
}
