//
//  ExecutionService.swift
//  gov.nist.Scriptex.helper
//
//  Created by Gendler, Bob (Fed) on 8/28/20.
//  Copyright © 2020 Amaris. All rights reserved.
//
import Foundation
struct ExecutionService {
    // MARK: - Constants
    static let programURL = URL(fileURLWithPath: "/usr/bin/env")
    //    typealias Handler = (Result<String, Error>) -> Void
    typealias Handler = ([[String:String]]?) -> Void
    // MARK: - Functions
    static func executeScript(at yams: [[String:String]], then completion: ([[String:String]]) -> ()) {
        var checkedYams = [[String:String]]()
        for yam in yams {
            for (id, check) in yam {
                let process = Process()
                process.launchPath = "/bin/bash"
                process.arguments = ["-c", check]
                let outputPipe = Pipe()
                process.standardOutput = outputPipe
                process.standardError = outputPipe
                try? process.run()
                    process.waitUntilExit()
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    guard let output = String(data: outputData, encoding: .utf8) else {
                        return
                    }
                    checkedYams.append([id:output])
            }
        }
        completion(checkedYams)
    }
}
