//
//  String+Hex.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 12.07.18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

fileprivate var hexPrefix = "0x"

extension String {
    
    func stripHexPrefix() -> String {
        var hex = self
        if hex.hasPrefix(hexPrefix) {
            hex = String(hex.dropFirst(hexPrefix.count))
        }
        return hex
    }
    
    func addHexPrefix() -> String {
        return hexPrefix.appending(self)
    }
    
    func toHexString() -> String {
        guard let data = data(using: .utf8) else {
            return ""
        }
        return data.toHexString()
    }
}

extension Data {
    func dataToHexString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
    
    static func fromHex(_ hex: String) -> Data? {
        let string = hex.lowercased().stripHexPrefix()
        let array = Array<UInt8>(hex: string)
        if (array.count == 0) {
            if (hex == "0x" || hex == "") {
                return Data()
            } else {
                return nil
            }
        }
        return Data(array)
    }
    
    func constantTimeComparisonTo(_ other:Data?) -> Bool {
        guard let rhs = other else {return false}
        guard self.count == rhs.count else {return false}
        var difference = UInt8(0x00)
        for i in 0..<self.count { // compare full length
            difference |= self[i] ^ rhs[i] //constant time
        }
        return difference == UInt8(0x00)
    }
}
