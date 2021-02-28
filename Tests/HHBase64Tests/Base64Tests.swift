import XCTest
@testable import HHBase64

final class Base64Tests: XCTestCase {
    static var allTests = [
        ("test_decode_StandardAlphabet_success", test_decode_StandardAlphabet_success),
        ("test_decode_StandardAlphabet_failure", test_decode_StandardAlphabet_failure),
        ("test_StandardAlphabet_containsIllegalCharacter", test_StandardAlphabet_containsIllegalCharacter),
        ("test_decode_URLSafeAlphabet_success", test_decode_URLSafeAlphabet_success),
        ("test_decode_URLSafeAlphabet_failure", test_decode_URLSafeAlphabet_failure),
        ("test_URLSafeAlphabet_containsIllegalCharacter", test_URLSafeAlphabet_containsIllegalCharacter),
        ("test_StandardAlphabet_containsLegalCharacter", test_StandardAlphabet_containsLegalCharacter),
        ("test_URLSafeAlphabet_containsLegalCharacter", test_URLSafeAlphabet_containsLegalCharacter),
        ("test_StandardAlphabet_UnicodeScalar", test_StandardAlphabet_UnicodeScalar),
        ("test_decode_throwsIfIllegalCharacters_StandardAlphabet", test_decode_throwsIfIllegalCharacters_StandardAlphabet),
        ("test_decode_throwsIfIllegalCharacters_URLSafeAlphabet", test_decode_throwsIfIllegalCharacters_URLSafeAlphabet),
        ("test_decode_StandardAlphabet_Strings", test_decode_StandardAlphabet_Strings),
        ("test_decode_URLSafeAlphabet_Strings", test_decode_URLSafeAlphabet_Strings),
        ("test_encode_URLSafe_Data01", test_encode_URLSafe_Data01),
        ("test_encode_URLSafe_Data02", test_encode_URLSafe_Data02),
        ("test_encode_URLSafe_Data03", test_encode_URLSafe_Data03),
        ("test_decode_URLSafe_01", test_decode_URLSafe_01),
        ("test_decode_URLSafe_02", test_decode_URLSafe_02),
        ("test_decode_URLSafe_03", test_decode_URLSafe_03),
        ("test_encode_Standard_Data01", test_encode_Standard_Data01),
        ("test_encode_Standard_Data02", test_encode_Standard_Data02),
        ("test_encode_Standard_Data03", test_encode_Standard_Data03),
        ("test_decode_Standard_01", test_decode_Standard_01),
        ("test_decode_Standard_02", test_decode_Standard_02),
        ("test_decode_Standard_03", test_decode_Standard_03)
    ]
    
    let illegalEncodedStrings_StandardAlphabet = ["MA\\=", "QQ-=", "Q=JDRE_GR0g="]
    let illegalEncodedStrings_URLSafeAlphabet  = ["+A", "/\\Q", "QUJDR=VmZ2hpams"]
    
    let legalEncodedStandardCharacterStrings = ["Zg==", "Zm8=", "Zm9v", "Zm9vYg==", "Zm9vYmE=", "Zm9vYmFy", "MA==", "QQ==", "QUJDREVGR0g=", "QUJDREVGR0hJ", "QTFCMkMzRDRINQ==", "QTFCMkMzRDRINStaL2cz"]
    let legalDecodedStandardCharacterStrings = ["f", "fo", "foo", "foob", "fooba", "foobar", "0", "A", "ABCDEFGH", "ABCDEFGHI", "A1B2C3D4H5", "A1B2C3D4H5+Z/g3"]
    
    let legalEncodedURLSafeCharacterStrings  = ["Zg", "Zm8", "Zm9v", "Zm9vYg", "Zm9vYmE", "Zm9vYmFy", "MA", "QQ", "QUJDREVmZ2hpams", "QTBCQ0RFZmdoaWprMQ", "QTFCMkMzRDRhMWIyYzNiNA", "QTFCMkMzRDRINStaL2cz"]
    let legalDecodedURLSafeCharacterStrings  = ["f", "fo", "foo", "foob", "fooba", "foobar", "0", "A", "ABCDEfghijk", "A0BCDEfghijk1", "A1B2C3D4a1b2c3b4", "A1B2C3D4H5+Z/g3"]

