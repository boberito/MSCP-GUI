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
    
    var delegate: complianceDelegate?
    // func checkCompliace() -->  ---build out completition handler{
    // dispatchQueue
    // cycle through array
    // executeScript --- this is still paused
    // count items in array
    // if arrayOut.count = arrayIn.count then end loop
    //}
    //at path: String, then completion:
    func checkCompliance(at rulesToCheck: [String], ruleURLS: [URL], then completion: ([rules]) -> ()) {
      
        var finishedArray = [rules]()
        var unCheckedArray = [rules]()

        for rule in rulesToCheck {
            for ruleURL in ruleURLS {
                let yam = rules()
                yam.readRules(ruleURL: ruleURL)
                if yam.check.first == "/" && ruleURL.absoluteString.contains(rule) {
                    unCheckedArray.append(yam)
                }
            }
        }
   var x = 1
        while finishedArray.count != unCheckedArray.count {
     
        for yam in unCheckedArray {
            print("\(x). \(yam.id)")
            try? ExecutionService.executeScript(at: yam.check){ [weak self] result in
                switch result {
                case .success(let output):
                    finishedArray.append(yam)
                    finishedArray.last?.checkResult = output
                    
                case .failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                }
                
            }
            x += 1
        }
            
        }
        
        completion(finishedArray)
    }
}
//        var finishedArray = [rules]()
//        var index = 0
//        while finishedArray.count != rulesToCheck.count {
//            try? ExecutionService.executeScript(at: rulesToCheck[index].check){ [weak self] result in
//                switch result {
//                case .success(let output):
//                    finishedArray.append(rulesToCheck[index])
//                    finishedArray[index].checkResult = output
//
//                case .failure(let error):
//                    print("ERROR: \(error.localizedDescription)")
//                }
//
//            }
//        }



//    func checkCompliance(rulesArray: [rules]) {
//
//            for yamlRule in rulesArray {
//                if yamlRule.tags.contains("manual") || yamlRule.tags.contains("inherent") || yamlRule.tags.contains("permanent") || yamlRule.tags.contains("n_a"){
//                    continue
//
//                } else {
//                    if yamlRule.check.first != "/" {
//                        //
//                    }
//                    try? ExecutionService.executeScript(at: yamlRule.check){ [weak self] result in
//                        DispatchQueue.main.async {
//                        switch result {
//                        case .success(let output):
//                            yamlRule.checkResult = output
//                            print(yamlRule.checkResult)
//                        case .failure(let error):
//                            print("ERROR: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
//
//            self.delegate?.didRecieveDataUpdate(resultYaml: rulesArray)
//
//        }
//
//    }

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


