//
//  Compliance.swift
//  MSCP
//
//  Created by Bob Gendler on 8/26/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Foundation

protocol complianceDelegate: class {
    func didRecieveDataUpdate(resultYaml: [rules])
}

class complianceClass {
    var completedResult = String()
    var delegate: complianceDelegate?
    
    var pdfText = [String]()
    func checkCompliance(rulesArray: [rules]) {
        DispatchQueue.main.async {
        for yamlRule in rulesArray {
            if yamlRule.tags.contains("manual") || yamlRule.tags.contains("inherent") || yamlRule.tags.contains("permanent") || yamlRule.tags.contains("n_a"){
                continue
                
            } else {
                if yamlRule.check.first != "/" {
                    //
                }
                try? ExecutionService.executeScript(at: yamlRule.check){ [weak self] result in
                    
                        switch result {
                        case .success(let output):
                            for (_, key) in yamlRule.result {
                                yamlRule.checkCompleted = key == output
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            
                        }
                    }
                    
                }
            }
            
            self.delegate?.didRecieveDataUpdate(resultYaml: rulesArray)
            
        }
        
    }
}
//    func checkCompliance(rules: [rules]) {
//        for yamlRule in rules {
//            if yamlRule.tags.contains("manual") || yamlRule.tags.contains("inherent") || yamlRule.tags.contains("permanent") || yamlRule.tags.contains("n_a"){
//                continue
//            }
//
//        }
//    }

//    func checkCompliance(arguments: String, resultExpected: [String: String], ruleID: String) {
//        if arguments.first != "/" {
//            return
//        }
//            do {
//                try ExecutionService.executeScript(at: arguments){ [weak self] result in
//                    DispatchQueue.main.async {
//                        for (_, value) in resultExpected {
//                            self?.delegate?.didRecieveDataUpdate(result: result, expected: value, ruleID: ruleID)
//
//                        }
//                    }
//                }
//            } catch {
//                print("error")
//
//            }
//
//        return
//
//    }


