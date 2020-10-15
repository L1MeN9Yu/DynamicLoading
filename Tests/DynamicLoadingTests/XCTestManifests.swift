import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(DynamicLoadingTests.allTests),
    ]
}
#endif
