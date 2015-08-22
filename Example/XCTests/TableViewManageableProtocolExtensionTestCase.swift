//
//  TableViewManageableProtocolExtensionTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 20.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTTableViewManager
import Nimble

class TableViewManageableProtocolExtensionTestCase: XCTestCase {
    
    func testConfigurationAssociation()
    {
        let foo = DTTestTableViewController(nibName: nil, bundle: nil)
        foo.manager.startManagingWithDelegate(foo)
        
        expect(foo.manager) != nil
        expect(foo.manager) == foo.manager // Test if lazily instantiating using associations works correctly
    }
    
}
