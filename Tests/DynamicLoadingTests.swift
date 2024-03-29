import XCTest

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.POSIX.dlfcn
@testable import DynamicLoading
import MachO.dyld
import zlib

final class DynamicLoadingTests: XCTestCase {
    func testDyld() {
        let allLibraries = Loader.allMachs()
        guard let zlib = (allLibraries.first { $0.path == "/usr/lib/libz.1.dylib" }) else {
            return XCTFail("zlib not found")
        }
        guard let symbol = zlib.find(name: "_zlibVersion") else { return XCTFail("_zlibVersion not found") }

        let handle = dlopen("/usr/lib/libz.1.dylib", RTLD_LAZY)!
        let address = dlsym(handle, "zlibVersion")!

        print("\(String(cString: zlibVersion()))")
        typealias zlibVersionFunc = @convention(c) () -> UnsafePointer<Int8>?
        let func1 = unsafeBitCast(address, to: zlibVersionFunc.self)
        XCTAssertEqual(String(cString: func1()!), String(cString: zlibVersion()))
        let func0 = unsafeBitCast(symbol.functionPointer!, to: zlibVersionFunc.self)
        XCTAssertEqual(String(cString: func0()!), String(cString: zlibVersion()))

        zlib.allSymbols().forEach {
            print("\($0.functionPointer!):\($0.name)")
        }
    }

    func testDlsym() {
        if let pointer = Loader.functionPointer(path: "/usr/lib/libz.1.dylib", symbol: "_zlibVersion") {
            typealias zlibVersionFunc = @convention(c) () -> UnsafePointer<Int8>
            let zlibVersion = unsafeBitCast(pointer, to: zlibVersionFunc.self)
            XCTAssertEqual(String(cString: zlib.zlibVersion()), String(cString: zlibVersion()))
        }
    }

    static var allTests = [
        ("testDyld", testDyld),
        ("testDlsym", testDlsym),
    ]
}

#endif
