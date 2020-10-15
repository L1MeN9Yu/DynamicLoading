//
// Created by Mengyu Li on 2020/10/13.
//

import Foundation
import MachO

#if arch(x86_64) || arch(arm64)
typealias MachHeader = mach_header_64
typealias NList = nlist_64
#else
typealias MachHeader = mach_header
typealias NList = nlist
#endif

public struct Mach {
    public let index: UInt32
    public let path: String

    public init(index: UInt32, path: String) {
        self.index = index
        self.path = path
    }
}

public extension Mach {
    func find(name: String) -> Symbol? {
        var symbol: Symbol?
        enumerate {
            if name == $0.name {
                symbol = $0
                return false
            } else {
                return true
            }
        }
        return symbol
    }

    func allSymbols() -> [Symbol] {
        var symbols = [Symbol]()
        enumerate {
            symbols.append($0)
            return true
        }
        return symbols
    }
}

private extension Mach {
    func enumerate(handle: (Symbol) -> Bool) {
        guard let machHeaderPointer = _dyld_get_image_header(index) else { return }
        let machHeaderSize: Int = MemoryLayout<MachHeader>.stride
        let loadCommandCount = machHeaderPointer.pointee.ncmds
        var loadCommandLeft = loadCommandCount
        var offsetCursor = UnsafeRawPointer(machHeaderPointer).advanced(by: machHeaderSize)
        var segmentBase: uintptr_t = 0
        let imageVirtualMemoryAddress = _dyld_get_image_vmaddr_slide(index)
        while loadCommandLeft > 0 {
            let commandPointer = offsetCursor.bindMemory(to: load_command.self, capacity: 1)
            let cmd = commandPointer.pointee.cmd

            switch cmd {
            case UInt32(LC_SEGMENT):
                let segmentCommandPointer = offsetCursor.bindMemory(to: segment_command.self, capacity: 1)
                let segmentCommand = segmentCommandPointer.pointee
                if String(bytesTuple: segmentCommand.segname) == SEG_LINKEDIT {
                    segmentBase = UInt(segmentCommand.vmaddr - segmentCommand.fileoff) + UInt(imageVirtualMemoryAddress)
                }
            case UInt32(LC_SEGMENT_64):
                let segmentCommandPointer = offsetCursor.bindMemory(to: segment_command_64.self, capacity: 1)
                let segmentCommand = segmentCommandPointer.pointee
                if String(bytesTuple: segmentCommand.segname) == SEG_LINKEDIT {
                    segmentBase = UInt(segmentCommand.vmaddr - segmentCommand.fileoff) + UInt(imageVirtualMemoryAddress)
                }
            case UInt32(LC_SYMTAB):
                if segmentBase > 0 {
                    let symbolTableCommandPointer = offsetCursor.bindMemory(to: symtab_command.self, capacity: 1)
                    let symbolTableCommand = symbolTableCommandPointer.pointee
                    let symbolTableAddress = segmentBase + UInt(symbolTableCommand.symoff)
                    let stringTableAddress = segmentBase + UInt(symbolTableCommand.stroff)
                    guard let symbolTableRawPointer = UnsafeRawPointer(bitPattern: symbolTableAddress) else { break }
                    let symbolTable = symbolTableRawPointer.bindMemory(to: NList.self, capacity: 1)
                    for idx in 0..<symbolTableCommand.nsyms {
                        // if n_value is 0, the symbol refers to an external object.
                        if symbolTable[Int(idx)].n_value != 0 {
                            let nlist: NList = symbolTable.advanced(by: Int(idx)).pointee
                            let symbolAddress = nlist.n_value + UInt64(imageVirtualMemoryAddress)
                            let symbolNameAddress = stringTableAddress + UInt(nlist.n_un.n_strx)
                            guard let symbolNameRawPointer = UnsafeRawPointer(bitPattern: symbolNameAddress) else { break }
                            let symbolNamePointer = symbolNameRawPointer.bindMemory(to: CChar.self, capacity: 1)
                            let symbolName = String(cString: symbolNamePointer)
                            let symbol = Symbol(address: symbolAddress, name: symbolName)
                            let shouldContinue = handle(symbol)
                            if !shouldContinue { return }
                        }
                    }
                }
            default: break
            }

            offsetCursor += Int(commandPointer.pointee.cmdsize)
            loadCommandLeft -= 1
        }
    }
}
