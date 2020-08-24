//
//  GitHelper.swift
//  masher
//
//  Created by jcadmin on 6/15/20.
//  Copyright © 2020 Orchard & Grove, Inc. All rights reserved.
//

import Foundation

let defaultLocalRepoPath = "/var/tmp/macos_security"

class GitHelper {
    
    let kdefaultRepo = "https://github.com/usnistgov/macos_security.git"
    
    func getRepo(repo: String?=nil) {
        let myGroup = DispatchGroup()
        myGroup.enter()
        DispatchQueue.global().async {
            
            let task = Process()
            task.launchPath = "/usr/bin/git"
            task.arguments = ["clone", repo ?? self.kdefaultRepo, defaultLocalRepoPath]
            task.launch()
            task.waitUntilExit()
            myGroup.leave()
        }
        myGroup.wait()
    }
    
    func listBranches() -> [String]{
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        task.arguments = ["--git-dir=/var/tmp/macos_security/.git", "branch", "-a"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        do {
            try task.run()
        } catch {
            print("Error")
        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        
        var branches = output.components(separatedBy: "\n")
        
        branches.removeFirst(2)
        branches.removeLast()
        return branches
        
    }
    
    func getBranch(branch: String) {
        let myGroup = DispatchGroup()
        myGroup.enter()
        DispatchQueue.global().async {

            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            let branchName = branch.components(separatedBy: "/")[2]
            task.currentDirectoryURL = URL(fileURLWithPath: "/var/tmp/macos_security")
            task.arguments = ["checkout", branchName]
            
            do {
                try task.run()
                myGroup.leave()
            } catch {
                print("Error")
                myGroup.leave()
            }
            
        }
        myGroup.wait()
        
        

//        myGroup.enter()
//        
//        DispatchQueue.global().async {
//            let task = Process()
//            task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
//            task.currentDirectoryURL = URL(fileURLWithPath: "/var/tmp/macos_security")
//            
//            task.arguments = ["pull"]
//            
//            do {
//                try task.run()
//            } catch {
//                print("Error")
//            }
//            myGroup.leave()
//        }
//        myGroup.wait()
        
        
        
    }
}
