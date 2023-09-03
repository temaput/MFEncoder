import Foundation

public enum NestedFieldsEncodingStrategy {
  case flattenKeys
  case multipleKeys
}
enum MFValue: Equatable {
  
  
  case string(String)
  case number(String)
  case bool(Bool)
  case url(URL)
  case data(Data)
  case date(Date)
  
  case array([MFValue])
  case object([String: MFValue])
}


extension MFValue {
  var isValue: Bool {
    switch self {
    case .array, .object:
      return false
    default:
      return true
    }
  }
  
  var isContainer: Bool {
    switch self {
    case .array, .object:
      return true
    default:
      return false
    }
  }
}

extension MFValue {
  
  struct Writer {
    var formData = MFFormData()
    let nestedFieldsEncodingStrategy: NestedFieldsEncodingStrategy
    
    func append(path: [String], value: CustomStringConvertible) {
      precondition(!path.isEmpty, "Root element should be object")
      formData.append(name: pathToKey(path), value: value)
    }
    
    func append(path: [String], value: URL) {
      precondition(!path.isEmpty, "Root element should be object")
      formData.append(name: pathToKey(path), value: value)
    }
    func append(path: [String], value: Data) {
      precondition(!path.isEmpty, "Root element should be object")
      formData.append(name: pathToKey(path), value: value)
    }
    func append(path: [String], value: Date) {
      precondition(!path.isEmpty, "Root element should be object")
      formData.append(name: pathToKey(path), value: value)
    }
    func pathToKey(_ path: [String]) -> String {
      switch nestedFieldsEncodingStrategy {
      case .flattenKeys:
        return (path[...0] + path[1...].map({ key in
          return "[\(key)]"
        })).joined(separator: "")
        
      default:
        return path.joined(separator: ".")
      }
    }
    func fillFormData(_ value: MFValue, path: [String] = []) {
      switch value {
      case .object(let object):
        for (key, value) in object {
          
          var nextPath = path
          nextPath.append(key)
          fillFormData(value, path: nextPath)
        }
      case .array(let array):
        precondition(!path.isEmpty, "Root element should be object")
        for (index, value) in array.enumerated() {
          var nextPath = path
          if nestedFieldsEncodingStrategy == .flattenKeys {
            nextPath.append("\(index)")
            
          } else {
            nextPath[nextPath.endIndex-1] = "\(nextPath.last!)[]"
          }
          fillFormData(value, path: nextPath)
        }
        
      case .number(let n):
        append(path: path, value: n)
      case .string(let s):
        append(path: path, value: s)
      case .bool(let b):
        append(path: path, value: b)
        
      case .url(let url):
        append(path: path, value: url)
      case .data(let data):
        append(path: path, value: data)
      case .date(let date):
        append(path: path, value: date)
        
      }
    }
  }
  
  func write(nestedFieldsEncodingStrategy: NestedFieldsEncodingStrategy, dateEncodingStrategy: MFFormData.DateEncodingStrategy, fieldNamesEncodingStrategy: MFFormData.FieldNamesEncodingStrategy) -> MFFormData {
    let writer = MFValue.Writer(nestedFieldsEncodingStrategy: nestedFieldsEncodingStrategy)
    writer.formData.dateEncodingStrategy = dateEncodingStrategy
    writer.formData.fieldNamesEncodingStrategy = fieldNamesEncodingStrategy
    writer.fillFormData(self)
    return writer.formData
    
  }
}
