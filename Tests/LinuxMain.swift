import XCTest

import Base64Tests

var tests = [XCTestCaseEntry]()
tests += Base64Tests.allTests()
XCTMain(tests)
