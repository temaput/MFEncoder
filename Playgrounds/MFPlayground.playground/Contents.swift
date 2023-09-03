import Foundation
import MFEncoder
import AppKit


var swiftLogo = Bundle.main.url(forResource: "Swift_logo", withExtension: "svg")





enum UserRole: Encodable {
  case user
  case powerUser
  case admin
  
}



struct Address: Encodable {
  var city: String
  var street: String
  var buildingNo: Int
  var meta: Dictionary<String, String>
  
}

enum ContactInfoKeys: String, CodingKey {
  case name, phones, sites, email
}

enum SitesKeys: String, CodingKey {
  case personal, linkedIn, github
}

struct ContactInfo: Encodable {
  
  var firstName: String = "John"
  var lastName: String = "Smith"
  
  var homePhone: String = "11 222 3333"
  var cellularPhone: String = "+11 222 333 444"
  var email: String = "john@email.com"
  
  let website: String = "https://example.com"
  let linkedIn: String = "https://linkedin.com/john"
  let github: String = "https://github.com/john"
  
  func encode(to encoder: Encoder) throws {
    var contact = encoder.container(keyedBy: ContactInfoKeys.self)
    try contact.encode("\(firstName) \(lastName)", forKey: .name)
    try contact.encode(email, forKey: .email)
    
    var phones = contact.nestedUnkeyedContainer(forKey: .phones)
    try phones.encode(homePhone)
    try phones.encode(cellularPhone)
    
    var sites = contact.nestedContainer(keyedBy: SitesKeys.self, forKey: .sites)
    print("Contact Info coding path: \(encoder.codingPath)")
    print("Sites coding path: \(sites.codingPath)")
    try sites.encode(website, forKey: .personal)
    try sites.encode(linkedIn, forKey: .linkedIn)
    try sites.encode(github, forKey: .github)
  }
  
}

struct Profile: Encodable {
  
  
  var username: String = "JohnSmith"
  var password: String = "secret"
  var rank: Int = 1
  var active: Bool = true
  var avatar: URL? = swiftLogo
  var avatarBin: Data? = try! Data(contentsOf: swiftLogo!)
  
  var userRole: UserRole = .powerUser
  
  
}

var components = DateComponents()
components.year = 2023
components.month = 5
components.day = 31
let calendar = Calendar.current
let myBirthday = calendar.date(from: components)

struct UserData: Encodable {
  var profile: Profile = Profile()
  var addresses: Array<Address> = [
    Address(city: "London", street: "Baker str", buildingNo: 221, meta: ["zip": "AB 123", "floor": "2b"]),
    Address(city: "Exceter", street: "Cathedral str", buildingNo: 1, meta: ["zip": "AB 124", "floor": "0"]),
  ]
  var birthDay: Date? = myBirthday
  var contactInfo: ContactInfo = ContactInfo()
}


func submitHttpRequest(_ request: URLRequest) async {
  do {
    print("Sending request...")
    let (data, response) = try await URLSession.shared.data(for: request)
    // Handle data and response.
    print("Got response!")
    print(String(data: data, encoding: .utf8) ?? "Data not readable")
    print(response)
  } catch {
    // Handle error.
    print("Error: \(error)")
  }
}

let apiURL = "http://127.0.0.1:8000/form_data/test/"



let encoder = MFEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.nestedFieldsEncodingStrategy = .multipleKeys
let userData = UserData()
if let url = URL(string: apiURL), let data = try? encoder.encode(userData),
   let contentTypeForHttpRequest = encoder.contentTypeForHttpRequest {
  
  
  Task.init {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    request.setValue(contentTypeForHttpRequest, forHTTPHeaderField: "Content-Type")
//    await submitHttpRequest(request)
    
  }
  
  if let formData = encoder.asFormData {
    formData.getAll(name: "addresses[].street")
  }
}

let formData = MFFormData()
formData.append(name: "username", value: userData.profile.username)
if let avatar = swiftLogo {
  formData.append(name: "avatar", value: avatar)
}
formData.append(name: "addresses[]", value: userData.addresses[0].street)
formData.append(name: "addresses[]", value: userData.addresses[1].street)
if let avatarNS = NSImage(named: "Swift_logo.png") {
  formData.append(name: "avatarNS", value: avatarNS)
  
}

formData.set(name: "ранк", value: userData.profile.rank)

for key in formData.keys() {
  print(key)
}
for value in formData.values() {
  print(value)
}
for item in formData.entries() {
  print(item)
}

formData.get(name: "rank")
formData.get(name: "avatarNS")
formData.getAll(name: "addresses[]")


if let url = URL(string: apiURL) {
  let request = formData.asHttpRequest(url: url)
  Task.init {
    await submitHttpRequest(request)
  }
}

