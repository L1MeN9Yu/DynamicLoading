//
// Created by Mengyu Li on 2020/10/15.
//

import Foundation

public struct Symbol {
    public let address: UInt64
    public let name: String

    init(address: UInt64, name: String) {
        self.address = address
        self.name = name
    }
}

public extension Symbol {
    var functionPointer: UnsafeRawPointer? {
        UnsafeRawPointer(bitPattern: UInt(address))
    }
}
