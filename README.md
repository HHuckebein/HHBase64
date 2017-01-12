# Base64

[![Build Status](https://travis-ci.org/HHuckebein/Base64.svg?branch=master)](https://travis-ci.org/HHuckebein/Base64)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codecov](https://codecov.io/gh/HHuckebein/Base64/branch/master/graph/badge.svg)](https://codecov.io/gh/HHuckebein/Base64)__
 
Base64 encoding/decoding.
Provides .urlSafe/.standard (iOS compatible) encoding of type Data and decoding of type String.
You can, when encoding, ask for padding.
When decoding padding is ignored if you choose .urlSafe decoding.
 
## How to use Base64
### Encoding
```swift
Base64.encode(data, coding: .urlSafe)
Base64.encode(data, coding: .urlSafe, padding: .off)

Base64.encode(data) // .standard is default as is .on for padding
```

### Decoding
```swift
Base64.decode(data, coding: .urlSafe)
Base64.decode(data) // .standard is default
```
## Installation

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Base64 into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "HHuckebein/Base64"
```

Run `carthage` to build the framework and drag the built `Base64.framework` into your Xcode project.


## Author

RABE_IT Services, development@berndrabe.de

## License

Base64 is available under the MIT license. See the LICENSE file for more info.
