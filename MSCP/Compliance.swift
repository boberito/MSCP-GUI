//
//  Compliance.swift
//  MSCP
//
//  Created by Bob Gendler on 8/26/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Foundation

class compliance {
    var completedResult = String()
    
    func checkCompliance(arguments: String, resultExpected: [String:String]) -> Bool? {
        if arguments.first != "/" {
            return nil
        }
        //
        //        let task = Process()
        //        task.launchPath = "/bin/bash"
        //        task.arguments = ["-c", arguments.replacingOccurrences(of: "$CURRENT_USER", with: NSUserName())]
        //        let outpipe = Pipe()
        //        let errorPipe = Pipe()
        //        task.standardOutput = outpipe
        //        task.standardError = errorPipe
        //        task.launch()
        //        task.waitUntilExit()
        DispatchQueue.global().async {
//        DispatchQueue.main.async {
            do {
                try ExecutionService.executeScript(at: arguments){ [weak self] result in
                    switch result {
                        
                    case .success(let output):
                        self?.completedResult = output
                        
                    case .failure(let error):
                        self?.completedResult = error.localizedDescription
                    }
                    
                }
            } catch {
                print("error")
                
            }
        }
        for (_, value) in resultExpected {
            
            return value == completedResult
        }
        
        return nil
        
    }
    
    func fixCompliance() {
        
    }
    
}
