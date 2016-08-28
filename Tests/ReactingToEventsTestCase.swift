//
//  ReactingToEventsTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
@testable import DTTableViewManager
import Nimble

class AlwaysVisibleTableView: UITableView
{
    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAt: indexPath)
    }
    
    
    override func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        return self.delegate?.tableView!(self, viewForHeaderInSection: section) as? UITableViewHeaderFooterView
    }
}

class ReactingTestTableViewController: DTTestTableViewController
{
    var indexPath : IndexPath?
    var model: Int?
    var text : String?
}

class ReactingToEventsTestCase: XCTestCase {

    var controller : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
    }
    
    func testCellSelectionClosure()
    {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        var reactingCell : SelectionReactingTableCell?
        controller.manager.didSelect(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testCellSelectionPerfomance() {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        self.controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) {
            self.controller.manager.didSelect(SelectionReactingTableCell.self) { (_, _, _) in
                self.stopMeasuring()
            }
            self.controller.manager.tableView(self.controller.tableView, didSelectRowAt: indexPath(1, 0))
        }
    }
    
    func testCellConfigurationClosure()
    {
        controller.manager.registerCellClass(SelectionReactingTableCell.self)
        
        var reactingCell : SelectionReactingTableCell?
        
        controller.manager.configureCell(SelectionReactingTableCell.self, { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        _ = controller.manager.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
    func testHeaderConfigurationClosure()
    {
        controller.manager.registerHeaderClass(ReactingHeaderFooterView.self)
        
        var reactingHeader : ReactingHeaderFooterView?
        
        controller.manager.configureHeader(ReactingHeaderFooterView.self) { (header, model, sectionIndex) in
            header.model = "Bar"
            header.sectionIndex = sectionIndex
        }
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        reactingHeader = controller.manager.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingHeader?.sectionIndex) == 0
        expect(reactingHeader?.model) == "Bar"
    }
    
    func testFooterConfigurationClosure()
    {
        controller.manager.registerFooterClass(ReactingHeaderFooterView.self)
        
        var reactingFooter : ReactingHeaderFooterView?
        
        controller.manager.configureFooter(ReactingHeaderFooterView.self) { (footer, model, sectionIndex) in
            footer.model = "Bar"
            footer.sectionIndex = sectionIndex
        }
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        reactingFooter = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingFooter?.sectionIndex) == 0
        expect(reactingFooter?.model) == "Bar"
    }
    
    func testShouldReactAfterContentUpdate()
    {
        controller.manager.registerCellClass(NibCell.self)
        
        expect(self.controller.afterContentUpdateValue) == false
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.afterContentUpdateValue) == true
    }
    
    func testShouldReactBeforeContentUpdate()
    {
        controller.manager.registerCellClass(NibCell.self)
        
        expect(self.controller.beforeContentUpdateValue) == false
        
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        expect(self.controller.beforeContentUpdateValue) == true
    }
    
    func testMovingTableViewItems() {
        controller.manager.memoryStorage.addItems([1,2,3])
        controller.manager.memoryStorage.addItems([4,5,6], toSection: 1)
        
        controller.manager.tableView(controller.tableView, moveRowAt: indexPath(0, 0), to: indexPath(3, 1))
        
        expect(self.controller.manager.memoryStorage.sectionAtIndex(0)?.itemsOfType(Int.self)) == [2,3]
        expect(self.controller.manager.memoryStorage.sectionAtIndex(1)?.itemsOfType(Int.self)) == [4,5,6,1]
    }
}

