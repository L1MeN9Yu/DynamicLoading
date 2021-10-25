# DynamicLoading

A replacement of `dlfcn`.

## Status

[![Build](https://github.com/L1MeN9Yu/DynamicLoading/actions/workflows/Build.yml/badge.svg)](https://github.com/L1MeN9Yu/DynamicLoading/actions/workflows/Build.yml)
[![codecov](https://codecov.io/gh/L1MeN9Yu/DynamicLoading/branch/main/graph/badge.svg?token=AW22MYW1SY)](https://codecov.io/gh/L1MeN9Yu/DynamicLoading)

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

## Code Coverage

![Code Coverage](https://codecov.io/gh/L1MeN9Yu/DynamicLoading/branch/main/graphs/sunburst.svg)
