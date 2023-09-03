import XCTest
@testable import MFEncoder


struct Address: Encodable {
  var city: String
  var street: String
  var buildingNo: Int
  var meta: Dictionary<String, String>
}

let bundle = Bundle.main
let swiftLogo = bundle.url(forResource: "Swift_logo", withExtension: "svg")
struct Profile: Encodable {
  
  var username: String = "JohnSmith"
  var password: String = "secret"
  var rank: Int = 1
  var active: Bool = true
}

struct UserData: Encodable {
  var profile: Profile = Profile()
  var addresses: Array<Address> = [
    Address(city: "London", street: "Baker str", buildingNo: 221, meta: ["zip": "AB 123", "floor": "2b"]),
    Address(city: "Exceter", street: "Cathedral str", buildingNo: 1, meta: ["zip": "AB 124", "floor": "0"]),
  ]
}

func debugPrintString(_ str: String) {
  var debugString = ""
  for scalar in str.unicodeScalars {
    if scalar.isASCII {
      if scalar.value < 32 || scalar.value >= 127 {  // Non-printable ASCII
        debugString += "\\\(scalar.value)"
        if scalar.value == 10 {
          debugString += "\n"
        }
      } else {
        debugString += "\(scalar)"
      }
    } else {
      debugString += "\(scalar)"
    }
  }
  print(debugString)
}

func reorderString(_ str: String) -> [String.Element] {
  return str.sorted()
}


final class MFEncoderTests: XCTestCase {
  func testEncodeProfile() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let encoder = MFEncoder()
    encoder.boundary = "--------------------------349673887307243309393243"
    let profile = Profile()
    let expectedSerializationResult = "----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"username\"\r\n\r\nJohnSmith\r\n----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"password\"\r\n\r\nsecret\r\n----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"rank\"\r\n\r\n1\r\n----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"active\"\r\n\r\ntrue\r\n----------------------------349673887307243309393243--\r\n"

    let serializedData = try encoder.encode(profile)
    let serializedDataAsString: String = String(data: serializedData, encoding: .utf8) ?? ""
    
    let expectedHash = reorderString(expectedSerializationResult)
    let serializedHash = reorderString(serializedDataAsString)
    
