//
//  Base64.swift
//  Base64
//
//  Created by Bernd Rabe on 04.04.16.
//  Copyright © 2016 RABE_IT Services. All rights reserved.
//

import Foundation

/// Base64Coding provides alphabet handling and base functionality to proof that the string is a valid base64 encoded string via
/// `validityRegEX` (Regular expression tested on [RegExr](http://regexr.com/)).
///
public enum Base64Coding {
    /// The default when encoding/decoding(iOS compatible).
    case standard

    /// to be used when dealing with URI.
    case urlSafe

    /// The alphabets used in decoding/encoding.
    var alphabet: [UInt8] {
        switch self {
        case .standard:
            return [65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
                    75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
                    85, 86, 87, 88, 89, 90, 97, 98, 99, 100,
                    101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
                    111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
                    121, 122, 48, 49, 50, 51, 52, 53, 54, 55,
                    56, 57, 43, 47, 61]

        case .urlSafe:
            return [65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
                    75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
                    85, 86, 87, 88, 89, 90, 97, 98, 99, 100,
                    101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
                    111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
                    121, 122, 48, 49, 50, 51, 52, 53, 54, 55,
                    56, 57, 45, 95, 61]

        }
    }

    /// Finds, for a given character at index `idx` the corresponding translated value out of the alphabet.
    /// - Parameters:
    ///   - idx: The character index.
    ///   - string: The string itself.
    /// - Returns: The corresponding translated value.
    func decodedValue(forIndex idx: Int, inString string: String) -> UInt8? {
        let index = string.utf8.index(string.utf8.startIndex, offsetBy: idx)
        if let idxPoint = alphabet.firstIndex(of: string.utf8[index]) {
            return UInt8(idxPoint) & UInt8.max
        }
        return nil
    }

    /// Returns wether a given string contains only the allowed characters. Ignore padding if decoding is .urlSafe.
    /// - Parameters:
    ///   - string: The string object to be decoded.
    ///   - ignorePadding: Determines if character check ends before padding characters.
    /// - Returns: Wether the string contains only allowed characters.
    func stringContainsIllegalCharacters(_ string: String, ignorePadding: Bool = false) -> Bool {
        if let regEx = self.validityRegEx {
            var range = NSRange(location: 0, length: string.count)
            if ignorePadding {
                if string.hasSuffix("==") {
                    range.length = string.count - 2
                } else if string.hasSuffix("=") {
                    range.length = string.count - 1
                }
            }
            return regEx.numberOfMatches(in: string, options: [], range: range) == 1 ? false : true
        }
        return false
    }
}

private extension Base64Coding {
    /// The validation regular expression according to the coding case.
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

extension Base64Coding {
    /// Used during decoding/encoding
    ///
    /// Parameter position: The position within the `alphabet`.
    subscript (position: Int) -> UInt8 {
        precondition(position >= 0 && position < alphabet.count, "out-of-range access on a alphabet")
        return alphabet[position]
    }
}

/// Defines, wether padding character will be added eventually.
public enum Base64Padding {
    /// Add padding character if necessary.
    case on

    /// Omit the final padding step, once encoding is complete.
    case off
}

/// Possible errors thrown during decoding.
public enum Base64Error: Error {
    /// Thrown when the input string contains characters not allowed for the given coding case.
    case containsIllegalCharacters

    /// When alphabet handling fails.
    case codingError
}

/// Provides base-64 en-/decoding for the standard and url safe alphabet.
/// Encoding and Decoding follows RFC4648 which means e.g. that an error
///  is thrown if an encoded strings contains illegal characters.
///  When decoding .urlSafe encoded strings padding characters are ignored.
///
public enum Base64 {
    /// Decode a base64 encoded string.
    /// - Parameters:
    ///   - string: The input string.
    ///   - coding: The decoding standard. Defaults to .standard
    /// - Throws: Throws an `Base64Error` error.
    /// - Returns: The decoded data object.
    public static func decode(_ string: String, coding: Base64Coding = .standard) throws -> Data? {
        if string.isEmpty { return nil }

        if coding.stringContainsIllegalCharacters(string, ignorePadding: coding == .urlSafe) == true {
            throw Base64Error.containsIllegalCharacters
        }

        // don't treat padding characters
        let unreadBytesArray: [Character] = string.filter({ String($0) != "=" })
        var unreadBytes = unreadBytesArray.count

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
        guard decodedBytes.isEmpty == false else { return nil }
        guard let unsafePointer = decodedBytes.withUnsafeBufferPointer({ $0.baseAddress }) else { return nil }
        return decodedBytes.isEmpty == false ? Data(bytes: unsafePointer, count: decodedBytes.count) : nil
    }

    /// Encode some data of type `Data`.
    /// - Parameters:
    ///   - data: The input data.
    ///   - coding: The decoding standard. Defaults to .standard.
    ///   - padding: Add padding character if necessary. Defaults to .on.
    /// - Returns: A base64 encoded string. In case of failure nil.
    public static func encode(_ data: Data, coding: Base64Coding = .standard, padding: Base64Padding = .on) -> String? {
        if data.isEmpty { return nil }

        let inputArray = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
        var bytes = [UInt8]()

        var i = 0
        while i < inputArray.count - 2 {
            let base0 = inputArray[i]
            let base1 = inputArray[i + 1]
            let base2 = inputArray[i + 2]

            let value0 = coding[Int((base0 >> 2) & 0x3F)]

            var first = Int((base0 & 0x3) << 4)
            var second = Int((base1 & 0xF0) >> 4)
            let value1 = coding[first | second]

            first = Int((base1 & 0xF) << 2)
            second = Int((base2 & 0xC0) >> 6)
            let value2 = coding[first | second]
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

            let first = Int((base0 & 0x3) << 4)
            let second = Int((base1 & 0xF0) >> 4)
            let value2 = coding[first | second]
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
        return bytes.isEmpty ? nil : String(bytes: bytes, encoding: .utf8)
    }
}
