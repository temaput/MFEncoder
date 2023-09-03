import UIKit
import MFEncoder

var greeting = "Hello, playground"
var swiftLogo = Bundle.main.url(forResource: "Swift_logo", withExtension: "svg")

let apiURL = "http://127.0.0.1:8000/form_data/test/"
let formData = MFFormData()
formData.append(name: "username", value: "JohnSmith")
if let avatar = swiftLogo {
  formData.append(name: "avatar", value: avatar)
}



if let avatarUI = UIImage(named: "Swift_logo.png") {
  formData.append(name: "avatarUI", value: avatarUI)
  print("Fire!")
  
}


formData.get(name: "rank")
formData.get(name: "avatarNS")
formData.getAll(name: "addresses[]")


if let url = URL(string: apiURL) {
  let request = formData.asHttpRequest(url: url)
  Task.init {
//    await submitHttpRequest(request)
  }
}







func submitHttpRequest(_ request: URLRequest) async {
  do {
    print("Sending request...")
    let (data, _) = try await URLSession.shared.data(for: request)
    // Handle data and response.
    print("Got response!")
    print(String(data: data, encoding: .utf8) ?? "Data not readable")
//    print(response)
  } catch {
    // Handle error.
    print("Error: \(error)")
  }
}




// Prepare fixtures for EncoderTests
struct Address: Encodable {
  var city: String
  var street: String
  var buildingNo: Int
  var meta: Dictionary<String, String>
}

struct Profile: Encodable {
  
  var username: String = "JohnSmith"
  var password: String = "secret"
  var rank: Int = 1
  var active: Bool = true
  var avatar: URL?
}

struct UserData: Encodable {
  var profile: Profile = Profile()
  var addresses: Array<Address> = [
    Address(city: "London", street: "Baker str", buildingNo: 221, meta: ["zip": "AB 123", "floor": "2b"]),
    Address(city: "Exceter", street: "Cathedral str", buildingNo: 1, meta: ["zip": "AB 124", "floor": "0"]),
  ]
}



let encoder = MFEncoder()
encoder.fieldNamesEncodingStrategy = .percentEncoding
let userData = UserData()
let profile = Profile()
encoder.nestedFieldsEncodingStrategy = .multipleKeys
let result = try encoder.encode(userData)

let echoUrl = "http://127.0.0.1:8000/form_data/echo/"

if let url = URL(string: echoUrl), let request = encoder.asFormData?.asHttpRequest(url: url)  {
  Task.init {
    await submitHttpRequest(request)
  }
}

