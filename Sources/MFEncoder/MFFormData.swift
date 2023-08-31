import Foundation
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import CoreImage

func getMimeTypeFromURL(_ fileURL: URL) -> String? {
  var fileURL = fileURL
  fileURL.resolveSymlinksInPath()
  do {
    let fileObjectResource = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
    if fileObjectResource.isDirectory ?? false {
      return nil
    }
    if #available(macOS 11.0, iOS 14.0, *) {
      let resourceValues = try fileURL.resourceValues(forKeys: [.contentTypeKey, .isDirectoryKey])
      if let type = resourceValues.contentType, let mime = type.preferredMIMEType  {
        return mime
      }
    }
    return "application/octet-stream"
  } catch {
    return nil
  }
}

var ascii: CharacterSet = CharacterSet(charactersIn: " " ... "~")

public class MFFormData {
  
  
  private var data: Array<FormDataItem> = []
  
  public var boundary: String
  
  public var dateEncodingStrategy: DateEncodingStrategy = .secondsSince1970
  
  public init() {
    boundary = "Boundary-\(UUID().uuidString)"
  }
  
  func wrapDate(_ date: Date) -> String {
    switch self.dateEncodingStrategy {
      
    case .millisecondsSince1970:
      return (date.timeIntervalSince1970 * 1000).description
      
    case .iso8601:
      if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        
        return formatter.string(from: date)
      } else {
        fatalError("ISO8601DateFormatter is unavailable on this platform.")
      }
      
    case .formatted(let formatter):
      
      return formatter.string(from: date)
      
    default:
      return date.timeIntervalSince1970.description
      
      
      
    }
  }
  
  
  // MARK: - FormData API
  
  public func append(name: String, value: CustomStringConvertible) {
    
    if let value = "\(value)".data(using: .utf8) {
      data.append(FormDataItem(name: name, value: value))
    }
  }
  
  
  public func append(name: String, value: CGImage) {
#if os(iOS)
    let image = UIImage(cgImage: value)
    append(name: name, value: image)
#elseif os(macOS)
    let image = NSImage(cgImage: value, size: .zero)
    append(name: name, value: image)
#endif
    
  }
  
  public func append(name: String, value: CIImage) {
    if let image = value.cgImage {
      append(name: name, value: image)
    }
  }
  
#if os(iOS)
  public func append(name: String, value: UIImage) {
    if let pngData = value.pngData() {
      let filename = "\(name).png"
      data.append(FormDataItem(name: name, value: pngData, filename: filename, mime: "image/png"))
    }
  }
#endif
  
  
  
#if os(macOS)
  public func append(name: String, value: NSImage) {
    
    if let tiffData = value.tiffRepresentation {
      var filename = "\(name).tiff"
      if let nsImageName = value.name() {
        filename = "\(nsImageName).tiff"
      }
      data.append(FormDataItem(name: name, value: tiffData, filename: filename, mime: "image/tiff"))
    }
  }
