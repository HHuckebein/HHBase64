//
//  Base64Tests.swift
//  Base64Tests
//
//  Created by Bernd Rabe on 04.04.16.
//  Copyright © 2016 RABE_IT Services. All rights reserved.
//

import XCTest
import Hamcrest
@testable import Base64

class Base64Tests: XCTestCase {
    
    let illegalEncodedStrings_StandardAlphabet = ["MA\\=", "QQ-=", "Q=JDRE_GR0g="]
    let illegalEncodedStrings_URLSafeAlphabet  = ["+A", "/\\Q", "QUJDR=VmZ2hpams"]
    
    let legalEncodedStandardCharacterStrings = ["Zg==", "Zm8=", "Zm9v", "Zm9vYg==", "Zm9vYmE=", "Zm9vYmFy", "MA==", "QQ==",  "QUJDREVGR0g=", "QUJDREVGR0hJ", "QTFCMkMzRDRINQ==", "QTFCMkMzRDRINStaL2cz"]
    let legalDecodedStandardCharacterStrings = ["f",    "fo",   "foo",  "foob",     "fooba",    "foobar",   "0",     "A",    "ABCDEFGH",     "ABCDEFGHI",    "A1B2C3D4H5",       "A1B2C3D4H5+Z/g3"]
    
    let legalEncodedURLSafeCharacterStrings  = ["Zg", "Zm8", "Zm9v", "Zm9vYg", "Zm9vYmE", "Zm9vYmFy", "MA", "QQ", "QUJDREVmZ2hpams", "QTBCQ0RFZmdoaWprMQ", "QTFCMkMzRDRhMWIyYzNiNA", "QTFCMkMzRDRINStaL2cz"]
    let legalDecodedURLSafeCharacterStrings  = ["f",  "fo",  "foo",  "foob",   "fooba",   "foobar",   "0",  "A",  "ABCDEfghijk",     "A0BCDEfghijk1",      "A1B2C3D4a1b2c3b4",       "A1B2C3D4H5+Z/g3"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Alphabet
    
    
    func test_decode_StandardAlphabet_success() {
        let coding = Base64Coding.standard
        let string = "ABCDEFGEHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        for (index, _) in string.utf8.enumerated() {
            assertThat(coding.decodedValue(forIndex: index, inString: string), present())
        }
    }
    
    func test_decode_StandardAlphabet_failure() {
        let coding = Base64Coding.standard
        let string = "😀💃#_´?"
        for (index, _) in string.utf8.enumerated() {
            assertThat(coding.decodedValue(forIndex: index, inString: string), nilValue())
        }
    }
    
    func test_StandardAlphabet_containsIllegalCharacter() {
        let coding = Base64Coding.standard
        for string in illegalEncodedStrings_StandardAlphabet {
            assertThat(coding.stringContainsIllegalCharacters(string) == true)
        }
    }
    
    func test_decode_URLSafeAlphabet_success() {
        let coding = Base64Coding.urlSafe
        let string = "ABCDEFGEHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
        for (index, _) in string.utf8.enumerated() {
            assertThat(coding.decodedValue(forIndex: index, inString: string), present())
        }
    }
    
    func test_decode_URLSafeAlphabet_failure() {
        let coding = Base64Coding.urlSafe
        let string = "😀💃#´+:"
        for (index, value) in string.utf8.enumerated() {
            print(String(value))
            print(assertThat(coding.decodedValue(forIndex: index, inString: string), nilValue()))
        }
    }
    
    func test_URLSafeAlphabet_containsIllegalCharacter() {
        let coding = Base64Coding.urlSafe
        for string in illegalEncodedStrings_URLSafeAlphabet {
            assertThat(coding.stringContainsIllegalCharacters(string) == true)
        }
    }
    
    func test_StandardAlphabet_containsLegalCharacter() {
        let coding = Base64Coding.standard
        for string in legalEncodedStandardCharacterStrings {
            assertThat(coding.stringContainsIllegalCharacters(string) == false)
        }
    }
    
    func test_URLSafeAlphabet_containsLegalCharacter() {
        let coding = Base64Coding.urlSafe
        for string in legalEncodedURLSafeCharacterStrings {
            assertThat(coding.stringContainsIllegalCharacters(string) == false)
        }
    }
    
    func test_StandardAlphabet_UnicodeScalar () {
        let coding = Base64Coding.standard
        let a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        for index in 0..<coding.alphabet.count {
            let characterA = UnicodeScalar(a.utf8[a.utf8.index(a.utf8.startIndex, offsetBy: index)])
            let characterB = UnicodeScalar(coding[index])
            assertThat(characterA == characterB)
        }
    }
    
    func test_URLSafeAlphabet_UnicodeScalar () {
        let coding = Base64Coding.urlSafe
        let a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_="
        for index in 0..<coding.alphabet.count {
            let characterA = UnicodeScalar(a.utf8[a.utf8.index(a.utf8.startIndex, offsetBy: index)])
            let characterB = UnicodeScalar(coding[index])
            assertThat(characterA == characterB)
        }
    }
    
    // MARK: Decoding
    
    func test_decode_throwsIfIllegalCharacters_StandardAlphabet () {
        for string in illegalEncodedStrings_StandardAlphabet {
            assertThrows(try Base64.decode(string), Base64Error.containsIllegalCharacters)
        }
    }
    
