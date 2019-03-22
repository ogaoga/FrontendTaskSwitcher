//
//  FTSTasksMenu.swift
//  FrontendTaskSwitcher
//
//  Created by Ogasawara, Tsutomu | Oga | CWDD on 1/29/15.
//  Copyright (c) 2015 Rakuten Front-end. All rights reserved.
//

import Cocoa

class FTSTasksMenu: NSMenu, NSMenuDelegate {

    var statusItem : NSStatusItem!

    @IBOutlet weak var subMenu: NSMenu!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.delegate = self
        
        // setup
        let systemStatusBar = NSStatusBar.system()
        let length : CGFloat = -1.0 // instead of NSVariableStatusItemLength
        self.statusItem = systemStatusBar.statusItem(withLength: length)
        self.statusItem.highlightMode = true
        self.statusItem.title = "📦"
        self.statusItem.menu = self
        
        // observe
        FTSProjects.sharedInstance.addObserver(self,
                                               forKeyPath: "length", options: NSKeyValueObservingOptions.new, context: nil);
        
        // update
        self.updateProjects()
    }
    
    // MARK: -
    
    private func getDirectoryURL() -> NSURL! {
        // show file open dialog
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        let result = panel.runModal()
        return (result == NSOKButton) ? panel.directoryURL! as NSURL : nil;
    }

    private func getTaskConfigFilePathAndType(directory: NSURL) -> [String: String]! {
        let manager = FileManager.default
        if ( directory.path != nil && directory.path?.lengthOfBytes(using: String.Encoding.utf8) ?? 0 > 0 ) {
            let path = directory.path!+"/Gruntfile.js"
            if manager.fileExists(atPath: path) {
                let name = directory.pathComponents?.last as String?
                return ["name": name ?? "", "path": path, "directory": directory.path!, "type": "grunt"]
            }
        }
        return nil
    }

    private func removeProjects() {
        // remove current menu items
        for item in self.items as [NSMenuItem] {
            if ( item.isSeparatorItem ) {
                break
            }
            else {
                self.removeItem(item)
            }
        }
    }
    
    private func updateProjects() {
        // remove projects
        self.removeProjects()
        // add projects
        if ( FTSProjects.sharedInstance.length > 0 ) {
            // add new menu items
            for (_, item) in FTSProjects.sharedInstance.data {
                let menuItem = NSMenuItem(title: item["name"] as! String, action: nil, keyEquivalent: "")
                menuItem.isEnabled = true
                menuItem.submenu = FTSActionMenu(params: item)
                self.insertItem(menuItem, at: 0)
            }
        }
        else {
            self.insertItem(NSMenuItem(title: "No project", action: nil, keyEquivalent: ""), at: 0)
        }
    }

    // MARK: -
    
    /**
    *  MARK: Observe
    */
    func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutableRawPointer) {
        if keyPath == "length" {
            self.updateProjects()
        }
    }
    
    /**
     * MARK: Actions
     */
    @IBAction func addProject(sender: AnyObject) {
        let directoryURL = self.getDirectoryURL()
        if ( directoryURL != nil ) {
            let data = self.getTaskConfigFilePathAndType(directory: directoryURL!)
            if ( data != nil && data?["path"] != nil ) {
                FTSProjects.sharedInstance.add(path: (data?["path"])!, project: data! as Dictionary<String, AnyObject>)
            }
        }
        else {
            // TODO: show message (already registered)
        }
    }

    // MARK: - Menu Delegate
    func menuWillOpen(_ menu: NSMenu) {
        
        // set running indicator
        let items = self.items
        for item in items as [NSMenuItem] {
            item.state = NSOffState
            if let submenu = item.submenu as? FTSActionMenu {
                if let task = submenu.task {
                    if ( task.isRunning() ) {
                        item.state = NSOnState
                    }
                }
            }
        }
    }
    
}
