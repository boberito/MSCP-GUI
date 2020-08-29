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
    typealias Handler = (Result<String, Error>) -> Void
    // MARK: - Functions
    static func executeScript(at path: String, then completion: @escaping Handler) throws {
        let process = Process()
//        process.executableURL = programURL
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", path]
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        try process.run()
        DispatchQueue.global(qos: .userInteractive).async {
            process.waitUntilExit()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: outputData, encoding: .utf8) else {
                completion(.failure(ScriptexError.invalidStringConversion))
                return
            }
            completion(.success(output))
        }
    }
}

//let task = Process()
//      task.launchPath = "/bin/bash"
//      task.arguments = ["-c", arguments.replacingOccurrences(of: "$CURRENT_USER", with: NSUserName())]
//      let outpipe = Pipe()
//      let errorPipe = Pipe()
//      task.standardOutput = outpipe
//      task.standardError = errorPipe
//      task.launch()
//      task.waitUntilExit()
