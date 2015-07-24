//
//  DatasourceTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import ModelStorage
import DTTableViewManager
import Nimble

class DatasourceTestCase: XCTestCase {

    var controller : DTTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = DTTableViewController()
        controller.tableView = UITableView()
        let _ = controller.view
        controller.storage = MemoryStorage()
        
        controller.registerCellClass(NibCell)
    }
    
    func testTableItemAtIndexPath()
    {
        controller.memoryStorage.addItems([3,2,1,6,4], toSection: 0)
        
        expect(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0))) == true
        expect(self.controller.verifyItem(3, atIndexPath: indexPath(0, 0))) == true
        expect(self.controller.memoryStorage.itemAtIndexPath(indexPath(56, 0))).to(beNil())
    }
    
    func testShouldReturnCorrectNumberOfTableItems()
    {
        controller.memoryStorage.addItems([1,1,1,1], toSection: 0)
        controller.memoryStorage.addItems([2,2,2], toSection: 1)
        let tableView = controller.tableView
        expect(self.controller.tableView(tableView, numberOfRowsInSection: 0)) == 4
        expect(self.controller.tableView(tableView, numberOfRowsInSection: 1)) == 3
    }
    
    func testShouldReturnCorrectNumberOfSections()
    {
        controller.memoryStorage.addItem(1, toSection: 0)
        controller.memoryStorage.addItem(4, toSection: 3)
        controller.memoryStorage.addItem(2, toSection: 2)
        
        expect(self.controller.numberOfSectionsInTableView(self.controller.tableView)) == 4
    }
    
    func testShouldSetSectionTitles()
    {
        controller.memoryStorage.setSectionHeaderModels(["one","two"])
        let tableView = self.controller.tableView
        expect(self.controller.tableView(tableView, titleForHeaderInSection: 0)) == "one"
        expect(self.controller.tableView(tableView, titleForHeaderInSection: 1)) == "two"
    }
    
    func testSHouldSetSectionFooterTitles()
    {
        controller.memoryStorage.setSectionFooterModels(["one","two"])
        let tableView = self.controller.tableView
        expect(self.controller.tableView(tableView, titleForFooterInSection: 0)) == "one"
        expect(self.controller.tableView(tableView, titleForFooterInSection: 1)) == "two"
    }
    
    func testShouldHandleAbsenceOfHeadersFooters()
    {
        controller.memoryStorage.addItem(1, toSection: 0)
        controller.memoryStorage.addItem(2, toSection: 1)
        
        controller.tableView(controller.tableView, titleForHeaderInSection: 0)
        controller.tableView(controller.tableView, titleForFooterInSection: 1)
    }

    func testShouldAddTableItems()
    {
        controller.memoryStorage.addItems([3,2], toSection: 0)
        
        expect(self.controller.memoryStorage.itemsInSection(0)?.count) == 2
    }
    
    //MARK: TODO Check this test on Swift 2.0
    
