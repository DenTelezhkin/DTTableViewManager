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
    
    class Foo : UIViewController, DTTableViewManageable
    {
        var tableView = UITableView()
    }
    
    func testConfigurationAssociation()
    {
        let foo = Foo(nibName: nil, bundle: nil)
        foo.configureTableViewDefaults()
        
        expect(foo.configuration.deleteRowAnimation) == UITableViewRowAnimation.Automatic
    }
    
}
