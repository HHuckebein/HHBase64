//
//  Base64.swift
//  Base64
//
//  Created by Bernd Rabe on 04.04.16.
//  Copyright © 2016 RABE_IT Services. All rights reserved.
//

import Foundation

/** Base64Coding provides alphabet handling and base functionality
 to proof that the string is a valid base64 encoded string via
 `validityRegEX` (Regular expression tested on [RegExr](http://regexr.com/)).
 */
public enum Base64Coding {
    /** The default when encoding/decoding(iOS compatible) */
    case standard

    /** to be used when dealing with URI */
    case urlSafe
    
    var alphabet: [UInt8] {
        switch self {
        case .standard:
            return [65,   66,  67,  68,  69,  70,  71,  72,  73,  74,
                    75,   76,  77,  78,  79,  80,  81,  82,  83,  84,
                    85,   86,  87,  88,  89,  90,  97,  98,  99, 100,
                   101,  102, 103, 104, 105, 106, 107, 108, 109, 110,
                   111,  112, 113, 114, 115, 116, 117, 118, 119, 120,
                   121,  122,  48,  49,  50,  51,  52,  53,  54,  55,
                    56,   57,  43,  47,  61]

        case .urlSafe:
            return [65,   66,  67,  68,  69,  70,  71,  72,  73,  74,
                    75,   76,  77,  78,  79,  80,  81,  82,  83,  84,
                    85,   86,  87,  88,  89,  90,  97,  98,  99, 100,
                   101,  102, 103, 104, 105, 106, 107, 108, 109, 110,
                   111,  112, 113, 114, 115, 116, 117, 118, 119, 120,
                   121,  122,  48,  49,  50,  51,  52,  53,  54,  55,
                    56,   57,  45,  95,  61]

        }
    }
    
    /** Finds, for a given character at index `idx` the corresponding
     translated value out of the alphabet.
         
    - parameter idx: The character index.
    - parameter string: The string itself.
    - returns: The corresponding translated value.
    */
    func decodedValue(forIndex idx: Int, inString string: String) -> UInt8? {
        let index = string.utf8.index(string.utf8.startIndex, offsetBy: idx)
        if let idxPoint = alphabet.index(of: string.utf8[index]) {
            return UInt8(idxPoint) & UInt8.max
        }
        return nil
    }
    
    /** Returns wether a given string contains only the allowed characters.
     Ignore padding if decoding is .urlSafe.
     
    - parameter string: The string object to be decoded.
    - parameter ignorePadding: Determines if character check ends before padding characters.
    - returns: Wether the string contains only allowed characters.
    */
    func stringContainsIllegalCharacters(_ string: String, ignorePadding: Bool = false) -> Bool {
        if let regEx = self.validityRegEx {
            var range = NSMakeRange(0, string.characters.count)
            if ignorePadding {
                if string.hasSuffix("==") {
                    range.length = string.characters.count - 2
                } else if string.hasSuffix("=") {
                    range.length = string.characters.count - 1
                }
            }
            return regEx.numberOfMatches(in: string, options: [], range: range) == 1 ? false : true
        }
        return false
    }
}

private extension Base64Coding {
    /** The validation regular expression according to the coding case. */
    var validityRegEx: NSRegularExpression? {
        switch self {
        case .standard:
            do {
                let regex = try NSRegularExpression(pattern: "^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})$", options: .caseInsensitive)
                return regex
            } catch {
                return nil
            }
            
        case .urlSafe:
            do {
                let regex = try NSRegularExpression(pattern: "^(?:[A-Za-z0-9-_]{4})*(?:[A-Za-z0-9-_]{2}|[A-Za-z0-9-_]{3}|[A-Za-z0-9-_]{4})$", options: .caseInsensitive)
                return regex
            } catch {
                return nil
            }
        }
    }
}

public extension Base64Coding {
    subscript (position: Int) -> UInt8  {
        precondition(position >= 0 && position < alphabet.count, "out-of-range access on a alphabet")
        return alphabet[position]
    }
}

/** Defines, wether padding character will be added eventually.
 */
public enum Base64Padding {
    /** Add padding character if necessary. */
    case on
    
    /** Omit the final padding step, once encoding is complete. */
    case off
}

/** Possible errors thrown during decoding.
 */
public enum Base64Error: Error {
    /** Thrown when the input string contains characters not allowed for the given coding case. */
    case containsIllegalCharacters
    
    /** When alphabet handling fails. */
    case codingError
}

/** Provides base-64 en-/decoding for the standard and url safe alphabet.
 Encoding and Decoding follows RFC4648 which means e.g. that an error
 is thrown if an encoded strings contains illegal characters.
 When decoding .urlSafe encoded strings padding characters are ignored.
 */
