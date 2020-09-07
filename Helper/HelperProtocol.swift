//
//  HelperProtocol.swift
//  gov.nist.Scriptex.helper
//
//  Created by Gendler, Bob (Fed) on 8/28/20.
//  Copyright © 2020 Amaris. All rights reserved.
//

import Foundation

@objc(HelperProtocol)
public protocol HelperProtocol {
    @objc func executeScript(at yams: [[String:String]], then completion: @escaping ([[String:String]]) -> Void)
}
