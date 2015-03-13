//
//  FrontendTaskSwitcherTests.swift
//  FrontendTaskSwitcherTests
//
//  Created by Ogasawara, Tsutomu | Oga | CWDD on 1/29/15.
//  Copyright (c) 2015 Rakuten Front-end. All rights reserved.
//

import Cocoa
import XCTest

class FrontendTaskSwitcherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        
        let projects = FTSProjects.sharedInstance
        projects.add("/tmp", project: ["path": "/tmp", "type": "grunt"])
        XCTAssert(projects.length == 1, "Pass")
        projects["/abc"] = ["path": "/abc", "type": "grunt"]
        XCTAssert(projects.length == 2, "Pass")
        XCTAssert(projects["/tmp"]["path"] as! String == "/tmp" as String, "Pass")
        XCTAssert(projects["/abc"]["type"] as! String == "grunt", "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
