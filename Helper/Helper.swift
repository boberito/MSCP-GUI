//
//  Helper.swift
//  gov.nist.Scriptex.helper
//
//  Created by Gendler, Bob (Fed) on 8/28/20.
//  Copyright © 2020 Amaris. All rights reserved.
//

import Foundation

class Helper: NSObject, NSXPCListenerDelegate, HelperProtocol {
    // MARK: - Properties
    
    let listener: NSXPCListener
    
    // MARK: - Initialisation
    
    override init() {
        self.listener = NSXPCListener(machServiceName: HelperConstants.domain)
        super.init()
        self.listener.delegate = self
    }
    
    // MARK: - Functions
    
    // MARK: HelperProtocol
    
    func executeScript(at yams: [[String : String]], then completion: @escaping ([[String : String]]) -> Void) {
        try? ExecutionService.executeScript(at: yams) { (checkedYams) -> () in
            completion(checkedYams)
        }
    }

    
    func run() {
        // start listening on new connections
        self.listener.resume()
        // prevent the terminal application to exit
        RunLoop.current.run()
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
        newConnection.remoteObjectInterface = NSXPCInterface(with: RemoteApplicationProtocol.self)
        newConnection.exportedObject = self
        newConnection.resume()
        
        return true
    }
}