    func test_decode_throwsIfIllegalCharacters_URLSafeAlphabet () {
        for string in illegalEncodedStrings_URLSafeAlphabet {
            assertThrows(try Base64.decode(string, coding: .urlSafe), Base64Error.containsIllegalCharacters)
        }
    }
    
    func test_decode_StandardAlphabet_Strings () {
        for idx in 0..<legalEncodedStandardCharacterStrings.count {
            let eString = legalEncodedStandardCharacterStrings[idx]
            let dString = legalDecodedStandardCharacterStrings[idx]
            do {
                if let data = try Base64.decode(eString), let string = String(data: data, encoding: String.Encoding.utf8)  {
                    assertThat(string == dString)
                } else {
                    XCTFail()
                }
                
            } catch {
                XCTFail("\(error)")
            }
        }
    }
    
    func test_decode_URLSafeAlphabet_Strings () {
        for idx in 0..<legalEncodedURLSafeCharacterStrings.count {
            let eString = legalEncodedURLSafeCharacterStrings[idx]
            let dString = legalDecodedURLSafeCharacterStrings[idx]
            do {
                if let data = try Base64.decode(eString, coding: .urlSafe), let string = String(data: data, encoding: String.Encoding.utf8)  {
                    assertThat(string == dString)
                } else {
                    XCTFail()
                }
                
            } catch {
                XCTFail("\(error)")
            }
        }
    }
    
    // MARK: - Encoding
    // MARK: Encoding/Decoding sample data taken from RFC4648
    // https://tools.ietf.org/pdf/rfc4648.pdf
    //
    func test_encode_URLSafe_Data01 () {
        let uInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
        let data  = Data(bytes: UnsafePointer<UInt8>(uInt8Array), count: uInt8Array.count)
        let expectedBase64 = "FPucA9l-"
        
        if let encodedString = Base64.encode(data, coding: .urlSafe) {
            assertThat(encodedString == expectedBase64)
        } else {
            XCTFail()
        }
    }
    
    func test_encode_URLSafe_Data02 () {
        let uInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
        let data  = Data(bytes: UnsafePointer<UInt8>(uInt8Array), count: uInt8Array.count)
        let expectedBase64 = "FPucA9k"
        
        if let encodedString = Base64.encode(data, coding: .urlSafe, padding: .off) {
            assertThat(encodedString == expectedBase64)
        } else {
            XCTFail()
        }
    }
    
    func test_encode_URLSafe_Data03 () {
        let uInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03]
        let data  = Data(bytes: UnsafePointer<UInt8>(uInt8Array), count: uInt8Array.count)
        let expectedBase64 = "FPucAw"
        
        if let encodedString = Base64.encode(data, coding: .urlSafe, padding: .off) {
            assertThat(encodedString == expectedBase64)
        } else {
            XCTFail()
        }
    }
    
    func test_decode_URLSafe_01 () {
        do {
            let orgUInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
            let encodedString = "FPucA9l-"
            
            if let data = try Base64.decode(encodedString, coding: .urlSafe) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(orgUInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == orgUInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_decode_URLSafe_02 () {
        do {
            let orgUInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
            let encodedString = "FPucA9k"
            
            if let data = try Base64.decode(encodedString, coding: .urlSafe) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(orgUInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == orgUInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_decode_URLSafe_03 () {
        do {
            let orgUInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03]
            let encodedString = "FPucAw=="
            
            if let data = try Base64.decode(encodedString, coding: .urlSafe) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(orgUInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == orgUInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_encode_Standard_Data01 () {
        let uInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
        let data  = Data(bytes: UnsafePointer<UInt8>(uInt8Array), count: uInt8Array.count)
        let expectedBase64 = "FPucA9l+"
        
        if let encodedString = Base64.encode(data) {
            assertThat(encodedString == expectedBase64)
        } else {
            XCTFail()
        }
    }
    
    func test_encode_Standard_Data02 () {
        let uInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
        let data  = Data(bytes: UnsafePointer<UInt8>(uInt8Array), count: uInt8Array.count)
        let expectedBase64 = "FPucA9k="
        
        if let encodedString = Base64.encode(data) {
            assertThat(encodedString == expectedBase64)
        } else {
            XCTFail()
        }
    }
    
    func test_encode_Standard_Data03 () {
        let uInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03]
        let data  = Data(bytes: UnsafePointer<UInt8>(uInt8Array), count: uInt8Array.count)
        let expectedBase64 = "FPucAw=="
        
        if let encodedString = Base64.encode(data) {
            assertThat(encodedString == expectedBase64)
        } else {
            XCTFail()
        }
    }
    
    func test_decode_Standard_01 () {
        do {
            let orgUInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
            let encodedString = "FPucA9l+"
            
            if let data = try Base64.decode(encodedString) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(orgUInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == orgUInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func test_decode_Standard_02 () {
        do {
            let orgUInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
            let encodedString = "FPucA9k="
            
            if let data = try Base64.decode(encodedString) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(orgUInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == orgUInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func test_decode_Standard_03 () {
        do {
            let orgUInt8Array:[UInt8] = [0x14, 0xFB, 0x9C, 0x03]
            let encodedString = "FPucAw=="
            
            if let data = try Base64.decode(encodedString) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(orgUInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == orgUInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    // MARK: Helper
    
    func arrayFromData(_ data: Data) -> [UInt8] {
        let count = data.count / MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        return array
    }
}