    // MARK: Alphabet
    
    func test_decode_StandardAlphabet_success() {
        let coding = Base64Coding.standard
        let string = "ABCDEFGEHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        for (index, _) in string.utf8.enumerated() {
            XCTAssertNotNil(coding.decodedValue(forIndex: index, inString: string))
        }
    }
    
    func test_decode_StandardAlphabet_failure() {
        let coding = Base64Coding.standard
        let string = "😀💃#_´?"
        for (index, _) in string.utf8.enumerated() {
            XCTAssertNil(coding.decodedValue(forIndex: index, inString: string))
        }
    }
    
    func test_StandardAlphabet_containsIllegalCharacter() {
        let coding = Base64Coding.standard
        for string in illegalEncodedStrings_StandardAlphabet {
            XCTAssert(coding.stringContainsIllegalCharacters(string) == true)
        }
    }
    
    func test_decode_URLSafeAlphabet_success() {
        let coding = Base64Coding.urlSafe
        let string = "ABCDEFGEHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
        for (index, _) in string.utf8.enumerated() {
            XCTAssertNotNil(coding.decodedValue(forIndex: index, inString: string))
        }
    }
    
    func test_decode_URLSafeAlphabet_failure() {
        let coding = Base64Coding.urlSafe
        let string = "😀💃#´+:"
        for (index, value) in string.utf8.enumerated() {
            XCTAssertNil(coding.decodedValue(forIndex: index, inString: string), "value: \(value)")
        }
    }
    
    func test_URLSafeAlphabet_containsIllegalCharacter() {
        let coding = Base64Coding.urlSafe
        for string in illegalEncodedStrings_URLSafeAlphabet {
            XCTAssert(coding.stringContainsIllegalCharacters(string) == true)
        }
    }
    
    func test_StandardAlphabet_containsLegalCharacter() {
        let coding = Base64Coding.standard
        for string in legalEncodedStandardCharacterStrings {
            XCTAssert(coding.stringContainsIllegalCharacters(string) == false)
        }
    }
    
    func test_URLSafeAlphabet_containsLegalCharacter() {
        let coding = Base64Coding.urlSafe
        for string in legalEncodedURLSafeCharacterStrings {
            XCTAssert(coding.stringContainsIllegalCharacters(string) == false)
        }
    }
    
    func test_StandardAlphabet_UnicodeScalar() {
        let coding = Base64Coding.standard
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        for index in 0..<coding.alphabet.count {
            let characterA = UnicodeScalar(characters.utf8[characters.utf8.index(characters.utf8.startIndex, offsetBy: index)])
            let characterB = UnicodeScalar(coding[index])
            XCTAssert(characterA == characterB)
        }
    }
    
    func test_URLSafeAlphabet_UnicodeScalar() {
        let coding = Base64Coding.urlSafe
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_="
        for index in 0..<coding.alphabet.count {
            let characterA = UnicodeScalar(characters.utf8[characters.utf8.index(characters.utf8.startIndex, offsetBy: index)])
            let characterB = UnicodeScalar(coding[index])
            XCTAssert(characterA == characterB)
        }
    }
    
    // MARK: Decoding
    
    func test_decode_throwsIfIllegalCharacters_StandardAlphabet() {
        for string in illegalEncodedStrings_StandardAlphabet {
            XCTAssertThrowsError(try Base64.decode(string), "") { (error) in
                XCTAssertEqual(error as? Base64Error, Base64Error.containsIllegalCharacters)
            }
        }
    }
    
    func test_decode_throwsIfIllegalCharacters_URLSafeAlphabet() {
        for string in illegalEncodedStrings_URLSafeAlphabet {
            XCTAssertThrowsError(try  Base64.decode(string, coding: .urlSafe), "") { (error) in
                XCTAssertEqual(error as? Base64Error, Base64Error.containsIllegalCharacters)
            }
        }
    }
    
    func test_decode_StandardAlphabet_Strings() {
        for idx in 0..<legalEncodedStandardCharacterStrings.count {
            let eString = legalEncodedStandardCharacterStrings[idx]
            let dString = legalDecodedStandardCharacterStrings[idx]
            do {
                if let data = try Base64.decode(eString), let string = String(data: data, encoding: String.Encoding.utf8) {
                    XCTAssertEqual(string, dString)
                } else {
                    XCTFail("decode failed")
                }
                
            } catch {
                XCTFail("\(error)")
            }
        }
    }
    
    func test_decode_URLSafeAlphabet_Strings() {
        for idx in 0..<legalEncodedURLSafeCharacterStrings.count {
            let eString = legalEncodedURLSafeCharacterStrings[idx]
            let dString = legalDecodedURLSafeCharacterStrings[idx]
            do {
                if let data = try Base64.decode(eString, coding: .urlSafe), let string = String(data: data, encoding: String.Encoding.utf8) {
                    XCTAssertEqual(string, dString)
                } else {
                    XCTFail("decode failed")
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
    func test_encode_URLSafe_Data01() {
        let uInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
        guard let unsafePointer = uInt8Array.withUnsafeBufferPointer({ $0.baseAddress }) else { XCTFail("Couldn't create unsafePointer"); return }
        let data  = Data(bytes: unsafePointer, count: uInt8Array.count)
        let expectedBase64 = "FPucA9l-"
        
        if let encodedString = Base64.encode(data, coding: .urlSafe) {
            XCTAssertEqual(encodedString, expectedBase64)
        } else {
            XCTFail("encode failed")
        }
    }
    
    func test_encode_URLSafe_Data02() {
        let uInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
        guard let unsafePointer = uInt8Array.withUnsafeBufferPointer({ $0.baseAddress }) else { XCTFail("Couldn't create unsafePointer"); return }
        let data  = Data(bytes: unsafePointer, count: uInt8Array.count)
        let expectedBase64 = "FPucA9k"
        
        if let encodedString = Base64.encode(data, coding: .urlSafe, padding: .off) {
            XCTAssertEqual(encodedString, expectedBase64)
        } else {
            XCTFail("encode failed")
        }
    }
    
    func test_encode_URLSafe_Data03() {
        let uInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03]
        guard let unsafePointer = uInt8Array.withUnsafeBufferPointer({ $0.baseAddress }) else { XCTFail("Couldn't create unsafePointer"); return }
        let data  = Data(bytes: unsafePointer, count: uInt8Array.count)
        let expectedBase64 = "FPucAw"
        
        if let encodedString = Base64.encode(data, coding: .urlSafe, padding: .off) {
            XCTAssertEqual(encodedString, expectedBase64)
        } else {
            XCTFail("encode failed")
        }
    }
    
    func test_decode_URLSafe_01() {
        do {
            let orgUInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
            let encodedString = "FPucA9l-"
            
            if let data = try Base64.decode(encodedString, coding: .urlSafe) {
                let decArray = arrayFromData(data)
                XCTAssertEqual(decArray.count, orgUInt8Array.count)
                for index in 0..<decArray.count {
                    XCTAssertEqual(decArray[index], orgUInt8Array[index])
                }
            } else {
                XCTFail("decode failed")
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_decode_URLSafe_02() {
        do {
            let orgUInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
            let encodedString = "FPucA9k"
            
            if let data = try Base64.decode(encodedString, coding: .urlSafe) {
                let decArray = arrayFromData(data)
                XCTAssertEqual(decArray.count, orgUInt8Array.count)
                for index in 0..<decArray.count {
                    XCTAssertEqual(decArray[index], orgUInt8Array[index])
                }
            } else {
                XCTFail("decode failed")
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_decode_URLSafe_03() {
        do {
            let orgUInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03]
            let encodedString = "FPucAw=="
            
            if let data = try Base64.decode(encodedString, coding: .urlSafe) {
                let decArray = arrayFromData(data)
                XCTAssertEqual(decArray.count, orgUInt8Array.count)
                for index in 0..<decArray.count {
                    XCTAssertEqual(decArray[index], orgUInt8Array[index])
                }
            } else {
                XCTFail("decode failed")
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_encode_Standard_Data01() {
        let uInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
        guard let unsafePointer = uInt8Array.withUnsafeBufferPointer({ $0.baseAddress }) else { XCTFail("Couldn't create unsafePointer"); return }
        let data  = Data(bytes: unsafePointer, count: uInt8Array.count)
        let expectedBase64 = "FPucA9l+"
        
        if let encodedString = Base64.encode(data) {
            XCTAssertEqual(encodedString, expectedBase64)
        } else {
            XCTFail("encode failed")
        }
    }
    
    func test_encode_Standard_Data02() {
        let uInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
        guard let unsafePointer = uInt8Array.withUnsafeBufferPointer({ $0.baseAddress }) else { XCTFail("Couldn't create unsafePointer"); return }
        let data  = Data(bytes: unsafePointer, count: uInt8Array.count)
        let expectedBase64 = "FPucA9k="
        
        if let encodedString = Base64.encode(data) {
            XCTAssertEqual(encodedString, expectedBase64)
        } else {
            XCTFail("encode failed")
        }
    }
    
    func test_encode_Standard_Data03() {
        let uInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03]
        guard let unsafePointer = uInt8Array.withUnsafeBufferPointer({ $0.baseAddress }) else { XCTFail("Couldn't create unsafePointer"); return }
        let data  = Data(bytes: unsafePointer, count: uInt8Array.count)
        let expectedBase64 = "FPucAw=="
        
        if let encodedString = Base64.encode(data) {
            XCTAssertEqual(encodedString, expectedBase64)
        } else {
            XCTFail("encode failed")
        }
    }
    
    func test_decode_Standard_01() {
        do {
            let orgUInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9, 0x7E]
            let encodedString = "FPucA9l+"
            
            if let data = try Base64.decode(encodedString) {
                let decArray = arrayFromData(data)
                XCTAssertEqual(decArray.count, orgUInt8Array.count)
                for index in 0..<decArray.count {
                    XCTAssertEqual(decArray[index], orgUInt8Array[index])
                }
            } else {
                XCTFail("decode failed")
            }
        } catch {
            XCTFail("decode failed with \(error)")
        }
    }
    
    func test_decode_Standard_02() {
        do {
            let orgUInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03, 0xD9]
            let encodedString = "FPucA9k="
            
            if let data = try Base64.decode(encodedString) {
                let decArray = arrayFromData(data)
                XCTAssertEqual(decArray.count, orgUInt8Array.count)
                for index in 0..<decArray.count {
                    XCTAssertEqual(decArray[index], orgUInt8Array[index])
                }
            } else {
                XCTFail("decode failed")
            }
        } catch {
            XCTFail("decode failed with \(error)")
        }
    }
    
    func test_decode_Standard_03() {
        do {
            let orgUInt8Array: [UInt8] = [0x14, 0xFB, 0x9C, 0x03]
            let encodedString = "FPucAw=="
            
            if let data = try Base64.decode(encodedString) {
                let decArray = arrayFromData(data)
                XCTAssertEqual(decArray.count, orgUInt8Array.count)
                for index in 0..<decArray.count {
                    XCTAssertEqual(decArray[index], orgUInt8Array[index])
                }
            } else {
                XCTFail("decode failed")
            }
        } catch {
            XCTFail("decode failed with \(error)")
        }
    }
    
    // MARK: Helper
    
    func arrayFromData(_ data: Data) -> [UInt8] {
        let count = data.count / MemoryLayout<UInt8>.size
        var array = [UInt8](repeating: 0, count: count)
        (data as NSData).getBytes(&array, length: count * MemoryLayout<UInt8>.size)
        
        return array
    }
}
