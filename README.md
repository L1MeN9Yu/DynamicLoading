# DynamicLoading

A replacement of `dlfcn`.

## Usage

```swift
if let pointer = Loader.functionPointer(path: "/usr/lib/libz.1.dylib", symbol: "_zlibVersion") {
    typealias zlibVersionFunc = @convention(c) () -> UnsafePointer<Int8>
    let zlibVersion = unsafeBitCast(pointer, to: zlibVersionFunc.self)
    print("\(String(cString: zlibVersion()))")
}
```

## Limitation

1. The image has been loaded.
2. The image macho's `LC_SYMTAB` is not obfuscated.
