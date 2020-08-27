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
    
    var ruleURLs = [URL]()
    
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
        tableView.delegate = self
        tableView.dataSource = self
        getDir()
        tableView.reloadData()
        
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
//        if let selectedBaseline =  baselineSelect.titleOfSelectedItem {
//            let baselineRules = baselines().readBaseline(baseline: selectedBaseline)
//
//
//        }
        
        if tableColumn?.identifier.rawValue == "checkbox" {
            guard let checkboxCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkCell"), owner: self) as? CustomTableCell else { return nil }
            checkboxCell.checkBox.integerValue = 0
            if let ruleName = ruleURLs[row].absoluteString.components(separatedBy: "/").last?.components(separatedBy: ".")[0] {
                checkboxCell.checkBox.title = ruleName
                
            }
            return checkboxCell
        }
        
//        if tableColumn?.identifier.rawValue == "rule_id" {
//            guard let ruleIDCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ruleIDCell"), owner: self) as? NSTableCellView else { return nil }
//            if let ruleName = ruleURLs[row].absoluteString.components(separatedBy: "/").last?.components(separatedBy: ".")[0] {
//                ruleIDCell.textField?.stringValue = ruleName
//
//            }
//            return ruleIDCell
//        }

        return nil
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ruleURLs.count
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
            getDir()
            tableView.reloadData()
        }
    }
    
    func getDir() {
        ruleURLs.removeAll()
        
        if let folders = try? FileManager.default.contentsOfDirectory(at: URL.init(fileURLWithPath: defaultLocalRepoPath + "/rules"), includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles) {
            for folder in folders {
                let temprules = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: [], options: .init())
                //            let inherent = defaultLocalRepoPath + "/rules/inherent/"
                let srg = defaultLocalRepoPath + "/rules/srg/"
                //            let not_applicable = defaultLocalRepoPath + "/rules/not_applicable/"
                let supplemental = defaultLocalRepoPath + "/rules/supplemental/"
                //            let permanent = defaultLocalRepoPath + "/rules/permanent/"
                if folder.absoluteString.contains(srg) || folder.absoluteString.contains(supplemental) {
                    continue
                } else {
                    ruleURLs.append(contentsOf: temprules!)
                }
            }
            
        }
        
    }
}

