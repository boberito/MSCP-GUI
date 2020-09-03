//
//  Yams.swift
//  MSCP
//
//  Created by Bob Gendler on 8/24/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Foundation
import Yams


//structure of the baseline yaml
struct baselineYaml: Decodable {
    
    let title: String
    let description: String
    
    let profile: [profile]
    struct profile: Decodable {
        let section: String
        let rules: [String]
    }
}


struct ruleYaml: Decodable {
    let id: String
    let title: String
    let result: [String:String]?
    let discussion: String
    let check: String
    let fix: String
    let references: [String:[String]]
    let macOS: [String]
    let tags: [String]
    let mobileconfig: Bool?
    //let mobileconfigInfo: MobileConfigDomain?
    var finding: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, title, result, discussion, check, fix, references, macOS, tags, mobileconfig
        //    case mobileconfigInfo = "mobileconfig_info"
    }
    
}

//baselines - method to read the baseline Yam
class baselines {
    
    func readBaseline(baseline: String) -> [String] {
        let fullURLString = defaultLocalRepoPath + "/baselines/" + baseline
        let decoder = YAMLDecoder()
        var ruleList = [String]()
        
        if let baselineYam = try? String(contentsOfFile: fullURLString),
            let decodedYamlBaseline = try? decoder.decode(baselineYaml.self, from: baselineYam) {
            for section in decodedYamlBaseline.profile {
                for rule in section.rules {
                    ruleList.append(rule)
                    
                }
            }
            
        } else {
            //other things
        }

        return ruleList
    }
}


//rules class - method to read the rules
class rules {
    var id = String()
    var title = String()
    var discussion = String()
    var check = String()
    var result = [String:String]()
    var references = [String:[String]]()
    var tags = [String]()
    var mobileConfig = Bool()
    
    var checkResult = String()
    var ruleURLs = URL(string: "")
    
    func readRules(ruleURL: URL){
        let decoder = YAMLDecoder()
        if let ruleFile = try? String(contentsOf: ruleURL),
            let decodedYamlRule = try? decoder.decode(ruleYaml.self, from: ruleFile) {
            id = decodedYamlRule.id
            title = decodedYamlRule.title
            discussion = decodedYamlRule.discussion
            check = decodedYamlRule.check
            if let decodedResult = decodedYamlRule.result {
                    result = decodedResult
            }
            references = decodedYamlRule.references
            tags = decodedYamlRule.tags
            mobileConfig = decodedYamlRule.mobileconfig ?? false
        }
        
    }
    
}