    if serializedHash != expectedHash {
      print("Strings do not match!")
      print("Serialized Data:")
      debugPrintString(serializedDataAsString)
      print("Expected Result:")
      debugPrintString(expectedSerializationResult)
    }
    XCTAssertEqual(serializedHash, expectedHash)

  }
  
  func testEncodeUserData() throws {
    let encoder = MFEncoder()
    encoder.boundary = "Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5"
    let userData = UserData()
    let expectedSerializationResult = "--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"profile[password]\"\r\n\r\nsecret\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"profile[rank]\"\r\n\r\n1\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"profile[active]\"\r\n\r\ntrue\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"profile[username]\"\r\n\r\nJohnSmith\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[0][buildingNo]\"\r\n\r\n221\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[0][street]\"\r\n\r\nBaker str\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[0][city]\"\r\n\r\nLondon\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[0][meta][floor]\"\r\n\r\n2b\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[0][meta][zip]\"\r\n\r\nAB 123\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[1][street]\"\r\n\r\nCathedral str\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[1][meta][floor]\"\r\n\r\n0\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[1][meta][zip]\"\r\n\r\nAB 124\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[1][city]\"\r\n\r\nExceter\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5\r\nContent-Disposition: form-data; name=\"addresses[1][buildingNo]\"\r\n\r\n1\r\n--Boundary-763B47E0-2A3F-4437-8628-CC4F9B4603D5--\r\n"
    let serializedData = try encoder.encode(userData)
    let serializedDataAsString: String = String(data: serializedData, encoding: .utf8) ?? ""
    
    let expectedHash = reorderString(expectedSerializationResult)
    let serializedHash = reorderString(serializedDataAsString)
    
    if serializedHash != expectedHash {
      print("Strings do not match!")
      print("Serialized Data:")
      debugPrintString(serializedDataAsString)
      print("Expected Result:")
      debugPrintString(expectedSerializationResult)
    }
    XCTAssertEqual(serializedHash, expectedHash)
  }
  
  func testEncodeUserDataDottedFields() throws {
    let encoder = MFEncoder()
    encoder.nestedFieldsEncodingStrategy = .multipleKeys
    encoder.boundary = "Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79"
    let userData = UserData()
    let expectedSerializationResult = "--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"profile.active\"\r\n\r\ntrue\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"profile.rank\"\r\n\r\n1\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"profile.password\"\r\n\r\nsecret\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"profile.username\"\r\n\r\nJohnSmith\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].meta.zip\"\r\n\r\nAB 123\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].meta.floor\"\r\n\r\n2b\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].city\"\r\n\r\nLondon\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].street\"\r\n\r\nBaker str\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].buildingNo\"\r\n\r\n221\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].meta.floor\"\r\n\r\n0\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].meta.zip\"\r\n\r\nAB 124\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].city\"\r\n\r\nExceter\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].street\"\r\n\r\nCathedral str\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79\r\nContent-Disposition: form-data; name=\"addresses[].buildingNo\"\r\n\r\n1\r\n--Boundary-0638453F-6088-4BC0-A982-C563B4C5BF79--\r\n"
    let serializedData = try encoder.encode(userData)
    let serializedDataAsString: String = String(data: serializedData, encoding: .utf8) ?? ""
    
    let expectedHash = reorderString(expectedSerializationResult)
    let serializedHash = reorderString(serializedDataAsString)
    
    if serializedHash != expectedHash {
      print("Strings do not match!")
      print("Serialized Data:")
      debugPrintString(serializedDataAsString)
      print("Expected Result:")
      debugPrintString(expectedSerializationResult)
    }
    XCTAssertEqual(serializedHash, expectedHash)
  }
  func testMFFormBasicSerialization() throws {
    let profile = Profile()
    let formData = MFFormData()
    formData.boundary = "--------------------------349673887307243309393243"
    formData.append(name: "username", value: profile.username)
    formData.append(name: "password", value: profile.password)
    formData.append(name: "rank", value: "\(profile.rank)")
    formData.append(name: "active", value: "\(profile.active)")
    let serializedData = formData.bodyForHttpRequest
    
    let expectedSerializationResult = "----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"username\"\r\n\r\nJohnSmith\r\n----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"password\"\r\n\r\nsecret\r\n----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"rank\"\r\n\r\n1\r\n----------------------------349673887307243309393243\r\nContent-Disposition: form-data; name=\"active\"\r\n\r\ntrue\r\n----------------------------349673887307243309393243--\r\n"
    
    let serializedDataAsString: String = String(data: serializedData, encoding: .utf8) ?? ""
    if serializedDataAsString != expectedSerializationResult {
      print("Strings do not match!")
      print("Serialized Data:")
      debugPrintString(serializedDataAsString)
      print("Expected Result:")
      debugPrintString(expectedSerializationResult)
    }
    XCTAssertEqual(serializedDataAsString, expectedSerializationResult)
  }
  
  
  func testMFFormFileSerialization() throws {
    let profile = Profile()
    let formData = MFFormData()
    formData.boundary = "--------------------------803230140533848331743995"
    
    if let avatar = swiftLogo {
      formData.append(name: "username", value: profile.username)
      formData.append(name: "avatar", value: avatar)
      let serializedData = formData.bodyForHttpRequest
      let serializedDataAsString: String = String(data: serializedData, encoding: .utf8) ?? ""
      
      let expectedSerializationResult = "----------------------------803230140533848331743995\r\nContent-Disposition: form-data; name=\"username\"\r\n\r\nJohnSmith\r\n----------------------------803230140533848331743995\r\nContent-Disposition: form-data; name=\"avatar\"; filename=\"Swift_logo.svg\"\r\nContent-Type: image/svg+xml\r\n\r\n<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<!-- Generator: Adobe Illustrator 18.1.1, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->\r\n<svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\"\r\n\t width=\"106.1px\" height=\"106.1px\" viewBox=\"-252 343.9 106.1 106.1\" enable-background=\"new -252 343.9 106.1 106.1\"\r\n\t xml:space=\"preserve\">\r\n<g>\r\n\t<path fill=\"#F05138\" d=\"M-145.9,373.3c0-1.1,0-2.1,0-3.2c-0.1-2.3-0.2-4.7-0.6-7c-0.4-2.3-1.1-4.5-2.2-6.6c-1.1-2.1-2.4-4-4.1-5.6\r\n\t\tc-1.7-1.7-3.6-3-5.6-4.1c-2.1-1.1-4.3-1.8-6.6-2.2c-2.3-0.4-4.6-0.6-7-0.6c-1.1,0-2.1,0-3.2,0c-1.3,0-2.5,0-3.8,0h-28.1h-11.6\r\n\t\tc-1.3,0-2.5,0-3.8,0c-1.1,0-2.1,0-3.2,0c-0.6,0-1.2,0-1.7,0.1c-1.7,0.1-3.5,0.2-5.2,0.5c-1.7,0.3-3.4,0.8-5,1.4\r\n\t\tc-0.5,0.2-1.1,0.5-1.6,0.7c-1.6,0.8-3,1.8-4.4,2.9c-0.4,0.4-0.9,0.8-1.3,1.2c-1.7,1.7-3,3.6-4.1,5.6c-1.1,2.1-1.8,4.3-2.2,6.6\r\n\t\tc-0.4,2.3-0.5,4.6-0.6,7c0,1.1,0,2.1,0,3.2c0,1.3,0,2.5,0,3.8v17.3v22.4c0,1.3,0,2.5,0,3.8c0,1.1,0,2.1,0,3.2\r\n\t\tc0.1,2.3,0.2,4.7,0.6,7c0.4,2.3,1.1,4.5,2.2,6.6c1.1,2.1,2.4,4,4.1,5.6c1.7,1.7,3.6,3,5.6,4.1c2.1,1.1,4.3,1.8,6.6,2.2\r\n\t\tc2.3,0.4,4.6,0.6,7,0.6c1.1,0,2.1,0,3.2,0c1.3,0,2.5,0,3.8,0h39.7c1.3,0,2.5,0,3.8,0c1.1,0,2.1,0,3.2,0c2.3-0.1,4.7-0.2,7-0.6\r\n\t\tc2.3-0.4,4.5-1.1,6.6-2.2c2.1-1.1,4-2.4,5.6-4.1c1.7-1.7,3-3.6,4.1-5.6c1.1-2.1,1.8-4.3,2.2-6.6c0.4-2.3,0.6-4.6,0.6-7\r\n\t\tc0-1.1,0-2.1,0-3.2c0-1.3,0-2.5,0-3.8v-39.7C-145.9,375.8-145.9,374.6-145.9,373.3z\"/>\r\n\t<path fill=\"#FFFFFF\" d=\"M-168,409.4c0.1-0.4,0.2-0.8,0.3-1.2c4.4-17.5-6.3-38.3-24.5-49.2c8,10.8,11.5,23.9,8.4,35.3\r\n\t\tc-0.3,1-0.6,2-1,3c-0.4-0.3-0.9-0.6-1.6-0.9c0,0-18.1-11.2-37.7-30.9c-0.5-0.5,10.5,15.7,22.9,28.8c-5.9-3.3-22.2-15.2-32.6-24.6\r\n\t\tc1.3,2.1,2.8,4.2,4.4,6.1c8.6,11,19.9,24.5,33.4,34.9c-9.5,5.8-22.9,6.3-36.2,0c-3.3-1.5-6.4-3.4-9.3-5.5\r\n\t\tc5.6,9,14.3,16.8,24.9,21.4c12.6,5.4,25.2,5.1,34.5,0.1l0,0c0,0,0.1,0,0.1-0.1c0.4-0.2,0.8-0.5,1.2-0.7c4.5-2.3,13.3-4.6,18.1,4.6\r\n\t\tC-161.3,432.6-158.8,420.6-168,409.4C-168,409.4-168,409.4-168,409.4z\"/>\r\n</g>\r\n</svg>\r\n\r\n----------------------------803230140533848331743995--\r\n"
      
      if serializedDataAsString != expectedSerializationResult {
        print("Strings do not match!")
        print("Serialized Data:")
        debugPrintString(serializedDataAsString)
        print("Expected Result:")
        debugPrintString(expectedSerializationResult)
      }
      XCTAssertEqual(serializedDataAsString, expectedSerializationResult)
      
    }
  }
}
