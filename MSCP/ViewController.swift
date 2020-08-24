//
//  ViewController.swift
//  MSCP
//
//  Created by Bob Gendler on 8/19/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var branchSelect: NSPopUpButton!
    @IBOutlet weak var baselineSelect: NSPopUpButton!
    @IBOutlet weak var tableView: NSTableView!
    
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
    
    func loadBaselines() {
        let fm = FileManager.default
        let baselinesPath = defaultLocalRepoPath + "/baselines"
        do {
            let items = try fm.contentsOfDirectory(atPath: baselinesPath)
            
            for item in items {
                baselineSelect.addItem(withTitle: item)
            }
        } catch {
            // failed to read directory – reasons?
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        
     return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
           return 1
       }
    
    @IBAction func branchSelect(_ sender: NSPopUpButton) {
        if branchSelect.titleOfSelectedItem == "" {
            return
        }
        
        baselineSelect.isEnabled = true
        if let selectedItem = branchSelect.titleOfSelectedItem {
            GitHelper().getBranch(branch: selectedItem)
            loadBaselines()
        }
        
        
        
    }
    
    @IBAction func baselineSelect(_ sender: Any) {
        if baselineSelect.titleOfSelectedItem == "" {
            return
        }
        if let selectedBaseline =  baselineSelect.titleOfSelectedItem {
            baselines().readBaseline(baseline: selectedBaseline)
            
        }
    }
}

