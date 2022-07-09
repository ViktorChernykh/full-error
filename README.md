# FullError

[![Swift 5.6](https://img.shields.io/badge/Swift-5.6-orange.svg?style=flat)](ttps://developer.apple.com/swift/)
[![Vapor 4](https://img.shields.io/badge/vapor-4.0-blue.svg?style=flat)](https://vapor.codes)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

Thanks to the creator of the original library [ExtendedError](https://github.com/Mikroservices/ExtendedError).  
Custom error middleware for Vapor. Thanks to this full error you can create errors with additional field: `code`. You create your own errors according to the `CodeError` protocol. Example:

```swift
import FullError
import Vapor

enum NotFoundError {
    case withId(String)
}

extension NotFoundError: CodeError {
    var status: HTTPResponseStatus { .notFound }
    var code: String {
        switch self {
        case .withId(let model):
            return String(describing: self) + ".\(model)WithId"
        }
    }
    var reason: String {
        switch self {
        case .withId(let model):
            return "There is no \(model) with the specified ID"
        }
    }
}

throw NotFoundError.withId("Product")
```

Thanks to this to client will be send below JSON:

```json
{
    "code": "NotFoundError.ProductWithId",
    "reason": "There is no Product with the specified ID."
}
```

You can also create your own validation errors. Example:

```swift
struct RegistrationDto: Content {
    name: String
}
extension RegistrationDto: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty,
                        customFailureDescription: "nameIsRequired:Name is required")
        // Separated by `:`
        // nameIsRequired - this is the code
        // Name must be no empty - this is the reason
    }
}
```

Thanks to this to client will be send below JSON:

```json
{
    "code": "validationError",
    "reason": "Validation errors occurs"
    [
        {
            "field": "name",
            "code": "ValidateFailure.nameIsRequired",
            "reason": "Name must be no empty"
        }
    ]
}
```

This is super important if you want to show user custom message based on `code` key (for example in different languages). 

## Getting started

You need to add library to `Package.swift` file:

 - add package to dependencies:
```swift
.package(url: "https://github.com/ViktorChernykh/full-error.git", from: "1.0.0")
```

- and add product to your target:
```swift
.target(name: "App", dependencies: [
    . . .
    .product(name: "FullError", package: "full-error")
])
```

Then you can add middleware to Vapor:

```swift
. . .
import FullError

public func configure(_ app: Application) throws {
. . .
// Add error middleware.
let errorMiddleware = FullErrorMiddleware()
app.middleware.use(errorMiddleware)
. . .
}
```

## Developing

Download the source code and run in command line:

```bash
$ git clone https://github.com/ViktorChernykh/full-error.git
$ swift package update
$ swift build
```
Run the following command if you want to open project in Xcode:

```bash
$ open Package.swift
```

## Contributing

You can fork and clone repository. Do your changes and pull a request.

