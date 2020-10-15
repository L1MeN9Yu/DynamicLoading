import XCTest

import DynamicLoaderTests

var tests = [XCTestCaseEntry]()
tests += DynamicLoaderTests.allTests()
XCTMain(tests)
