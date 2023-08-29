import XCTest
@testable import MFEncoder


struct Address: Encodable {
  var city: String
  var street: String
  var buildingNo: Int
  var meta: Dictionary<String, String>
}

let bundle = Bundle.module
let swiftLogo = bundle.url(forResource: "Swift_logo", withExtension: "svg")
struct Profile: Encodable {
  
  var username: String = "JohnSmith"
  var password: String = "secret"
  var rank: Int = 1
  var active: Bool = true
  var avatar: URL? = swiftLogo
}

struct UserData: Encodable {
  var profile: Profile = Profile()
  var addresses: Array<Address> = [
    Address(city: "London", street: "Baker str", buildingNo: 221, meta: ["zip": "AB 123", "floor": "2b"]),
    Address(city: "Exceter", street: "Cathedral str", buildingNo: 1, meta: ["zip": "AB 124", "floor": "0"]),
  ]
}


final class MFEncoderTests: XCTestCase {
  func testEncodeProfile() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let encoder = MFEncoder()
    let profile = Profile()
    _ = try encoder.encode(profile)
  }
  
  func testEncodeUserData() throws {
    let encoder = MFEncoder()
    let userData = UserData()
    _ = try encoder.encode(userData)
    
  }
}