//    func testShouldInsertTableItem()
//    {
//        controller.memoryStorage.addItems([2,4,6], toSection: 0)
//        controller.memoryStorage.insertItem(1, toIndexPath: indexPath(2, 0))
//        
//        expect(self.controller.memoryStorage.itemsInSection(0)?.count) == 4
//        expect(self.controller.verifyItem(1, atIndexPath: indexPath(2, 0))) == true
//        expect(self.controller.verifyItem(6, atIndexPath: indexPath(3, 0))) == true
//    }
    
    func testReplaceItem()
    {
        controller.memoryStorage.addItems([1,3], toSection: 0)
        controller.memoryStorage.addItems([4,6], toSection: 1)
        controller.memoryStorage.replaceItem(3, replacingItem: 2)
        controller.memoryStorage.replaceItem(4, replacingItem: 5)
        
        expect(self.controller.memoryStorage.itemsInSection(0)?.count) == 2
        expect(self.controller.memoryStorage.itemsInSection(1)?.count) == 2
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(1, 0))) == true
        expect(self.controller.verifyItem(5, atIndexPath: indexPath(0, 1))) == true
    }
    
    func testRemoveItem()
    {
        controller.memoryStorage.addItems([1,3,2,4], toSection: 0)
        controller.memoryStorage.removeItems([1,4,3,5])
        
        expect(self.controller.memoryStorage.itemsInSection(0)?.count) == 1
        expect(self.controller.verifyItem(2, atIndexPath: indexPath(0, 0))) == true
    }
    
    func testRemoveItems()
    {
        controller.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.memoryStorage.removeAllTableItems()
        
        expect(self.controller.memoryStorage.itemsInSection(0)?.count) == 0
    }
    
    func testMovingItems()
    {
        controller.memoryStorage.addItems([1,2,3], toSection: 0)
        controller.memoryStorage.moveTableItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(2, 0))
        
        expect(self.controller.verifySection([2,3,1], withSectionNumber: 0)) == true
    }
    
    func testShouldNotCrashWhenMovingToBadRow()
    {
        controller.memoryStorage.addItem([1,2,3], toSection: 0)
        
        controller.memoryStorage.moveTableItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(2, 1))
    }
    
    func testShouldNotCrashWhenMovingFromBadRow()
    {
        controller.memoryStorage.addItem([1,2,3], toSection: 0)
        controller.memoryStorage.moveTableItemAtIndexPath(indexPath(0, 1), toIndexPath: indexPath(0, 0))
    }
    
    func testShouldMoveSections()
    {
        controller.memoryStorage.addItem(1, toSection: 0)
        controller.memoryStorage.addItem(2, toSection: 1)
        controller.memoryStorage.addItem(3, toSection: 2)
        
        controller.memoryStorage.moveTableViewSection(0, toSection: 1)
        
        expect(self.controller.verifySection([2], withSectionNumber: 0)) == true
        expect(self.controller.verifySection([1], withSectionNumber: 1)) == true
        expect(self.controller.verifySection([3], withSectionNumber: 2)) == true
    }
    
    func testShouldDeleteSections()
    {
        controller.memoryStorage.addItem(0, toSection: 0)
        controller.memoryStorage.addItem(1, toSection: 1)
        controller.memoryStorage.addItem(2, toSection: 2)
        
        controller.memoryStorage.deleteSections(NSIndexSet(index: 1))
        
        expect(self.controller.memoryStorage.sections.count) == 2
        expect(self.controller.verifySection([2], withSectionNumber: 1))
    }
    
    func testShouldShowTitlesOnEmptySection()
    {
        controller.memoryStorage.setSectionHeaderModels(["Foo"])
        controller.displayHeaderOnEmptySection = false
        expect(self.controller.tableView(self.controller.tableView, titleForHeaderInSection: 0)).to(beNil())
    }
    
    func testShouldShowTitleOnEmptySectionFooter()
    {
        controller.memoryStorage.setSectionFooterModels(["Foo"])
        controller.displayFooterOnEmptySection = false
        expect(self.controller.tableView(self.controller.tableView, titleForFooterInSection: 0)).to(beNil())
    }
    
    func testShouldShowViewHeaderOnEmptySEction()
    {
        controller.registerHeaderClass(NibView)
        controller.displayHeaderOnEmptySection = false
        controller.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beNil())
    }
    
    func testShouldShowViewFooterOnEmptySection()
    {
        controller.registerFooterClass(NibView)
        controller.displayFooterOnEmptySection = false
        controller.memoryStorage.setSectionFooterModels([1])
        expect(self.controller.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beNil())
    }
    
    func testSupplementaryKindsShouldBeSet()
    {
        expect(self.controller.memoryStorage.supplementaryHeaderKind) == DTTableViewElementSectionHeader
        expect(self.controller.memoryStorage.supplementaryFooterKind) == DTTableViewElementSectionFooter
    }
    
    func testHeaderViewShouldBeCreated()
    {
        controller.registerHeaderClass(NibHeaderFooterView)
        controller.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView))
    }
    
    func testFooterViewShouldBeCreated()
    {
        controller.registerFooterClass(NibHeaderFooterView)
        controller.memoryStorage.setSectionFooterModels([1])
        expect(self.controller.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beAKindOf(NibHeaderFooterView))
    }
    
    func testHeaderViewShouldBeCreatedFromXib()
    {
        controller.registerNibNamed("NibHeaderFooterView", forHeaderType: NibHeaderFooterView.self)
        controller.memoryStorage.setSectionHeaderModels([1])
        expect(self.controller.tableView(self.controller.tableView, viewForHeaderInSection: 0)).to(beAKindOf(NibHeaderFooterView))
    }
    
    func testFooterViewShouldBeCreatedFromXib()
    {
        controller.registerNibNamed("NibHeaderFooterView", forFooterType: NibHeaderFooterView.self)
        controller.memoryStorage.setSectionFooterModels([1])
        expect(self.controller.tableView(self.controller.tableView, viewForFooterInSection: 0)).to(beAKindOf(NibHeaderFooterView))
    }
    
    func testObjectForCellAtIndexPathGenericConversion()
    {
        controller.registerCellClass(NibCell)
        controller.memoryStorage.addItem(1, toSection: 0)
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        
        if let object = controller.objectForCell(cell as? NibCell, atIndexPath: indexPath(0, 0))
        {
            expect(object) == 1
        }
        else {
            XCTFail("")
        }
    }
    
    func testObjectAtIndexPathGenericConversionFailsForNil()
    {
        controller.registerCellClass(NibCell)
        controller.memoryStorage.addItem(1, toSection: 0)
        
        let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: indexPath(0, 0))
        
        if let object = controller.objectForCell(cell as? StringCell, atIndexPath: indexPath(0, 0))
        {
            XCTFail()
        }
    }
    
    func testHeaderObjectForViewGenericConversion()
    {
        controller.registerNibNamed("NibHeaderFooterView", forHeaderType: NibHeaderFooterView.self)
        controller.memoryStorage.setSectionHeaderModels([1])
        let header = controller.tableView(controller.tableView, viewForHeaderInSection: 0)
        if let object = controller.objectForHeader(header as? NibHeaderFooterView, atSectionIndex: 0)
        {
            
        }
        else {
            XCTFail()
        }
    }
    
    func testFooterObjectForViewGenericConversion()
    {
        controller.registerNibNamed("NibHeaderFooterView", forFooterType: NibHeaderFooterView.self)
        controller.memoryStorage.setSectionFooterModels([1])
        let header = controller.tableView(controller.tableView, viewForFooterInSection: 0)
        if let object = controller.objectForFooter(header as? NibHeaderFooterView, atSectionIndex: 0)
        {
            
        }
        else {
            XCTFail()
        }
    }
}
