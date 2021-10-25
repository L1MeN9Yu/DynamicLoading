//
// Created by Mengyu Li on 2020/10/13.
//

extension String {
    typealias BytesTuple16 = (
        Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8
    )
}

extension String {
    init(bytesTuple: BytesTuple16) {
        var table = [Int8](repeating: 0, count: 17)
        withUnsafePointer(to: bytesTuple) { ptr in
            ptr.withMemoryRebound(to: Int8.self, capacity: 16) { ptr in
                for i in 0..<16 {
                    table[i] = ptr[i]
                }
            }
        }
        self.init(cString: table)
    }
}
