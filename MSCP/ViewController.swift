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
    @IBOutlet weak var complianceButton: NSButtonCell!
    
    var ruleURLs = [URL]()
    var rulesStatus = [[String: Int]]()
    
    override func viewDidAppear() {
        if !FileManager.default.fileExists(atPath: defaultLocalRepoPath) {
            GitHelper().getRepo()
        }
        let branchList = GitHelper().listBranches()
        getDir()
        loadBranchSelector(branches: branchList)
        branchSelect.selectItem(withTitle: "origin/master")
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
        getDir()
        tableView.reloadData()
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
        if let selectedBaseline =  baselineSelect.titleOfSelectedItem {
            let baselineRules = baselines().readBaseline(baseline: selectedBaseline)
            if tableColumn?.identifier.rawValue == "checkbox" {
                guard let checkboxCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkCell"), owner: self) as? CustomTableCell else { return nil }
                
                if let ruleName = ruleURLs[row].absoluteString.components(separatedBy: "/").last?.components(separatedBy: ".")[0] {
                    if baselineRules.contains(ruleName) {
                        checkboxCell.checkBox.integerValue = 1
                    } else {
                        checkboxCell.checkBox.integerValue = 0
                    }
                    checkboxCell.checkBox.title = ruleName
                    rulesStatus.append([ruleName:checkboxCell.checkBox.integerValue])
                }
                return checkboxCell
            }
            
        }
        
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
            getDir()
            tableView.reloadData()
        }
        
        
        
    }
    
    @IBAction func baselineSelect(_ sender: Any) {
        if baselineSelect.titleOfSelectedItem == "" {
            return
        }
        getDir()
        tableView.reloadData()
    }
    

    @IBAction func complianceReport(_ sender: Any) {
        for rule in rulesStatus {
            for (key, value) in rule {
                for ruleURL in ruleURLs {
                    if ruleURL.absoluteString.contains(key) && value == 1{
                        rules().readRules(ruleURL: ruleURL)
                    }
                }
            }
            
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

