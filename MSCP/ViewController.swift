//
//  ViewController.swift
//  MSCP
//
//  Created by Bob Gendler on 8/19/20.
//  Copyright © 2020 Bob Gendler. All rights reserved.
//

import Cocoa
import os
import PDFAuthor
import Cassowary

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource{
    
    @IBOutlet weak var branchSelect: NSPopUpButton!
    @IBOutlet weak var baselineSelect: NSPopUpButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var complianceButton: NSButtonCell!
    
    //keep track of all the rule paths
    //keep track if the rule is clicked or not
    //    var compliance = complianceClass()
    var ruleURLs = [URL]()
    var rulesStatus = [[String: Int]]()
    
    
    //load up git stuff as the UI loads
    override func viewDidAppear() {
        
        //download the repo if it doesn't exist
        if !FileManager.default.fileExists(atPath: defaultLocalRepoPath) {
            GitHelper().getRepo()
        }
        
        //list the branches and load the menus
        let branchList = GitHelper().listBranches()
        getDir()
        loadBranchSelector(branches: branchList)
        branchSelect.selectItem(withTitle: "")
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        //        compliance.delegate = self
        
        
        //reload the table with the data
        getDir()
        tableView.reloadData()
        
    }
    
    //fills in the branch drop down
    func loadBranchSelector(branches: [String]) {
        for branch in branches {
            branchSelect.addItem(withTitle: branch)
        }
        getDir()
        tableView.reloadData()
    }
    
    
    //fills Baseline dropdown
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
    
    //load table data
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        //if a baseline is selected, get the rules for it
        if let selectedBaseline =  baselineSelect.titleOfSelectedItem {
            //            rulesStatus.append([baselines().readBaseline(baseline: selectedBaseline):0])
            let baselineRules = baselines().readBaseline(baseline: selectedBaseline)
            //            rulesStatus baselineRules:0
            guard let checkboxCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "checkCell"), owner: self) as? CustomTableCell else { return nil }
            
            //if the rule in the baseline matches one in URL list, check it
            if let ruleName = ruleURLs[row].absoluteString.components(separatedBy: "/").last?.components(separatedBy: ".")[0] {
                
                if baselineRules.contains(ruleName) {
                    checkboxCell.checkBox.integerValue = 1
                    //                    rulesStatus.append([ruleName:checkboxCell.checkBox.integerValue])
                } else {
                    checkboxCell.checkBox.integerValue = 0
                    //                    rulesStatus.append([ruleName:checkboxCell.checkBox.integerValue])
                }
                checkboxCell.checkBox.title = ruleName
                
                
            }
            return checkboxCell
        }
        
        return nil
    }
    
    @IBAction func checkboxAction(_ sender: NSButton) {
        //        print(sender.title)
        if baselineSelect.title == "" {
            rulesStatus.append([sender.title:sender.integerValue])
        } else {
            
            rulesStatus = rulesStatus.map({
                var dict = $0
                let keyExists = dict[sender.title] != nil
                if keyExists{
                    dict[sender.title] = sender.integerValue
                }
                return dict
            })
        }
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return ruleURLs.count
        
    }
    
    //if a branch is selected, load the baselines
    @IBAction func branchSelect(_ sender: NSPopUpButton) {
        if branchSelect.titleOfSelectedItem == "" {
            return
        }
        rulesStatus.removeAll()
        baselineSelect.isEnabled = true
        if let selectedItem = branchSelect.titleOfSelectedItem {
            
            GitHelper().getBranch(branch: selectedItem)
            loadBaselines()
            getDir()
            tableView.reloadData()
            
        }
        
        
        
    }
    
    //baseline selected, reload the table data
    @IBAction func baselineSelect(_ sender: Any) {
        if baselineSelect.titleOfSelectedItem == "" {
            return
        }
        rulesStatus.removeAll()
        if let selectedBaseline =  baselineSelect.titleOfSelectedItem {
            //            rulesStatus.append([baselines().readBaseline(baseline: selectedBaseline):0])
            let baselineRules = baselines().readBaseline(baseline: selectedBaseline)
            for ruleURL in ruleURLs {
                if let ruleName = ruleURL.absoluteString.components(separatedBy: "/").last?.components(separatedBy: ".")[0]{
                    if baselineRules.contains(ruleName) {
                        rulesStatus.append([ruleName:1])
                    } else {
                        rulesStatus.append([ruleName:0])
                    }
                }
            }
        }
        
        tableView.reloadData()
        
    }
    
    
    @IBAction func remediateButton(_ sender: Any) {
        var checkRules = [String]()
        for rule in rulesStatus {
            for (key,value) in rule{
                if value == 1 {
                    checkRules.append(key)
                    
                }
            }
        }
        var checkURLs = [URL]()
        var yams = [rules]()
        var uncheckedRules = [[String:String]]()
        for ruleURL in ruleURLs {
            for checkRule in checkRules {
                let yam = rules()
                if ruleURL.absoluteString.contains(checkRule) {
                    checkURLs.append(ruleURL)
                    yam.readRules(ruleURL: ruleURL)
                    yams.append(yam)
                    uncheckedRules.append([yam.id: yam.check.replacingOccurrences(of: "$CURRENT_USER", with: NSUserName())])
                }
                
            }
            
        }
        try? ExecutionService.executeScript(at: uncheckedRules) { (finishedArray) -> () in
            for yam in yams {
                for checked in finishedArray {
                    for (key, value) in checked {
                        if yam.id == key {
                            yam.checkResult = value
                        }
                    }
                }
                
            }
            DispatchQueue.main.async {
                // send it off somewhere else to do things
                self.remediate(yams: yams)
                yams.removeAll()
            }
        }
        
    }
    
    
    
    // run a compliance report on all the rules selected
    @IBAction func complianceReport(_ sender: Any) {
        
        var checkRules = [String]()
        for rule in rulesStatus {
            for (key,value) in rule{
                if value == 1 {
                    checkRules.append(key)
                    
                }
                
            }
            
        }
        var checkURLs = [URL]()
        //        var ruleURLs = [URL]()
        
        var yams = [rules]()
        var uncheckedRules = [[String:String]]()
        for ruleURL in ruleURLs {
            for checkRule in checkRules {
                let yam = rules()
                if ruleURL.absoluteString.contains(checkRule) {
                    checkURLs.append(ruleURL)
                    yam.readRules(ruleURL: ruleURL)
                    yams.append(yam)
                    uncheckedRules.append([yam.id: yam.check.replacingOccurrences(of: "$CURRENT_USER", with: NSUserName())])
                }
                
            }
            
        }
        
        try? ExecutionService.executeScript(at: uncheckedRules) { (finishedArray) -> () in
            for yam in yams {
                for checked in finishedArray {
                    for (key, value) in checked {
                        if yam.id == key {
                            yam.checkResult = value
                        }
                    }
                }
                
            }
            DispatchQueue.main.async {
                self.createPDF(yams: yams)
                yams.removeAll()
            }
            
        }
        
    }
    
    // get all the rules in the rules directory and sub directories
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
    
    func remediate(yams: [rules]) {
        for yam in yams {
            if yam.tags.contains("inherent") || yam.tags.contains("permanent") || yam.tags.contains("n_a") || yam.tags.contains("manual") {
                continue
            }
            
            if yam.mobileConfig {
                continue
            }
            
            
            var failArray = [[String:String]]()
            for (_, expectedResult) in yam.result {
                if yam.checkResult.dropLast() != expectedResult {
                let bashScript = "[source,bash]"
                if yam.fix.contains(bashScript) {
                    let command = yam.fix.components(separatedBy: "----")[1]
                    failArray.append([yam.id: command])
                    
                }
                }
            }
            try? ExecutionService.executeScript(at: failArray) { (finishedArray) -> () in
                for yam in yams {
                    for checked in finishedArray {
                        for (key, value) in checked {
                            if yam.id == key {
                                yam.checkResult = value
                            }
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    let alert = NSAlert()
                     alert.messageText = "Remediation Complete"
                     alert.informativeText = "All script fixes have been run"
                     alert.alertStyle = .informational
                     alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
            
        }
        
    }
    
    func createPDF(yams: [rules]) {
        
        var reportText = [String]()
        var pageSpec = PDFPageSpecifications(size: .A4)
        pageSpec.contentInsets = PDFEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        pageSpec.backgroundInsets = PDFEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        //        let myDoc = PDFContent(pageSpecifications: pageSpec)
        let mainDoc = MultiplePages(pageSpecifications: pageSpec)
        var x = 1
        
        var pass = 0
        var fail = 0
        for yam in yams {
            var passFail = String()
            for (_, expectedResult) in yam.result {
                if yam.checkResult.dropLast() == expectedResult {
                    passFail = "PASS"
                    pass += 1
                } else {
                    passFail = "FAIL"
                    fail += 1
                }
            }
            if yam.check.first != "/" {
                for tag in yam.tags {
                    if tag == "inherent" {
                        passFail = "Inherent"
                    }
                    if tag == "permanent" {
                        passFail = "Permanent"
                    }
                    if tag == "n_a" {
                        passFail = "Not Applicable"
                    }
                    if tag == "manual" {
                        passFail = "Manual Check"
                    }
                }
            }
            
            reportText.append("\(x). [\(passFail)] \(yam.title)")
            x += 1
        }
        let myTitle = TitleChapter(pageSpecifications: pageSpec)
        
        if let selectedBaseline =  baselineSelect.titleOfSelectedItem {
            let baseline = baselines()
            baseline.readBaseline(baseline: selectedBaseline)
            
            myTitle.title = "macOS Compliance Report\n\(baseline.title)"
        }
        
        let footer = regularPage(pageSpecifications: pageSpec)
        var percentage = Double()
        
        percentage = round(100*(Double(Double(pass)/(Double(pass)+Double(fail)))))
        footer.content = """
        
        Compliance Score
        --------------------------------------
        Number of passed test: \(pass)
        Number of failed tests: \(fail)
        Percentage passed: \(percentage)%
"""
        //        let footer = regularPage(pageSpecifications: pageSpec)
        //        foot
        
        //        print(reportText)
        mainDoc.contentText = reportText
        mainDoc.checkCount = reportText.count
        let document = PDFAuthorDocument().with{
            $0.addChapter(myTitle)
            $0.addChapter(mainDoc)
            $0.addChapter(footer)
            
            
        }
        
        let savePanel = NSSavePanel()
        savePanel.title = "Save Example..."
        savePanel.prompt = "Save to file"
        savePanel.nameFieldLabel = "Pick a name"
        savePanel.nameFieldStringValue = "example.pdf"
        savePanel.isExtensionHidden = false
        savePanel.canSelectHiddenExtension = true
        savePanel.allowedFileTypes = ["pdf"]
        
        let result = savePanel.runModal()
        
        switch result {
        case .OK:
            guard let saveURL = savePanel.url else { return }
            //            do {
            try? document.generate(to: saveURL) { progress in
                //                        try document.generate(to: URL(fileURLWithPath: ("~/Desktop/test1.pdf" as NSString).expandingTildeInPath)) { progress in
                print ("Progress : \(Int(progress * 100))%")
            }

        case .cancel:
            print("User Cancelled")
        default:
            print("Panel shouldn't be anything other than OK or Cancel")
        }
    }
}

