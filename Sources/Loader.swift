//
// Created by Mengyu Li on 2020/10/12.
//

import Foundation
import MachO.dyld

public enum Loader {}

public extension Loader {
    static func allMachs() -> [Mach] {
        var result = [Mach]()
        enumerate {
            result.append($0)
            return true
        }
        return result
    }

    static func find(path: String, symbol: String) -> Symbol? {
        var mach: Mach?
        enumerate {
            if $0.path == path {
                mach = $0
                return false
            } else {
                return true
            }
        }
        return mach?.find(name: symbol)
    }

    static func functionPointer(path: String, symbol: String) -> UnsafeRawPointer? {
        find(path: path, symbol: symbol)?.functionPointer
    }
}

private extension Loader {
    static func enumerate(handle: (Mach) -> Bool) {
        for index in 0..<_dyld_image_count() {
            guard let cName = _dyld_get_image_name(index) else { break }
            let path = String(cString: cName)
            let mach = Mach(index: index, path: path)
            let `continue` = handle(mach)
            if !`continue` { break }
        }
    }
}
