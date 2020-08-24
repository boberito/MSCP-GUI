//
//  Yams.swift
//  MSCP
//
//  Created by Bob Gendler on 8/24/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Foundation
import Yams

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
    let check: String
    let result: [String:String]
    let fix: String
    let references: references
    let macOS: String
    let tags: [String]
    let mobileconfig: Bool
    
    struct references: Decodable {
        let cce: String
        let cci: String
        let nist80053r4: [String]
        let srg: [String]
        let disa_stig: [String]
        
        private enum CodingKeys: String, CodingKey {
            case cce, cci, srg, disa_stig,
            nist80053r4 = "800-53r4"
        }
    }
        
    
}

class baselines {
    func readBaseline(baseline: String) {
        let fullURLString = defaultLocalRepoPath + "/baselines/" + baseline
        let decoder = YAMLDecoder()
        if let baselineYam = try? String(contentsOfFile: fullURLString),
            let decodedYamlBaseline = try? decoder.decode(baselineYaml.self, from: baselineYam) {
            for section in decodedYamlBaseline.profile {
                for rule in section.rules {
                    print(rule)
                }
            }
            
            } else {
                //other things
            }
            
        
    }
}
