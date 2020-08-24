//
//  ViewController.swift
//  MSCP
//
//  Created by Bob Gendler on 8/19/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var branchSelect: NSPopUpButton!
    
    @IBOutlet weak var baselineSelect: NSPopUpButton!
    
    let gitty = GitHelper()
    var path: String = ""
    
    override func viewDidAppear() {
        if !FileManager.default.fileExists(atPath: defaultLocalRepoPath) {
            GitHelper().getRepo()
        }
        let branchList = GitHelper().listBranches()
        loadBranchSelector(branches: branchList)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func loadBranchSelector(branches: [String]) {
        
        
        for branch in branches {
            
            branchSelect.addItem(withTitle: branch)
        }
    }
    
    
    
    @IBAction func branchSelect(_ sender: NSPopUpButton) {
        if branchSelect.titleOfSelectedItem == "" {
            return
        }
        
        baselineSelect.isEnabled = true
        if let selectedItem = branchSelect.titleOfSelectedItem {
                
            GitHelper().getBranch(branch: selectedItem)
            let fm = FileManager.default
            let baselinesPath = defaultLocalRepoPath + "/baselines"
            do {
                let items = try fm.contentsOfDirectory(atPath: baselinesPath)
                
                for item in items {
                    print("Found \(item)")
                }
            } catch {
                // failed to read directory – reasons?
            }
        }
        
        
        
    }
    
}

