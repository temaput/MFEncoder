## Multipart Form Encoder & FormData Swift Package

### Overview

The `MFEncoder & MFFormData` Swift package provides an efficient and user-friendly way to encode data as multipart forms in your Swift applications. It comes with two primary APIs:

- `MFEncoder`: A high-level API that conforms to Swift's `Encoder` protocol. Perfect for converting your Swift models into multipart form data without hassle.
- `MFFormData`: A low-level API, inspired by the Web's FormData API, that gives you complete control over the form data before submitting it over HTTP.

### Features

- **MFEncoder**
  - Conforms to Swift's `Encoder` protocol.
  - Customizable date encoding strategies.
  - Supports encoding nested fields.
  - Generates `Content-Type` headers for HTTP requests.
  
- **MFFormData**
  - Create, modify, and inspect form data manually.
  - Append, set, get, and delete form data fields.
  - Enumerate keys and values.
  - Convert to `URLRequest` objects for easy submission.

### Usage Examples

#### Using MFEncoder

```swift
let encoder = MFEncoder(dateEncodingStrategy: .iso8601, nestedFieldsEncodingStrategy: .multipleKeys)
let userData = UserData()
if let url = URL(string: apiURL), let data = try? encoder.encode(userData),
   let contentTypeForHttpRequest = encoder.contentTypeForHttpRequest {
    // ... submit your request
}
```

#### Using MFFormData

```swift
let formData = MFFormData()
formData.append(name: "username", value: "JohnDoe")
formData.append(name: "avatar", value: UIImage(named: "avatar"))
// ... more form fields
// Submit using your own HTTP client
```

See the playgrounds included for more examples

### Installation

The package is available as a Swift Package Manager package and can be added to your project via Xcode's package management feature.



### Platform Support

- **iOS**: iOS 12 and above (iOS 14 for proper mime attribution)
- **macOS**: macOS 10.14 and above (macOS 11 for proper mime attribution)



### License

Licensed under the [MIT License](LICENSE.md).

