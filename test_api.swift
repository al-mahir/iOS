import Foundation

let url = URL(string: "https://virtserver.swaggerhub.com/iti-ff4/AuthN-AuthZ-API/1.4.0/auth/user/login")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.httpBody = try! JSONSerialization.data(withJSONObject: ["email":"test@example.com","password":"password"])

let sema = DispatchSemaphore(value: 0)
let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let data = data, let str = String(data: data, encoding: .utf8) {
        print("Response: \(str)")
    } else if let error = error {
        print("Error: \(error)")
    }
    sema.signal()
}
task.resume()
sema.wait()