public struct Base64 {
    /** Decode a base64 encoded string.
     
    - parameter string: The input string.
    - parameter coding: The decoding standard. Defaults to .standard.
    - returns: The decoded data object.
    - Throws: Throws an `Base64Error` error.
    */
    public static func decode(_ string: String, coding: Base64Coding = .standard) throws -> Data? {
        if string.isEmpty { return nil }
        
        if coding.stringContainsIllegalCharacters(string, ignorePadding: coding == .urlSafe) == true {
            throw Base64Error.containsIllegalCharacters
        }
        
        // don't treat padding characters
        var unreadBytes = string.characters.filter{ String($0) != "=" }.count

        var base = 0
        var decodedBytes = [UInt8]()
        
        while unreadBytes > 4 {
            guard
            let value0 = coding.decodedValue(forIndex: base + 0, inString: string),
            let value1 = coding.decodedValue(forIndex: base + 1, inString: string),
            let value2 = coding.decodedValue(forIndex: base + 2, inString: string),
            let value3 = coding.decodedValue(forIndex: base + 3, inString: string) else {
                throw Base64Error.codingError
            }
            
            decodedBytes.append((value0 << 2) | (value1 >> 4))
            decodedBytes.append((value1 << 4) | (value2 >> 2))
            decodedBytes.append((value2 << 6) | value3)

            base += 4
            unreadBytes -= 4
        }

        if unreadBytes > 1 {
            guard
                let value0 = coding.decodedValue(forIndex: base + 0, inString: string),
                let value1 = coding.decodedValue(forIndex: base + 1, inString: string) else {
                    throw Base64Error.codingError
            }
            decodedBytes.append((value0 << 2) | (value1 >> 4))
        }
        
        if unreadBytes > 2 {
            guard
                let value1 = coding.decodedValue(forIndex: base + 1, inString: string),
                let value2 = coding.decodedValue(forIndex: base + 2, inString: string) else {
                    throw Base64Error.codingError
            }
            decodedBytes.append((value1 << 4) | (value2 >> 2))
        }
        
        if unreadBytes > 3 {
            guard
                let value2 = coding.decodedValue(forIndex: base + 2, inString: string),
                let value3 = coding.decodedValue(forIndex: base + 3, inString: string) else {
                    throw Base64Error.codingError
            }
            decodedBytes.append((value2 << 6) | value3)
        }
        
        return decodedBytes.count != 0 ? Data(bytes: UnsafePointer<UInt8>(decodedBytes), count: decodedBytes.count) : nil
    }
    
    /** Encode some data of type `Data`.
     
    - parameter data: The input data.
    - parameter coding: The decoding standard. Defaults to .standard.
    - parameter padding: Add padding character if necessary. Defaults to .on.
    - returns: A base64 encoded string. In case of failure nil.
    */
    public static func encode(_ data: Data, coding: Base64Coding = .standard, padding: Base64Padding = .on) -> String? {
        if data.count == 0 { return nil }
        
        let inputArray = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
        var bytes = [UInt8]()
        
        var i = 0
        while i < inputArray.count - 2 {
            let base0 = inputArray[i]
            let base1 = inputArray[i + 1]
            let base2 = inputArray[i + 2]
            
            let value0 = coding[Int((base0 >> 2) & 0x3F)]
            let value1 = coding[Int(((base0 & 0x3) << 4) | ((base1 & 0xF0) >> 4))]
            let value2 = coding[Int(((base1 & 0xF) << 2) | ((base2 & 0xC0) >> 6))]
            let value3 = coding[Int(base2 & 0x3F)]

            bytes.append(value0)
            bytes.append(value1)
            bytes.append(value2)
            bytes.append(value3)
            
            i += 3
        }
        
        if i < inputArray.count {
            let base0 = inputArray[i]
            let base1 = i == inputArray.count - 1 ? 0 : inputArray[i + 1]

            let value0 = coding[Int((base0 >> 2) & 0x3F)]
            let value1 = coding[Int((base0 & 0x3) << 4)]
            let value2 = coding[Int((base0 & 0x3) << 4 | ((base1 & 0xF0) >> 4))]
            let value3 = coding[Int((base1 & 0xF) << 2)]
            
            bytes.append(value0)
            
            if i == inputArray.count - 1 {
                bytes.append(value1)
                if padding == .on {
                    bytes.append("=".utf8.first!)
                }
            } else {
                bytes.append(value2)
                bytes.append(value3)
            }
            
            if padding == .on {
                bytes.append("=".utf8.first!)
            }
        }
        return bytes.count == 0 ? nil : String(bytes: bytes, encoding: String.Encoding.utf8)
    }
}
