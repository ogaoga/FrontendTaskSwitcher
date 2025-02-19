//
//  FTSProjects.swift
//  FrontendTaskSwitcher
//
//  Created by Ogasawara, Tsutomu | Oga | CWDD on 1/30/15.
//  Copyright (c) 2015 Rakuten Front-end. All rights reserved.
//

import Cocoa
import Foundation

class FTSProjects: NSObject {

    dynamic var length = 0 // for KVC
    var data : Dictionary<String, Dictionary<String, AnyObject>> = Dictionary()

    /**
    * Singleton
    * see https://github.com/hpique/SwiftSingleton
    */
    class var sharedInstance: FTSProjects {
        struct Singleton {
            static let instance : FTSProjects = FTSProjects()
        }
        return Singleton.instance
    }
    
    // MARK: -
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(self.data, forKey: "data")
        defaults.synchronize()
    }
    
    func load() {
        let defaults = UserDefaults.standard
        let _data = defaults.object(forKey: "data") as? Dictionary<String, Dictionary<String, AnyObject>>
        if ( _data != nil ) {
            self.data = _data!
            self.length = self.data.count
        }
    }

    /**
    * Adaptor functions
    */
    
    func count() -> Int {
        return self.data.count
    }
    
    subscript(path: String) -> Dictionary<String, Dictionary<String, String>> {
        get {
            return self.data[path] as! Dictionary<String, Dictionary<String, String>>
        }
        set(item) {
            self.add(path: path, project: item as Dictionary<String, AnyObject>)
        }
    }
    
    func add(path: String, project: Dictionary<String, AnyObject>) {
        if ( path.lengthOfBytes(using: String.Encoding.utf8) > 0 ) {
            self.data[path] = project
            self.length = self.data.count
        }
    }
    
    func removeValueForKey(key: String) {
        data.removeValue(forKey: key)
        self.length = self.data.count
    }
}
