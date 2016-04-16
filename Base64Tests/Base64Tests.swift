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
    
    let legalEncodedStandardCharacterStrings = ["MA==", "QQ==", "QUJDREVGR0g=", "QUJDREVGR0hJ", "QTFCMkMzRDRINQ==", "QTFCMkMzRDRINStaL2cz"]
    let legalDecodedStandardCharacterStrings = ["0", "A", "ABCDEFGH", "ABCDEFGHI", "A1B2C3D4H5", "A1B2C3D4H5+Z/g3"]
    
    let legalEncodedURLSafeCharacterStrings  = ["MA", "QQ", "QUJDREVmZ2hpams", "QTBCQ0RFZmdoaWprMQ", "QTFCMkMzRDRhMWIyYzNiNA", "QTFCMkMzRDRINStaL2cz"]
    let legalDecodedURLSafeCharacterStrings  = ["0", "A", "ABCDEfghijk", "A0BCDEfghijk1", "A1B2C3D4a1b2c3b4", "A1B2C3D4H5+Z/g3"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: Alphabet 
    
    
    func test_StandardAlphabet_containsIllegalCharacter() {
        let coding = Base64Coding.Standard
        for string in illegalEncodedStrings_StandardAlphabet {
            assertThat(coding.stringContainsIllegalCharacters(string) == true)
        }
    }
    
    func test_URLSafeAlphabet_containsIllegalCharacter() {
        let coding = Base64Coding.URLSafe
        for string in illegalEncodedStrings_URLSafeAlphabet {
            assertThat(coding.stringContainsIllegalCharacters(string) == true)
        }
    }
    
    func test_StandardAlphabet_containsLegalCharacter() {
        let coding = Base64Coding.Standard
        for string in legalEncodedStandardCharacterStrings {
            assertThat(coding.stringContainsIllegalCharacters(string) == false)
        }
    }
    
    func test_URLSafeAlphabet_containsLegalCharacter() {
        let coding = Base64Coding.URLSafe
        for string in legalEncodedURLSafeCharacterStrings {
            assertThat(coding.stringContainsIllegalCharacters(string) == false)
        }
    }
    
    func test_StandardAlphabet_UnicodeScalar () {
        let coding = Base64Coding.Standard
        let a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        for index in 0..<coding.alphabet.count {
            let characterA = UnicodeScalar(a.utf8[a.utf8.startIndex.advancedBy(index)])
            let characterB = UnicodeScalar(coding[index]!)
            assertThat(characterA == characterB)
        }
    }
    
    func test_URLSafeAlphabet_UnicodeScalar () {
        let coding = Base64Coding.URLSafe
        let a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_="
        for index in 0..<coding.alphabet.count {
            let characterA = UnicodeScalar(a.utf8[a.utf8.startIndex.advancedBy(index)])
            let characterB = UnicodeScalar(coding[index]!)
            assertThat(characterA == characterB)
        }
    }
    
    // MARK: Decoding
    
    func test_decode_throwsIfIllegalCharacters_StandardAlphabet () {
        for string in illegalEncodedStrings_StandardAlphabet {
            assertThrows(try Base64.decode(string), Base64Error.ContainsIllegalCharacters)
        }
    }

    func test_decode_throwsIfIllegalCharacters_URLSafeAlphabet () {
        for string in illegalEncodedStrings_URLSafeAlphabet {
            assertThrows(try Base64.decode(string, coding: .URLSafe), Base64Error.ContainsIllegalCharacters)
        }
    }
    
    func test_decode_StandardAlphabet_Strings () {
        for idx in 0..<legalEncodedStandardCharacterStrings.count {
            let eString = legalEncodedStandardCharacterStrings[idx]
            let dString = legalDecodedStandardCharacterStrings[idx]
            do {
                if let data = try Base64.decode(eString), let string = String(data: data, encoding: NSUTF8StringEncoding)  {
                    assertThat(string == dString)
                } else {
                    XCTFail()
                }
                
            } catch {
                XCTFail()
            }
        }
    }

    func test_decode_URLSafeAlphabet_Strings () {
        for idx in 0..<legalEncodedURLSafeCharacterStrings.count {
            let eString = legalEncodedURLSafeCharacterStrings[idx]
            let dString = legalDecodedURLSafeCharacterStrings[idx]
            do {
                if let data = try Base64.decode(eString, coding: .URLSafe), let string = String(data: data, encoding: NSUTF8StringEncoding)  {
                    assertThat(string == dString)
                } else {
                    XCTFail()
                }
                
            } catch {
                XCTFail()
            }
        }
    }
    
    // MARK: Encoding
    
    func test_encode_URLSafe_Data01 () {
        let intArray:[Int8] = [-79, 43, -76, -88, -11, 72, -118, -126, 12, 123, 113, -100, 28, -109, -31, -81, 122, 80, 44, 53, -94, 79, 64, 125, -84, -87, -37, -18, -109, -123, -67, 35]
        let uInt8Array = intArray.map(toUInt8)
        let data  = NSData(bytes: uInt8Array, length: intArray.count)
        let expectedBase64 = "sSu0qPVIioIMe3GcHJPhr3pQLDWiT0B9rKnb7pOFvSM"
        
        do {
            if let encodedString = try Base64.encode(data, coding: .URLSafe, padding: nil) {
                assertThat(encodedString == expectedBase64)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
            
        }
    }
    
    func test_encode_URLSafe_Data02 () {
        let intArray:[Int8] = [115, 49, -5, -63, -12, 45, 38, 94, 115, -69, 77, -54, -103, 111, -116, -33, 10, -48, -87, 83, 120, 39, 74, 5, -65, 65, 46, -27, 9, 65, -50, -99]
        let uInt8Array = intArray.map(toUInt8)
        let data  = NSData(bytes: uInt8Array, length: intArray.count)
        let expectedBase64 = "czH7wfQtJl5zu03KmW-M3wrQqVN4J0oFv0Eu5QlBzp0"
        
        do {
            if let encodedString = try Base64.encode(data, coding: .URLSafe, padding: nil) {
                assertThat(encodedString == expectedBase64)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
            
        }
    }
    
    func test_encode_URLSafe_Data03 () {
        let intArray:[Int8] = [12, -56, -39, 54, 35, 79, -90, 20, -109, -39, -31, 114, -8, 73, -18, 6, 126, 1, -88, -69, -111, 33, -71, 38, -56, -22, 18, -117, 110, 89, 114, 68]
        let uInt8Array = intArray.map(toUInt8)
        let data  = NSData(bytes: uInt8Array, length: intArray.count)
        let expectedBase64 = "DMjZNiNPphST2eFy-EnuBn4BqLuRIbkmyOoSi25ZckQ"
        
        do {
            if let encodedString = try Base64.encode(data, coding: .URLSafe, padding: nil) {
                assertThat(encodedString == expectedBase64)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
            
        }
    }
    
    func test_decodeUser01 () {
        let org:[Int8] = [-79, 43, -76, -88, -11, 72, -118, -126, 12, 123, 113, -100, 28, -109, -31, -81, 122, 80, 44, 53, -94, 79, 64, 125, -84, -87, -37, -18, -109, -123, -67, 35]
        let uInt8Array = org.map(toUInt8)
        
        let base64URLSafe = "sSu0qPVIioIMe3GcHJPhr3pQLDWiT0B9rKnb7pOFvSM"
        do {
            if let data = try Base64.decode(base64URLSafe, coding: .URLSafe) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(uInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == uInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func test_decodeUser02 () {
        let org:[Int8] = [115, 49, -5, -63, -12, 45, 38, 94, 115, -69, 77, -54, -103, 111, -116, -33, 10, -48, -87, 83, 120, 39, 74, 5, -65, 65, 46, -27, 9, 65, -50, -99]
        let uInt8Array = org.map(toUInt8)
        
        let base64URLSafe = "czH7wfQtJl5zu03KmW-M3wrQqVN4J0oFv0Eu5QlBzp0"
        do {
            if let data = try Base64.decode(base64URLSafe, coding: .URLSafe) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(uInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == uInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func test_decodeUser03 () {
        let org:[Int8] = [12, -56, -39, 54, 35, 79, -90, 20, -109, -39, -31, 114, -8, 73, -18, 6, 126, 1, -88, -69, -111, 33, -71, 38, -56, -22, 18, -117, 110, 89, 114, 68]
        let uInt8Array = org.map(toUInt8)
        
        let base64URLSafe = "DMjZNiNPphST2eFy-EnuBn4BqLuRIbkmyOoSi25ZckQ"
        do {
            if let data = try Base64.decode(base64URLSafe, coding: .URLSafe) {
                let decArray = arrayFromData(data)
                assertThat(decArray, hasCount(uInt8Array.count))
                for index in 0..<decArray.count {
                    assertThat(decArray[index] == uInt8Array[index])
                }
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    // MARK: Helper
    
    func arrayFromData(data: NSData) -> [UInt8] {
        let count = data.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 0)
        data.getBytes(&array, length:count * sizeof(UInt8))
        
        return array
    }
    
    func toUInt8(signed: Int8) -> UInt8 {
        return signed >= 0 ? UInt8(signed) : UInt8(signed  - Int8.min) + UInt8(Int8.max) + 1
     }

}
