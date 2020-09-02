//
//  Compliance.swift
//  MSCP
//
//  Created by Bob Gendler on 8/26/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Foundation

protocol complianceDelegate: class {
    func didRecieveDataUpdate(result: Result<String, Error>, expected: String, ruleID: String)
}

class complianceClass {
    var completedResult = String()
    var delegate: complianceDelegate?
    
    func checkCompliance(arguments: String, resultExpected: [String: String], ruleID: String) {
        
        if arguments.first != "/" {
            return
        }
            do {
                try ExecutionService.executeScript(at: arguments){ [weak self] result in
                    DispatchQueue.main.async {
                        for (_, value) in resultExpected {
                            self?.delegate?.didRecieveDataUpdate(result: result, expected: value, ruleID: ruleID)
                        }

                    }
                }
            } catch {
                print("error")
                
            }

        return
        
    }
    
    func fixCompliance() {
        
    }
    
}
