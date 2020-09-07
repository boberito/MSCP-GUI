import Foundation
struct ExecutionService {
    // MARK: - Constants
    static let programURL = URL(fileURLWithPath: "/usr/bin/env")
    // MARK: - Functions
    static func executeScript(at yams: [[String:String]], then completion: @escaping ([[String:String]]) -> Void) throws {
        let remote = try HelperRemote().getRemote()
        remote.executeScript(at: yams) { (resultYams) in
            completion(resultYams)
        }
    }
}
