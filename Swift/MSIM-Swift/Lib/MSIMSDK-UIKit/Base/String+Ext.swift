//
//  String+Ext.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/29.
//

import Foundation
import CommonCrypto


public extension String {
    
    var md5: String! {
        let utf8 = cString(using: .utf8)
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
            return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    var sha1: String! {
        let str = self.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1(str, CC_LONG(str!.count - 1), &digest)
                return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    var sha256: String! {
        let str = self.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(str, CC_LONG(str!.count - 1), &digest)
                return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    var sha512: String! {
        let str = self.cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        CC_SHA512(str, CC_LONG(str!.count - 1), &digest)
                return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    /// 截取到任意位置
    func subString(to: Int) -> String {
        let index: String.Index = self.index(startIndex, offsetBy: to)
        return String(self[..<index])
    }
    /// 从任意位置开始截取
    func subString(from: Int) -> String {
        let index: String.Index = self.index(startIndex, offsetBy: from)
        return String(self[index ..< endIndex])
    }
    /// 从任意位置开始截取到任意位置
    func subString(from: Int, to: Int) -> String {
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex...endIndex])
    }
    //使用下标截取到任意位置
    subscript(to: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: to)
        return String(self[..<index])
    }
    //使用下标从任意位置开始截取到任意位置
    subscript(from: Int, to: Int) -> String {
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex...endIndex])
    }
}
