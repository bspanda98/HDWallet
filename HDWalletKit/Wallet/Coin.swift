//
//  Coin.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/3/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

public enum Coin {
    case bitcoin
    case ethereum
    case zilliqa
    case litecoin
    case dash
    case bitcoinCash
    case neo
    case zcoin
    case divi
    
    //https://github.com/satoshilabs/slips/blob/master/slip-0132.md
    public var privateKeyVersion: UInt32 {
        switch self {
        case .litecoin: return 0x019D9CFE
        default: return 0x0488ADE4
        }
    }
    
    public var publicKeyVersion: UInt32 {
        switch self {
        case .litecoin: return 0x019DA462
        default: return 0x0488B21E
        }
    }
    
    public var publicKeyHash: UInt8 {
        switch self {
        case .litecoin: return 0x30
        case .dash: return 0x4c
        case .zcoin: return 0x52
        case .divi: return 30
        case .neo: return 0x21
        default: return 0x00
        }
    }
    
    public var scripthash: UInt8 {
        switch self {
        case .dash: return 0x10
        case .zcoin: return 0x07
        case .divi: return 13
        default: return 0x05
        }
    }
    
    //https://www.reddit.com/r/litecoin/comments/6vc8tc/how_do_i_convert_a_raw_private_key_to_wif_for/
    public var wifPreifx: UInt8 {
        switch self {
        case .litecoin: return 0xB0
        case .dash: return 0xcc
        case .zcoin: return 0xd2
        case .divi: return 0xd4
        default: return 0x80
        }
    }
    
    public var addressPrefix:String {
        switch self {
        case .zilliqa: fallthrough
        case .ethereum: return "0x"
        default: return ""
        }
    }
    
    public var masterSecret:String {
        switch self {
        case .neo: return "Nist256p1 seed"
        default: return "Bitcoin seed"
        }
    }
    
    
    public var coinType: UInt32 {
        switch self {
        case .bitcoin: return 0
        case .litecoin: return 2
        case .dash: return 5
        case .ethereum: return 60
        case .bitcoinCash: return 145
        case .zcoin: return 136
        case .divi: return 301
        case .neo: return 888
        case .zilliqa: return 8888
        }
    }
    
    public func validatePrivateKey(_ privateKey:String) -> Bool {
        switch self {
        case .zilliqa: fallthrough
        case .ethereum:
            let raw = Data.init(hex: privateKey)
            return ECDSA.secp256k1.generatePublicKey(privateKeyData: raw, isCompression: true) != nil
        default:
            let decodedPk = Base58.bytesFromBase58(privateKey)
            guard decodedPk.count > 4 else {return false}
            let checksumDropped = decodedPk.prefix(decodedPk.count - 4)
            guard checksumDropped.count == (1 + 32) || checksumDropped.count == (1 + 32 + 1) else {
                return false
            }
        }
        return true
    }
    
    public func validateAddress(_ address:String) -> Bool {
        switch self {
        case .zilliqa: fallthrough
        case .ethereum:
            guard let data = Data.fromHex(address) else {return false}
            guard data.count == 20 else {return false}
            if !address.hasPrefix("0x") {
                return false
            }
        default:
            let decoded = Data(Base58.bytesFromBase58(address))
            guard decoded.count > 4 else {return false}
            let checksum = decoded.suffix(4)
            let pubKeyHash = decoded.dropLast(4)
            let checksumConfirm = pubKeyHash.doubleSHA256.prefix(4)
            guard checksum == checksumConfirm else { return false }
            let prefix = self == .neo ? Data([0x17]) : Data([publicKeyHash])
            if pubKeyHash.prefix(prefix.count) == prefix {return true}
            let scrypt = Data([scripthash])
            return pubKeyHash.prefix(scrypt.count) == scrypt
        }
        return true
    }
}
