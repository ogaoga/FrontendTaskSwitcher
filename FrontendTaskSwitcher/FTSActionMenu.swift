//
//  FTSActionMenu.swift
//  FrontendTaskSwitcher
//
//  Created by Ogasawara, Tsutomu | Oga | CWDD on 2/3/15.
//  Copyright (c) 2015 Rakuten Front-end. All rights reserved.
//

import Cocoa
import Foundation

enum MenuItem : Int {
    case Start = 1
    case Stop
    case Remove
}

class FTSActionMenu: NSMenu, NSMenuDelegate {

    var params : [String : AnyObject]!
    var task : FTSTask!
    
    /*
    let menuItems = [
        ["title": "Start",              "action": "start:",            "key": "", "tag": MenuItem.Start.rawValue],
        ["title": "Stop",               "action": "stop:",             "key": "", "tag": MenuItem.Stop.rawValue],
        ["separator": true],
        ["title": "Open with Terminal", "action": "openWithTerminal:", "key": ""],
        ["title": "Open with Finder",   "action": "openWithFinder:",   "key": ""],
        ["separator": true],
        ["title": "Remove...",          "action": "remove:",            "key": "", "tag": MenuItem.Remove.rawValue],
    ]
     */

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(title aTitle: String) {
        super.init(title: aTitle)
    }
    
    init(params: [String: AnyObject]) {
        super.init(title: "Title")
        
        self.delegate = self
        self.params = params
        self.autoenablesItems = false
        self.initMenuItems()
        self.task = FTSTask()
    }
    
    private func initMenuItems() {
        /*
        for item in items {
            var menuItem : NSMenuItem!
            if ( item["separator"] as? Bool == true ) {
                menuItem = NSMenuItem.separator()
            }
            else {
                menuItem = NSMenuItem(title: item["title"] as String,
                    action: Selector(item["action"] as String),
                    keyEquivalent: item["key"] as String)
                menuItem.target = self
                menuItem.tag = item["tag"] as? Int ?? 0
            }
            self.addItem(menuItem)
        }
         */
        addItem(NSMenuItem(title: "Start", action: nil, keyEquivalent: ""))
    }
    
    func start(sender: AnyObject) {
        let dir = self.params["directory"] as! String
        self.task.start(command: "grunt serve", currentDirectory: dir)
    }
    
    func stop(sender: AnyObject) {
        self.task.interrupt()
    }
    
    func openWithTerminal(sender: AnyObject) {
        let dir = self.params["directory"] as! String
        self.task.start(command: "open -a /Applications/Utilities/Terminal.app " + dir + ";")
    }
    
    func openWithFinder(sender: AnyObject) {
        let dir = self.params["directory"] as! String
        self.task.start(command: "open " + dir + ";")
    }
    
    func remove(sender: AnyObject) {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.informational
        alert.informativeText = NSLocalizedString("Confirmation", comment: "")
        alert.messageText = NSLocalizedString("Do you want to remove the task?",
            comment: "Message of confirmation Dialog")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Remove")
        NSApplication.shared().activate(ignoringOtherApps: true)
        let result = alert.runModal()
        if ( result == NSAlertSecondButtonReturn ) {
            // remove
            self.removeProject()
        }
    }
    
    // MARK: - 
    
    func removeProject() {
        // stop task
        if self.task.isRunning() {
            self.stop(sender: self)
        }
        // remove project
        let path = self.params["path"] as! String
        FTSProjects.sharedInstance.removeValueForKey(key: path)
    }
    
    // MARK: - menu delegate
    
    func menuWillOpen(_ menu: NSMenu) {
        if ( self.task.isRunning() ) {
            menu.item(withTag: MenuItem.Start.rawValue)?.isHidden = true
            menu.item(withTag: MenuItem.Stop.rawValue)?.isHidden = false
            menu.item(withTag: MenuItem.Remove.rawValue)?.isEnabled = false
        }
        else {
            menu.item(withTag: MenuItem.Start.rawValue)?.isHidden = false
            menu.item(withTag: MenuItem.Stop.rawValue)?.isHidden = true
            menu.item(withTag: MenuItem.Remove.rawValue)?.isEnabled = true
        }
    }
}