class ReactingToEventsFastTestCase : XCTestCase {
    var controller : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.startManagingWithDelegate(controller)
        controller.manager.storage = MemoryStorage()
        controller.manager.registerFooterClass(ReactingHeaderFooterView.self)
        controller.manager.registerCellClass(NibCell.self)
    }
    
    func testFooterConfigurationClosure()
    {
        let exp = expectation(description: "Configure footer")
        controller.manager.configureFooter(ReactingHeaderFooterView.self) { _ in
            exp.fulfill()
        }
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = controller.manager.tableView(controller.tableView, viewForFooterInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "heightForRowAtIndexPath")
        controller.manager.heightForCell(withItemType: Int.self, closure: { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, heightForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEstimatedHeightForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "estimatedHeightForRowAtIndexPath")
        controller.manager.estimatedHeightForCell(withItemType: Int.self, closure: { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, estimatedHeightForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testIndentationLevelForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "indentationLevelForRowAtIndexPath")
        controller.manager.indentationLevel(forItemType: Int.self, closure: { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, indentationLevelForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillSelectRowAtIndexPathClosure() {
        let exp = expectation(description: "willSelect")
        controller.manager.willSelect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, willSelectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDeselectRowAtIndexPathClosure() {
        let exp = expectation(description: "willDeselect")
        controller.manager.willDeselect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, willDeselectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidDeselectRowAtIndexPathClosure() {
        let exp = expectation(description: "didDeselect")
        controller.manager.didDeselect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, didDeselectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayRowAtIndexPathClosure() {
        let exp = expectation(description: "willDisplay")
        controller.manager.willDisplay(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, willDisplay: NibCell(), forRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testEditActionsForRowAtIndexPathClosure() {
        let exp = expectation(description: "editActions")
        controller.manager.editActions(for: NibCell.self, { (cell, model, indexPath) -> [UITableViewRowAction]? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, editActionsForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testAccessoryButtonTappedForRowAtIndexPathClosure() {
        let exp = expectation(description: "accessoryButtonTapped")
        controller.manager.accessoryButtonTapped(in: NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, accessoryButtonTappedForRowWith: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCommitEditingStyleForRowAtIndexPathClosure() {
        let exp = expectation(description: "commitEditingStyle")
        controller.manager.commitEditingStyle(for: NibCell.self, { style, cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, commit: .delete, forRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanEditRowAtIndexPathClosure() {
        let exp = expectation(description: "canEditRow")
        controller.manager.canEdit(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return false
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, canEditRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanMoveRowAtIndexPathClosure() {
        let exp = expectation(description: "canMoveRow")
        controller.manager.canMove(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return false
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, canMoveRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForHeaderInSection() {
        let exp = expectation(description: "heightForHeader")
        controller.manager.heightForHeader(withItemType: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEstimatedHeightForHeaderInSection() {
        let exp = expectation(description: "estimatedHeightForHeader")
        controller.manager.estimatedHeightForHeader(withItemType: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForFooterInSection() {
        let exp = expectation(description: "heightForHeader")
        controller.manager.heightForFooter(withItemType: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEstimatedHeightForFooterInSection() {
        let exp = expectation(description: "estimatedHeightForFooter")
        controller.manager.estimatedHeightForFooter(withItemType: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayHeaderInSection() {
        let exp = expectation(description: "willDisplayHeaderInSection")
        controller.manager.willDisplayHeaderView(ReactingHeaderFooterView.self, { header, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        _ = controller.manager.tableView(controller.tableView, willDisplayHeaderView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayFooterInSection() {
        let exp = expectation(description: "willDisplayFooterInSection")
        controller.manager.willDisplayFooterView(ReactingHeaderFooterView.self, { footer, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = controller.manager.tableView(controller.tableView, willDisplayFooterView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testWillBeginEditingRowAtIndexPathClosure() {
        let exp = expectation(description: "willBeginEditing")
        controller.manager.willBeginEditing(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, willBeginEditingRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndEditingRowAtIndexPathClosure() {
        let exp = expectation(description: "didEndEditing")
        controller.manager.didEndEditing(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, didEndEditingRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testEditingStyleForRowAtIndexPath() {
        let exp = expectation(description: "editingStyle")
        controller.manager.editingStyle(for: NibCell.self, { (cell, model, indexPath) -> UITableViewCellEditingStyle in
            exp.fulfill()
            return .none
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, editingStyleForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testTitleForDeleteButtonForRowAtIndexPath() {
        let exp = expectation(description: "titleForDeleteButton")
        controller.manager.titleForDeleteConfirmationButton(in: NibCell.self, { (cell, model, indexPath) -> String? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, titleForDeleteConfirmationButtonForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testShouldIndentRowWhileEditingAtIndexPath() {
        let exp = expectation(description: "shouldIndent")
        controller.manager.shouldIndentWhileEditing(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, shouldIndentWhileEditingRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingRowAtIndexPathClosure() {
        let exp = expectation(description: "didEndDispaying")
        controller.manager.didEndDisplaying(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, didEndDisplaying:NibCell(), forRowAt : indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingHeaderInSection() {
        let exp = expectation(description: "didEndDisplayingHeaderInSection")
        controller.manager.didEndDisplayingHeaderView(ReactingHeaderFooterView.self, { header, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        _ = controller.manager.tableView(controller.tableView, didEndDisplayingHeaderView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingFooterInSection() {
        let exp = expectation(description: "didEndDisplayingFooterInSection")
        controller.manager.didEndDisplayingFooterView(ReactingHeaderFooterView.self, { footer, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = controller.manager.tableView(controller.tableView, didEndDisplayingFooterView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldMenuForRowAtIndexPath() {
        let exp = expectation(description: "shouldShowMenu")
        controller.manager.shouldShowMenu(for: NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, shouldShowMenuForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "canPerformActionForRowAtIndexPath")
        controller.manager.canPerformAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, canPerformAction: #selector(testDidEndDisplayingFooterInSection), forRowAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "performActionForRowAtIndexPath")
        controller.manager.performAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, performAction: #selector(testDidEndDisplayingFooterInSection), forRowAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldHighlightRowAtIndexPath() {
        let exp = expectation(description: "shouldHighlight")
        controller.manager.shouldHighlight(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, shouldHighlightRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidHighlightRowAtIndexPath() {
        let exp = expectation(description: "didHighlight")
        controller.manager.didHighlight(NibCell.self, { (cell, model, indexPath) in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, didHighlightRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidUnhighlightRowAtIndexPath() {
        let exp = expectation(description: "didUnhighlight")
        controller.manager.didUnhighlight(NibCell.self, { (cell, model, indexPath) in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, didUnhighlightRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    func testCanFocusRowAtIndexPath() {
        let exp = expectation(description: "canFocus")
        controller.manager.canFocus(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableView(controller.tableView, canFocusRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAllDelegateMethodSignatures() {
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)))) == EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:canEditRowAt:)))) == EventMethodSignature.canEditRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:)))) == EventMethodSignature.canMoveRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:heightForRowAt:)))) == EventMethodSignature.heightForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)))) == EventMethodSignature.estimatedHeightForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)))) == EventMethodSignature.indentationLevelForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)))) == EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue
        
        #if os(iOS)
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)))) == EventMethodSignature.editActionsForRowAtIndexPath.rawValue
        #endif
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)))) == EventMethodSignature.accessoryButtonTappedForRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willSelectRowAt:)))) == EventMethodSignature.willSelectRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:)))) == EventMethodSignature.didSelectRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)))) == EventMethodSignature.willDeselectRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)))) == EventMethodSignature.didDeselectRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)))) == EventMethodSignature.heightForHeaderInSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)))) == EventMethodSignature.estimatedHeightForHeaderInSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)))) == EventMethodSignature.heightForFooterInSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)))) == EventMethodSignature.estimatedHeightForFooterInSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)))) == EventMethodSignature.willDisplayHeaderForSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)))) == EventMethodSignature.willDisplayFooterForSection.rawValue
        
        #if os(iOS)
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)))) == EventMethodSignature.willBeginEditingRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)))) == EventMethodSignature.didEndEditingRowAtIndexPath.rawValue
        #endif
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)))) == EventMethodSignature.editingStyleForRowAtIndexPath.rawValue
        #if os(iOS)
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)))) == EventMethodSignature.titleForDeleteButtonForRowAtIndexPath.rawValue
        #endif
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)))) == EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)))) == EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)))) == EventMethodSignature.didEndDisplayingHeaderViewForSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)))) == EventMethodSignature.didEndDisplayingFooterViewForSection.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)))) == EventMethodSignature.shouldShowMenuForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)))) == EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)))) == EventMethodSignature.performActionForRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)))) == EventMethodSignature.shouldHighlightRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)))) == EventMethodSignature.didHighlightRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)))) == EventMethodSignature.didUnhighlightRowAtIndexPath.rawValue
        if #available(iOS 9.0, tvOS 9.0, *) {
            expect(String(describing: #selector(UITableViewDelegate.tableView(_:canFocusRowAt:)))) == EventMethodSignature.canFocusRowAtIndexPath.rawValue
        }
    }
}