#endif
  
  public func append(name: String, value: URL) {
    
    if !value.isFileURL {
      append(name: name, value: value.absoluteString)
    }
    if let fileData = try? Data(contentsOf: value), let mime = getMimeTypeFromURL(value)  {
      data.append(FormDataItem(name: name, value: fileData, filename: value.lastPathComponent, mime: mime))
    }
  }
  
  public func append(name: String, value: Data) {
    data.append(FormDataItem(name: name, value: value, filename: "file", mime: "application/octet-stream"))
  }
  
  public func append(name: String, value: Date) {
    let serializedDate = wrapDate(value)
    append(name: name, value: serializedDate)
  }
  
  public func set(name: String, value: CustomStringConvertible) {
    
    delete(name: name)
    append(name: name, value: value)
  }
  public func set(name: String, value: URL) {
    delete(name: name)
    append(name: name, value: value)
  }
  public func set(name: String, value: Data) {
    delete(name: name)
    append(name: name, value: value)
  }
  
  public func has(name: String) -> Bool {
    return data.contains(where: {$0.name == name})
  }
  
  public func keys() -> KeysIterator {
    return KeysIterator(data)
  }
  
  public func entries() -> EntriesIterator {
    return EntriesIterator(data)
  }
  
  public func values() -> ValuesIterator {
    return ValuesIterator(data)
  }
  
  public func get(name: String) -> ValueOutput? {
    if let item = data.first(where: { $0.name == name }) {
      return ValueOutput(item)
    } else {
      return nil
    }
  }
  
  public func getAll(name: String) -> Array<ValueOutput> {
    return data.filter({ $0.name == name }).compactMap({ ValueOutput($0) })
  }
  
  public func delete(name: String) {
    data.removeAll { formDataItem in
      formDataItem.name == name
    }
    
  }
  
  // MARK: - Helper methods to work with URLSession
  
  private func encodeName(_ name: String) -> String {
    return name.addingPercentEncoding(withAllowedCharacters: ascii) ?? "NA"
  }
  
  public var bodyForHttpRequest: Data {
    
    var body = Data()
    
    data.forEach { formDataItem in
      body.append("--\(boundary)\r\n".data(using: .utf8)!)
      if let fileName = formDataItem.filename, let mime = formDataItem.mime {
        body.append("Content-Disposition: form-data; name=\"\(encodeName(formDataItem.name))\"; filename=\"\(encodeName(fileName))\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mime)\r\n\r\n".data(using: .utf8)!)
      } else {
        body.append("Content-Disposition: form-data; name=\"\(encodeName(formDataItem.name))\"\r\n\r\n".data(using: .utf8)!)
      }
      body.append(formDataItem.value)
      body.append("\r\n".data(using: .utf8)!)
      
      
    }
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    return body
    
    
  }
  
  public var contentTypeForHttpRequest: String {
    return "multipart/form-data; boundary=\(boundary)"
  }
  
  
  public func asHttpRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = bodyForHttpRequest
    request.setValue(contentTypeForHttpRequest, forHTTPHeaderField: "Content-Type")
    return request
  }
  
  
  
  // MARK: - Internal Structures
  struct FormDataItem {
    var name: String
    var value: Data
    var filename: String?
    var mime: String?
  }
  
  public enum ValueOutput {
    case stringCase(String)
    case blobCase(Data)
    
    init?(_ item: FormDataItem) {
      if item.filename != nil {
        self = .blobCase(item.value)
      } else {
        if let stringValue = String(data: item.value, encoding: .utf8) {
          self = .stringCase(stringValue)
          
        } else {
          return nil
        }
      }
      
    }
  }
  
  
  
  public enum DateEncodingStrategy {
    /// Defer to `Date` for choosing an encoding. This is the default strategy.
    case deferredToDate
    
    /// Encode the `Date` as a UNIX timestamp (as a JSON number).
    case secondsSince1970
    
    /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
    case millisecondsSince1970
    
    /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    case iso8601
    
    /// Encode the `Date` as a string formatted by the given formatter.
    case formatted(DateFormatter)
    
  }
  
  
  
  public struct ValuesIterator: IteratorProtocol, Sequence {
    public typealias Element = ValueOutput
    private var current = 0
    private let elements: Array<FormDataItem>
    init(_ elements: Array<FormDataItem>) {
      self.elements = elements
    }
    
    mutating public func next() -> ValueOutput? {
      defer {
        current += 1
      }
      guard current < elements.count else {
        return nil
      }
      return ValueOutput(elements[current])
    }
  }
  public struct EntriesIterator: IteratorProtocol, Sequence {
    public typealias Element = (String, ValueOutput)
    private var current = 0
    private let elements: Array<FormDataItem>
    init(_ elements: Array<FormDataItem>) {
      self.elements = elements
    }
    
    mutating public func next() -> Element? {
      defer {
        current += 1
      }
      guard current < elements.count else {
        return nil
      }
      if let valueOutput = ValueOutput(elements[current]) {
        return (elements[current].name, valueOutput)
      } else {
        return nil
      }
    }
  }
  
  public struct KeysIterator: IteratorProtocol, Sequence {
    public typealias Element = String
    
    private var current = 0
    private let elements: Array<FormDataItem>
    init(_ elements: Array<FormDataItem>) {
      self.elements = elements
    }
    
    mutating public func next() -> String? {
      defer {
        current += 1
        while current < elements.count && elements[current - 1].name == elements[current].name {
          current += 1
        }
      }
      return current < elements.count ? elements[current].name : nil
    }
  }
  
  
}
