import UIKit
import MFEncoder

var greeting = "Hello, playground"
let someFilePng = URL(filePath: "/Users/artemputilov/Downloads/Screenshot 2023-08-28 at 16.44.33.png")
var swiftLogo = Bundle.main.url(forResource: "Swift_logo", withExtension: "svg")

let apiURL = "http://127.0.0.1:8000/form_data/test/"
let formData = MFFormData()
formData.append(name: "username", value: "JohnSmith")
if let avatar = swiftLogo {
  formData.append(name: "avatar", value: avatar)
}

let avatarUI = UIImage(contentsOfFile: someFilePng.absoluteString)


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
    await submitHttpRequest(request)
  }
}







func submitHttpRequest(_ request: URLRequest) async {
  do {
    print("Sending request...")
    let (data, response) = try await URLSession.shared.data(for: request)
    // Handle data and response.
    print("Got response!")
    print(String(data: data, encoding: .utf8) ?? "Data not readable")
//    print(response)
  } catch {
    // Handle error.
    print("Error: \(error)")
  }
}
