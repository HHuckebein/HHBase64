# Base64
___
 
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
