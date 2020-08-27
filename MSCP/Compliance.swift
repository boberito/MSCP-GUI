//
//  Compliance.swift
//  MSCP
//
//  Created by Bob Gendler on 8/26/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Foundation

class compliance {
    func checkCompliance(arguments: String, resultExpected: String) -> Bool? {
        if arguments.first != "/" {
            return nil
        }
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", arguments.replacingOccurrences(of: "$CURRENT_USER", with: NSUserName())]
        let outpipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = errorPipe
        task.launch()
        task.waitUntilExit()
        
        let data = outpipe.fileHandleForReading.readDataToEndOfFile()
        
        if let resultString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines){
            return resultString == resultExpected
        }
        return nil
    }
    
    func fixCompliance() {
        
    }
}

