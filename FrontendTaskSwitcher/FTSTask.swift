//
//  FTSTask.swift
//  FrontendTaskSwitcher
//
//  Created by Ogasawara, Tsutomu | Oga | CWDD on 2/20/15.
//  Copyright (c) 2015 Rakuten Front-end. All rights reserved.
//

import Cocoa

class FTSTask: NSObject {
    
    private var _task : Process!
    
    deinit {
        if ( self.isRunning() ) {
            _task.terminate()
        }
    }
    
    private func initializeTask() {
        if ( _task == nil ) {
            _task = Process()
        }
        _task.environment = ["PATH": "/bin:/usr/bin:/usr/local/bin"]
        
        let outPipe = Pipe()
        _task.standardOutput = outPipe
        let errorPipe = Pipe()
        _task.standardError = errorPipe
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: Selector(("readCompleted:")),
            name: FileHandle.readCompletionNotification,
            object:outPipe.fileHandleForReading )
        outPipe.fileHandleForReading.readInBackgroundAndNotify()
        
        nc.addObserver(self,
                       selector: Selector(("taskDidTerminated:")),
            name: Process.didTerminateNotification,
            object: _task)
    }

    func start(command: String, currentDirectory: String = "") {
        self.initializeTask()
        if ( currentDirectory != "" ) {
            _task.currentDirectoryPath = currentDirectory
        }
        if ( !self.isRunning() ) {
            _task.launchPath = "/bin/sh"
            _task.arguments = ["-c", command]
            _task.launch()
            print("task start")
        }
    }
    
    func interrupt() {
        if ( self.isRunning() ) {
            _task.interrupt()
        }
    }
    
    func isRunning() -> Bool {
        return _task != nil && _task.isRunning
    }
    
    func readCompleted(notification: NSNotification) {
        let data: NSData? = notification.userInfo?[NSFileHandleNotificationDataItem] as? NSData
        if (data != nil) && data!.length > 0 {
            print(NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)!)
        }
    }
    
    func taskDidTerminated(notification: NSNotification) {
        print("taskDidTerminated")
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: Process.didTerminateNotification, object: _task)
        _task = nil
    }

}
