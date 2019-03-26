//
//  ECDSA.swift
//  ECDSA
//
//  Created by yuzushioh on 2018/01/25.
//  Copyright © 2018 yuzushioh. All rights reserved.
//

import Foundation
import secp256k1_swift
import GMEllipticCurveCrypto

public protocol secp256 {
    func generatePublicKey(with privateKey: Data, isCompressed: Bool) -> Data
    func chosenCurveN() -> String
}

public final class ECDSA:secp256 {
    public static var chosenCurve:secp256 = ECDSA.secp256k1
    public static let secp256k1 = ECDSA()
    public static let secp256r1 = ECDSA_secp256r1()
    
    public func generatePublicKey(with privateKey: Data, isCompressed: Bool) -> Data {
        return generatePublicKey(privateKeyData: privateKey, isCompression: isCompressed)!
    }
    public func chosenCurveN() -> String {
        return "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141"
    }
    func generatePublicKey(privateKeyData: Data, isCompression: Bool) -> Data? {
        
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        
        let prvKey = privateKeyData.bytes
        var pKey = secp256k1_pubkey()
        
        var result = SecpResult(secp256k1_ec_pubkey_create(context, &pKey, prvKey))
        if result == .failure {
            return nil
        }
        let compressedKeySize = 33
        let decompressedKeySize = 65
        
        let keySize = isCompression ? compressedKeySize : decompressedKeySize
        let serealizedKey = UnsafeMutablePointer<UInt8>.allocate(capacity: keySize)
        
        var keySizeT = size_t(keySize)
        let copressingKey = isCompression ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        
        result = SecpResult(secp256k1_ec_pubkey_serialize(context,
                                                          serealizedKey,
                                                          &keySizeT,
                                                          &pKey,
                                                          copressingKey))
        if result == .failure {
            return nil
        }
        
        secp256k1_context_destroy(context)
        
        let data = Data(bytes: serealizedKey, count: keySize)
        free(serealizedKey)
        return data
    }
}


public final class ECDSA_secp256r1 : secp256 {
    public func generatePublicKey(with privateKey: Data, isCompressed: Bool) -> Data {
        let crypto = GMEllipticCurveCrypto.init(curve: GMEllipticCurveSecp256r1)!
        crypto.privateKey = privateKey
        crypto.compressedPublicKey = isCompressed
        return crypto.publicKey
    }
    
    public func chosenCurveN() -> String {
        return "FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551"
    }
}
