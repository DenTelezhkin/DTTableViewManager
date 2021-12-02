//
//  ReactingToEventsTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
@testable import DTTableViewManager

#if os(iOS)
    
class SpringLoadedContextMock : NSObject, UISpringLoadedInteractionContext {
    var state: UISpringLoadedInteractionEffectState = .activated
    
    var targetView: UIView?
    var targetItem: Any?
    func location(in view: UIView?) -> CGPoint {
        return .zero
    }
}
    
class DragAndDropMock : NSObject, UIDragSession, UIDropSession {
    var progress: Progress = Progress()
    
    var localDragSession: UIDragSession?
    
    var progressIndicatorStyle: UIDropSessionProgressIndicatorStyle = .default
    
    func canLoadObjects(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        return false
    }
    
    func loadObjects(ofClass aClass: NSItemProviderReading.Type, completion: @escaping ([NSItemProviderReading]) -> Void) -> Progress {
        return Progress()
    }
    
    var items: [UIDragItem] = []
    
    func location(in view: UIView) -> CGPoint {
        return CGPoint()
    }
    
    var allowsMoveOperation: Bool = true
    
    var isRestrictedToDraggingApplication: Bool = false
    
    func hasItemsConforming(toTypeIdentifiers typeIdentifiers: [String]) -> Bool {
        return false
    }
    
    var localContext: Any?
}
    
class DropPlaceholderContextMock : NSObject, UITableViewDropPlaceholderContext {
    var dragItem: UIDragItem = UIDragItem(itemProvider: NSItemProvider(contentsOf: URL(fileURLWithPath: ""))!)
    func commitInsertion(dataSourceUpdates: (IndexPath) -> Void) -> Bool {
        return true
    }
    
    func deletePlaceholder() -> Bool {
        return true
    }
    
    func addAnimations(_ animations: @escaping () -> Void) {
        
    }
    
    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        
    }
}
    
class DropCoordinatorMock: NSObject, UITableViewDropCoordinator {
    var items: [UITableViewDropItem] = []
    
    var destinationIndexPath: IndexPath?
    
    var proposal: UITableViewDropProposal = .init(operation: .copy, intent: .automatic)
    
    var session: UIDropSession = DragAndDropMock()
    
    override init() {
        super.init()
    }
    
    func drop(_ dragItem: UIDragItem, to placeholder: UITableViewDropPlaceholder) -> UITableViewDropPlaceholderContext {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, toRowAt indexPath: IndexPath) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, intoRowAt indexPath: IndexPath, rect: CGRect) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, to target: UIDragPreviewTarget) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
        
    
}

@available(iOS 13, *)
class ContextMenuInteractionAnimatorMock: NSObject, UIContextMenuInteractionCommitAnimating {
    var preferredCommitStyle: UIContextMenuInteractionCommitStyle = .pop
    
    var previewViewController: UIViewController?
    
    func addAnimations(_ animations: @escaping () -> Void) {
        
    }
    
    func addCompletion(_ completion: @escaping () -> Void) {
        
    }
    
    
}
    
#endif

class AlwaysVisibleTableView: UITableView
{
    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAt: indexPath)
    }
    
    
    override func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        return self.delegate?.tableView?(self, viewForHeaderInSection: section) as? UITableViewHeaderFooterView
    }
}

class ReactingTestTableViewController: DTTestTableViewController
{
    var indexPath : IndexPath?
    var model: Int?
    var text : String?
}

fileprivate class FirstTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

fileprivate class SecondTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class ReactingToEventsTestCase: XCTestCase {

    var controller : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
    }
    
    func testCellSelectionClosure()
    {
        controller.manager.register(SelectionReactingTableCell.self)
        var reactingCell : SelectionReactingTableCell?
        controller.manager.didSelect(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableDelegate?.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        XCTAssertEqual(reactingCell?.indexPath, indexPath(1, 0))
        XCTAssertEqual(reactingCell?.model, 2)
    }
    
    func testCellSelectionPerfomance() {
        if #available(tvOS 11, *) {
            controller.tableView = UITableView()
        }
        controller.manager.register(SelectionReactingTableCell.self)
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            controller.manager.didSelect(SelectionReactingTableCell.self) { (_, _, _) in
                self.stopMeasuring()
            }
            controller.manager.tableDelegate?.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        }
    }
    
    func testCellConfigurationClosure()
    {
        var reactingCell : SelectionReactingTableCell?
        controller.manager.register(SelectionReactingTableCell.self, handler: { cell, model, indexPath in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        
        XCTAssertEqual(reactingCell?.indexPath, indexPath(0, 0))
        XCTAssertEqual(reactingCell?.model, 2)
        XCTAssertEqual(reactingCell?.textLabel?.text, "Foo")
    }
    
    func testHeaderConfigurationClosure()
    {
        controller.manager.registerHeader(ReactingHeaderFooterView.self, handler: { view, model, sectionIndex in
            view.sectionIndex = sectionIndex
        })
        
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        let reactingHeader : ReactingHeaderFooterView? = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
        XCTAssertEqual(reactingHeader?.sectionIndex, 0)
    }
    
    func testFooterConfigurationClosure()
    {
        controller.manager.registerFooter(ReactingHeaderFooterView.self, handler: { view, model, sectionIndex in
            view.sectionIndex = sectionIndex
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        let reactingFooter : ReactingHeaderFooterView? = controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
        
        XCTAssertEqual(reactingFooter?.sectionIndex, 0)
    }
    
    func testShouldReactAfterContentUpdate()
    {
        controller.manager.register(NibCell.self)
        let exp = expectation(description: "didUpdateContent")
        controller.manager.tableViewUpdater?.didUpdateContent = { _ in
            exp.fulfill()
        }
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldReactBeforeContentUpdate()
    {
        controller.manager.register(NibCell.self)
        let exp = expectation(description: "willUpdateContent")
        controller.manager.tableViewUpdater?.willUpdateContent = { _ in
            exp.fulfill()
        }
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

class ReactingToEventsFastTestCase : XCTestCase {
    var sut : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        sut = ReactingTestTableViewController()
        sut.tableView = AlwaysVisibleTableView()
        let _ = sut.view
        sut.manager.registerFooter(ReactingHeaderFooterView.self)
        sut.manager.register(NibCell.self)
    }
    
    func unregisterAll() {
        sut.manager.viewFactory.mappings.removeAll()
    }
    
    func fullfill<Cell,Model,ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (Cell,Model,IndexPath) -> ReturnValue {
        { cell, model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<View,Model,ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (View,Model,Int) -> ReturnValue {
        { cell, model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<Cell,Model,Argument,ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (Argument,Cell,Model,IndexPath) -> ReturnValue {
        { argument,cell, model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<Cell,Model,ArgumentOne,ArgumentTwo,ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (ArgumentOne,ArgumentTwo,Cell,Model,IndexPath) -> ReturnValue {
        { argumentOne, argumentTwo, cell, model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<Model, ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (Model,IndexPath) -> ReturnValue {
        { model, indexPath in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func fullfill<Model, ReturnValue>(_ expectation: XCTestExpectation, andReturn returnValue: ReturnValue) -> (Model,Int) -> ReturnValue {
        { model, section in
            expectation.fulfill()
            return returnValue
        }
    }
    
    func addIntItem(_ item: Int = 3) -> (ReactingTestTableViewController) -> Void {
        {
            $0.manager.memoryStorage.addItem(item)
        }
    }
    
    func setHeaderIntModels(_ models: [Int] = [5]) -> (ReactingTestTableViewController) -> Void {
        {
            $0.manager.memoryStorage.setSectionHeaderModels(models)
        }
    }
    
    func setHeaderStringModels(_ models: [String] = ["Foo"]) -> (ReactingTestTableViewController) -> Void {
        {
            $0.manager.memoryStorage.setSectionHeaderModels(models)
        }
    }
    
    func setFooterIntModels(_ models: [Int] = [5]) -> (ReactingTestTableViewController) -> Void {
        {
            $0.manager.memoryStorage.setSectionFooterModels(models)
        }
    }
    
    func setFooterStringModels(_ models: [String] = ["Foo"]) -> (ReactingTestTableViewController) -> Void {
        {
            $0.manager.memoryStorage.setSectionFooterModels(models)
        }
    }
    
    func verifyEvent<U: Equatable>(_ signature: EventMethodSignature,
                                                   registration: (ReactingTestTableViewController, XCTestExpectation) -> Void,
                                                   alternativeRegistration: (ReactingTestTableViewController, XCTestExpectation) -> Void,
                                                   preparation: (ReactingTestTableViewController) -> Void,
                                                   action: (ReactingTestTableViewController) throws -> U,
                                                   expectedResult: U? = nil) throws {
        guard let sut = sut else {
            XCTFail()
            return
        }
        unregisterAll()
        
        let exp = expectation(description: signature.rawValue)
        registration(sut,exp)
        preparation(sut)
        let result = try action(sut)
        if let expectedResult = expectedResult {
            XCTAssertEqual(result, expectedResult)
        }
        waitForExpectations(timeout: 1)
        
        unregisterAll()
        
        let altExp = expectation(description: signature.rawValue)
        alternativeRegistration(sut,altExp)
        preparation(sut)
        let altResult = try action(sut)
        if let expectedResult = expectedResult {
            XCTAssertEqual(altResult, expectedResult)
        }
        waitForExpectations(timeout: 1)
    }
    
    func verifyEvent<U>(_ signature: EventMethodSignature,
                                                   registration: (ReactingTestTableViewController, XCTestExpectation) -> Void,
                                                   alternativeRegistration: (ReactingTestTableViewController, XCTestExpectation) -> Void,
                                                   preparation: (ReactingTestTableViewController) -> Void,
                                                   action: (ReactingTestTableViewController) throws -> U) throws {
        guard let sut = sut else {
            XCTFail()
            return
        }
        unregisterAll()
        
        let exp = expectation(description: signature.rawValue)
        registration(sut,exp)
        preparation(sut)
        _ = try action(sut)
        waitForExpectations(timeout: 1)
        
        unregisterAll()
        
        let altExp = expectation(description: signature.rawValue)
        alternativeRegistration(sut,altExp)
        preparation(sut)
        _ = try action(sut)
        waitForExpectations(timeout: 1)
    }
    
    func testFooterConfigurationClosure()
    {
        sut.manager.unregisterFooter(ReactingHeaderFooterView.self)
        let exp = expectation(description: "Configure footer")
        sut.manager.registerFooter(ReactingHeaderFooterView.self, handler: { view, model, sectionIndex in
            exp.fulfill()
        })
        sut.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = sut.manager.tableDelegate?.tableView(sut.tableView, viewForFooterInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForRowAtIndexPathClosure() throws
    {
        try verifyEvent(.heightForRowAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self)
            sut.manager.heightForCell(withItem: Int.self, self.fullfill(exp, andReturn: 42))
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self) { $0.heightForCell(self.fullfill(exp, andReturn: 42))}
        }, preparation: addIntItem(), action: {
           try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, heightForRowAt: indexPath(0, 0)))
        }, expectedResult: 42)
    }
    
    func testEstimatedHeightForRowAtIndexPathClosure() throws
    {
        try verifyEvent(.estimatedHeightForRowAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self)
            sut.manager.estimatedHeightForCell(withItem: Int.self, self.fullfill(exp, andReturn: 42))
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self) { $0.estimatedHeightForCell(self.fullfill(exp, andReturn: 42))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, estimatedHeightForRowAt: indexPath(0, 0)))
        }, expectedResult: 42)
    }
    
    func testIndentationLevelForRowAtIndexPathClosure() throws
    {
        try verifyEvent(.indentationLevelForRowAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self)
            sut.manager.indentationLevelForCell(withItem: Int.self, self.fullfill(exp, andReturn: 3))
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self) { $0.indentationLevelForCell(self.fullfill(exp, andReturn: 3))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, indentationLevelForRowAt: indexPath(0, 0)))
        }, expectedResult: 3)
    }
    
    func testWillSelectRowAtIndexPathClosure() throws {
        try verifyEvent(.willSelectRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.willSelect(NibCell.self, self.fullfill(exp, andReturn: indexPath(10, 10)))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.willSelect(self.fullfill(exp, andReturn: indexPath(10, 10)))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, willSelectRowAt: indexPath(0,0)))
        }, expectedResult: indexPath(10, 10))
    }
    
    func testWillDeselectRowAtIndexPathClosure() throws {
        try verifyEvent(.willDeselectRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.willDeselect(NibCell.self, self.fullfill(exp, andReturn: indexPath(5, 5)))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.willDeselect(self.fullfill(exp, andReturn: indexPath(5, 5)))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, willDeselectRowAt: indexPath(0,0)))
        }, expectedResult: indexPath(5, 5))
    }
    
    func testDidSelectRowAtIndexPathClosure() throws {
        try verifyEvent(.didSelectRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didSelect(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didSelect(self.fullfill(exp, andReturn: ()))}
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, didSelectRowAt: indexPath(0, 0))
        })
    }
    
    func testDidDeselectRowAtIndexPathClosure() throws {
        try verifyEvent(.didDeselectRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didDeselect(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didDeselect(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, didDeselectRowAt: indexPath(0,0))
        })
    }
    
    func testWillDisplayRowAtIndexPathClosure() throws {
        try verifyEvent(.willDisplayCellForRowAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self)
            sut.manager.willDisplay(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self) { $0.willDisplay(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, willDisplay: NibCell(), forRowAt: indexPath(0,0))
        })
    }
    
    #if os(iOS)
    func testEditActionsForRowAtIndexPathClosure() {
        let exp = expectation(description: "editActions")
        sut.manager.editActions(for: NibCell.self, { (cell, model, indexPath) -> [UITableViewRowAction]? in
            exp.fulfill()
            return nil
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.tableDelegate?.tableView(sut.tableView, editActionsForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testAccessoryButtonTappedForRowAtIndexPathClosure() throws {
        try verifyEvent(.accessoryButtonTappedForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.accessoryButtonTapped(in: NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.accessoryButtonTapped(self.fullfill(exp, andReturn: ()))}
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, accessoryButtonTappedForRowWith: indexPath(0,0))
        })
    }
    
    func testCommitEditingStyleForRowAtIndexPathClosure() throws {
        try verifyEvent(.commitEditingStyleForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.commitEditingStyle(for: NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.commitEditingStyle(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDataSource?.tableView(sut.tableView, commit: .delete, forRowAt: indexPath(0,0))
        })
    }
    
    func testCanEditRowAtIndexPathClosure() throws {
        try verifyEvent(.canEditRowAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self)
            sut.manager.canEditCell(withItem: Int.self, self.fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self) { $0.canEditCell(self.fullfill(exp, andReturn: true))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDataSource?.tableView(sut.tableView, canEditRowAt: indexPath(0,0)))
        }, expectedResult: true)
    }
    
    func testCanMoveRowAtIndexPathClosure() throws {
        try verifyEvent(.canMoveRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.canMove(NibCell.self, fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.canMove(self.fullfill(exp, andReturn: true)) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDataSource?.tableView(sut.tableView, canMoveRowAt: indexPath(0,0)))
        }, expectedResult: true)
    }
    
    func testHeightForHeaderInSection() throws {
        try verifyEvent(.heightForHeaderInSection, registration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self)
            sut.manager.heightForHeader(withItem: Int.self, self.fullfill(exp, andReturn: 42))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self) { $0.heightForHeader(self.fullfill(exp, andReturn: 42)) }
        }, preparation: setHeaderIntModels(), action: { sut in
            try XCTUnwrap(sut.manager.tableDelegate?.tableView(sut.tableView, heightForHeaderInSection: 0))
        }, expectedResult: CGFloat(42))
    }
    
    func testEstimatedHeightForHeaderInSection() throws {
        try verifyEvent(.estimatedHeightForHeaderInSection, registration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self)
            sut.manager.estimatedHeightForHeader(withItem: Int.self, self.fullfill(exp, andReturn: 42))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(NibHeaderFooterView.self) { $0.estimatedHeightForHeader(self.fullfill(exp, andReturn: 42)) }
        }, preparation: setHeaderIntModels(), action: { sut in
            try XCTUnwrap(sut.manager.tableDelegate?.tableView(sut.tableView, estimatedHeightForHeaderInSection: 0))
        }, expectedResult: CGFloat(42))
    }
    
    func testHeightForFooterInSection() throws {
        try verifyEvent(.heightForFooterInSection, registration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self)
            sut.manager.heightForFooter(withItem: Int.self, self.fullfill(exp, andReturn: 42))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self) { $0.heightForFooter(self.fullfill(exp, andReturn: 42)) }
        }, preparation: setFooterIntModels(), action: { sut in
            try XCTUnwrap(sut.manager.tableDelegate?.tableView(sut.tableView, heightForFooterInSection: 0))
        }, expectedResult: CGFloat(42))
    }
    
    func testEstimatedHeightForFooterInSection() throws {
        try verifyEvent(.estimatedHeightForFooterInSection, registration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self)
            sut.manager.estimatedHeightForFooter(withItem: Int.self, self.fullfill(exp, andReturn: 42))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerFooter(NibHeaderFooterView.self) { $0.estimatedHeightForFooter(self.fullfill(exp, andReturn: 42)) }
        }, preparation: setFooterIntModels(), action: { sut in
            try XCTUnwrap(sut.manager.tableDelegate?.tableView(sut.tableView, estimatedHeightForFooterInSection: 0))
        }, expectedResult: CGFloat(42))
    }
    
    func testWillDisplayHeaderInSection() throws {
        try verifyEvent(.willDisplayHeaderForSection, registration: { (sut, exp) in
            sut.manager.registerHeader(ReactingHeaderFooterView.self)
            sut.manager.willDisplayHeaderView(ReactingHeaderFooterView.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(ReactingHeaderFooterView.self) { $0.willDisplayHeaderView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setHeaderStringModels(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, willDisplayHeaderView: ReactingHeaderFooterView(), forSection: 0)
        })
    }
    
    func testWillDisplayFooterInSection() throws {
        try verifyEvent(.willDisplayFooterForSection, registration: { (sut, exp) in
            sut.manager.registerFooter(ReactingHeaderFooterView.self)
            sut.manager.willDisplayFooterView(ReactingHeaderFooterView.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerFooter(ReactingHeaderFooterView.self) { $0.willDisplayFooterView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setFooterStringModels(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, willDisplayFooterView: ReactingHeaderFooterView(), forSection: 0)
        })
    }
    
    #if os(iOS)
    func testWillBeginEditingRowAtIndexPathClosure() throws {
        try verifyEvent(.willBeginEditingRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.willBeginEditing(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.willBeginEditing(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, willBeginEditingRowAt: indexPath(0,0))
        })
    }
    
    func testDidEndEditingRowAtIndexPathClosure() throws {
        try verifyEvent(.didEndEditingRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didEndEditing(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didEndEditing(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, didEndEditingRowAt: indexPath(0,0))
        })
    }
    #endif
    
    func testEditingStyleForRowAtIndexPath() throws {
        try verifyEvent(.editingStyleForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.editingStyle(forItem: Int.self, self.fullfill(exp, andReturn: .insert))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.editingStyle(self.fullfill(exp, andReturn: .insert))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, editingStyleForRowAt: indexPath(0,0)))
        }, expectedResult: .insert)
    }
    
    #if os(iOS)
    func testTitleForDeleteButtonForRowAtIndexPath() throws {
        try verifyEvent(.titleForDeleteButtonForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.titleForDeleteConfirmationButton(in: NibCell.self, self.fullfill(exp, andReturn: "Title"))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.titleForDeleteConfirmationButton(self.fullfill(exp, andReturn: "Title"))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, titleForDeleteConfirmationButtonForRowAt: indexPath(0,0)))
        }, expectedResult: "Title")
    }
    #endif
    
    func testShouldIndentRowWhileEditingAtIndexPath() throws {
        try verifyEvent(.shouldIndentWhileEditingRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldIndentWhileEditing(NibCell.self, self.fullfill(exp, andReturn: false))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldIndentWhileEditing(self.fullfill(exp, andReturn: false)) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, shouldIndentWhileEditingRowAt: indexPath(0,0)))
        }, expectedResult: false)
    }
    
    func testDidEndDisplayingRowAtIndexPathClosure() throws {
        try verifyEvent(.didEndDisplayingCellForRowAtIndexPath, registration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self)
            sut.manager.didEndDisplaying(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            exp.assertForOverFulfill = false
            sut.manager.register(NibCell.self) { $0.didEndDisplaying(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, didEndDisplaying: NibCell(), forRowAt: indexPath(0,0))
        })
    }
    
    func testDidEndDisplayingHeaderInSection() throws {
        try verifyEvent(.didEndDisplayingHeaderViewForSection, registration: { (sut, exp) in
            sut.manager.registerHeader(ReactingHeaderFooterView.self)
            sut.manager.didEndDisplayingHeaderView(ReactingHeaderFooterView.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerHeader(ReactingHeaderFooterView.self) { $0.didEndDisplayingHeaderView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setHeaderStringModels(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, didEndDisplayingHeaderView: ReactingHeaderFooterView(), forSection: 0)
        })
    }
    
    func testDidEndDisplayingFooterInSection() throws {
        try verifyEvent(.didEndDisplayingFooterViewForSection, registration: { (sut, exp) in
            sut.manager.registerFooter(ReactingHeaderFooterView.self)
            sut.manager.didEndDisplayingFooterView(ReactingHeaderFooterView.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.registerFooter(ReactingHeaderFooterView.self) { $0.didEndDisplayingFooterView(self.fullfill(exp, andReturn: ())) }
        }, preparation: setFooterStringModels(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, didEndDisplayingFooterView: ReactingHeaderFooterView(), forSection: 0)
        })
    }
    
    func testShouldMenuForRowAtIndexPath() {
        let exp = expectation(description: "shouldShowMenu")
        sut.manager.shouldShowMenu(for: NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.tableDelegate?.tableView(sut.tableView, shouldShowMenuForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "canPerformActionForRowAtIndexPath")
        sut.manager.canPerformAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.tableDelegate?.tableView(sut.tableView, canPerformAction: #selector(testDidEndDisplayingFooterInSection), forRowAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "performActionForRowAtIndexPath")
        sut.manager.performAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) in
            exp.fulfill()
            return
        })
        sut.manager.memoryStorage.addItem(3)
        _ = sut.manager.tableDelegate?.tableView(sut.tableView, performAction: #selector(testDidEndDisplayingFooterInSection), forRowAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldHighlightRowAtIndexPath() throws {
        try verifyEvent(.shouldHighlightRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldHighlight(NibCell.self, self.fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldHighlight(self.fullfill(exp, andReturn: true)) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, shouldHighlightRowAt: indexPath(0,0)))
        }, expectedResult: true)
    }
    
    func testDidHighlightRowAtIndexPath() throws {
        try verifyEvent(.didHighlightRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didHighlight(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didHighlight(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, didHighlightRowAt: indexPath(0,0)))
        })
    }
    
    func testDidUnhighlightRowAtIndexPath() throws {
        try verifyEvent(.didUnhighlightRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didUnhighlight(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didUnhighlight(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, didUnhighlightRowAt: indexPath(0,0)))
        })
    }
    
    @available(tvOS 9.0, *)
    func testCanFocusRowAtIndexPath() throws {
        try verifyEvent(.canFocusRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.canFocus(NibCell.self, self.fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.canFocus(self.fullfill(exp, andReturn: true)) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, canFocusRowAt: indexPath(0,0)))
        }, expectedResult: true)
    }
    #if os(iOS)
    func testSectionIndexTitlesFor() {
        let exp = expectation(description: "sectionIndexTitles")
        sut.manager.sectionIndexTitles {
            exp.fulfill()
            return ["1","2"]
        }
        XCTAssertEqual(["1","2"], sut.manager.tableDataSource?.sectionIndexTitles(for: sut.tableView))
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testSectionForSectionIndexTitleAt() {
        let exp = expectation(description: "sectionForSectionIndexTitle")
        sut.manager.sectionForSectionIndexTitle { title, index -> Int in
            exp.fulfill()
            return 5
        }
        XCTAssertEqual(sut.manager.tableDataSource?.tableView(sut.tableView, sectionForSectionIndexTitle: "2", at: 3), 5)
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    #endif
    
    func testMoveRowAtIndexPath() throws {
        try verifyEvent(.moveRowAtIndexPathToIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.move(NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.moveRowTo(self.fullfill(exp, andReturn: ()))}
        }, preparation: { sut in
            sut.manager.memoryStorage.addItems([3,4])
        }, action: {
            $0.manager.tableDataSource?.tableView(sut.tableView, moveRowAt: indexPath(0,0), to: indexPath(1, 0))
        })
    }
    
    #if os(iOS)
    func testItemsForBeginningInDragSession() throws {
        try verifyEvent(.itemsForBeginningDragSession, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.itemsForBeginningDragSession(from: NibCell.self, fullfill(exp, andReturn: []))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.itemsForBeginningDragSession(self.fullfill(exp, andReturn: [])) }
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDragDelegate?.tableView(sut.tableView, itemsForBeginning: DragAndDropMock(), at: indexPath(0, 0)))
        }, expectedResult: [])
    }
    
    func testItemsForAddingToDragSession() throws {
        try verifyEvent(.itemsForAddingToDragSession, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.itemsForAddingToDragSession(from: NibCell.self, fullfill(exp, andReturn: []))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.itemsForAddingToDragSession(self.fullfill(exp, andReturn: []))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDragDelegate?.tableView(sut.tableView, itemsForAddingTo: DragAndDropMock(), at: indexPath(0,0), point: .zero))
        }, expectedResult: [])
    }
    
    func testDragPreviewParametersForRowAtIndexPath() throws {
        try verifyEvent(.dragPreviewParametersForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.dragPreviewParameters(for: NibCell.self, fullfill(exp, andReturn: nil))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.dragPreviewParameters(self.fullfill(exp, andReturn: nil)) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDragDelegate?.tableView(sut.tableView, dragPreviewParametersForRowAt: indexPath(0, 0))
        }, expectedResult: nil)
    }
    
    func testDragSessionWillBegin() {
        let exp = expectation(description: "dragSessionWillBegin")
        sut.manager.dragSessionWillBegin { _ in
            exp.fulfill()
        }
        _ = sut.manager.tableDragDelegate?.tableView(sut.tableView, dragSessionWillBegin: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionDidEnd() {
        let exp = expectation(description: "dragSessionDidEnd")
        sut.manager.dragSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = sut.manager.tableDragDelegate?.tableView(sut.tableView, dragSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionAllowsMoveOperation() {
        let exp = expectation(description: "dragSessionAllowsMoveOperation")
        sut.manager.dragSessionAllowsMoveOperation{ _  in
            exp.fulfill()
            return true
        }
        _ = sut.manager.tableDragDelegate?.tableView(sut.tableView, dragSessionAllowsMoveOperation: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionIsRestrictedToDraggingApplication() {
        let exp = expectation(description: "dragSessionRestrictedToDraggingApplication")
        sut.manager.dragSessionIsRestrictedToDraggingApplication{ _  in
            exp.fulfill()
            return true
        }
        _ = sut.manager.tableDragDelegate?.tableView(sut.tableView, dragSessionIsRestrictedToDraggingApplication: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    /// MARK: - UITableViewDropDelegate
    
    func testPerformDropWithCoordinator() {
        let exp = expectation(description: "performDropWithCoordinator")
        sut.manager.performDropWithCoordinator { _ in
            exp.fulfill()
        }
        _ = sut.manager.tableDropDelegate?.tableView(sut.tableView, performDropWith: DropCoordinatorMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanHandleDropSession() {
        let exp = expectation(description: "canHandleDropSession")
        sut.manager.canHandleDropSession { _ in
            exp.fulfill()
            return true
        }
        _ = sut.manager.tableDropDelegate?.tableView(sut.tableView, canHandle: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnter() {
        let exp = expectation(description: "dropSessionDidEnter")
        sut.manager.dropSessionDidEnter { _ in
            exp.fulfill()
        }
        _ = sut.manager.tableDropDelegate?.tableView(sut.tableView, dropSessionDidEnter: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidUpdate() {
        let exp = expectation(description: "dropSessionDidUpdate")
        sut.manager.dropSessionDidUpdate { _, _ in
            exp.fulfill()
            return UITableViewDropProposal(operation: .cancel)
        }
        _ = sut.manager.tableDropDelegate?.tableView(sut.tableView, dropSessionDidUpdate: DragAndDropMock(), withDestinationIndexPath: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidExit() {
        let exp = expectation(description: "dropSessionDidExit")
        sut.manager.dropSessionDidExit { _ in
            exp.fulfill()
        }
        _ = sut.manager.tableDropDelegate?.tableView(sut.tableView, dropSessionDidExit: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnd() {
        let exp = expectation(description: "dropSessionDidEnd")
        sut.manager.dropSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = sut.manager.tableDropDelegate?.tableView(sut.tableView, dropSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropPreviewParametersForRowAtIndexPath() {
        let exp = expectation(description: "dropPreviewParametersForRowAtIndexPath")
        sut.manager.dropPreviewParameters { _ in
            exp.fulfill()
            return nil
        }
        XCTAssertNil(sut.manager.tableDropDelegate?.tableView(sut.tableView, dropPreviewParametersForRowAt: indexPath(0, 0)))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLeadingSwipeActionsConfiguration() throws {
        var swipeActionConfiguration: UISwipeActionsConfiguration? = nil
        let conf = UISwipeActionsConfiguration(actions: [.init(style: .destructive, title: "Foo", handler: { _, _, _ in
            
        })])
        try verifyEvent(.leadingSwipeActionsConfigurationForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.leadingSwipeActionsConfiguration(for: NibCell.self, self.fullfill(exp, andReturn: conf))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.leadingSwipeActionsConfiguration(self.fullfill(exp, andReturn: conf))}
        }, preparation: addIntItem(), action: {
            swipeActionConfiguration = $0.manager.tableDelegate?.tableView(sut.tableView, leadingSwipeActionsConfigurationForRowAt: indexPath(0, 0))
        })
        XCTAssertEqual(swipeActionConfiguration?.actions.count, 1)
        XCTAssertEqual(swipeActionConfiguration?.actions.first?.title, "Foo")
    }
    
    func testTrailingSwipeActionsConfiguration() throws {
        var swipeActionConfiguration: UISwipeActionsConfiguration? = nil
        let conf = UISwipeActionsConfiguration(actions: [.init(style: .destructive, title: "Foo", handler: { _, _, _ in
            
        })])
        try verifyEvent(.trailingSwipeActionsConfigurationForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.trailingSwipeActionsConfiguration(for: NibCell.self, self.fullfill(exp, andReturn: conf))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.trailingSwipeActionsConfiguration(self.fullfill(exp, andReturn: conf))}
        }, preparation: addIntItem(), action: {
            swipeActionConfiguration = $0.manager.tableDelegate?.tableView(sut.tableView, trailingSwipeActionsConfigurationForRowAt: indexPath(0, 0))
        })
        XCTAssertEqual(swipeActionConfiguration?.actions.count, 1)
        XCTAssertEqual(swipeActionConfiguration?.actions.first?.title, "Foo")
    }
    
    func testShouldSpringLoadRow() throws {
        try verifyEvent(.shouldSpringLoadRowAtIndexPathWithContext, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldSpringLoad(NibCell.self, self.fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldSpringLoad(self.fullfill(exp, andReturn: true))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, shouldSpringLoadRowAt: indexPath(0, 0), with: SpringLoadedContextMock()))
        }, expectedResult: true)
    }
    
    func testShouldBeginMultipleSelectionInteraction() throws {
        guard #available(iOS 13, *) else { throw XCTSkip() }
        try verifyEvent(.shouldBeginMultipleSelectionInteractionAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.shouldBeginMultipleSelectionInteraction(for: NibCell.self, self.fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.shouldBeginMultipleSelectionInteraction(self.fullfill(exp, andReturn: true))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView, shouldBeginMultipleSelectionInteractionAt: indexPath(0, 0)))
        }, expectedResult: true)
    }
    
    func testDidBeginMultipleSelectionInteraction() throws {
        guard #available(iOS 13, *) else { throw XCTSkip() }
        try verifyEvent(.didBeginMultipleSelectionInteractionAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.didBeginMultipleSelectionInteraction(for: NibCell.self, self.fullfill(exp, andReturn: ()))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.didBeginMultipleSelectionInteraction(self.fullfill(exp, andReturn: ())) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, didBeginMultipleSelectionInteractionAt: indexPath(0, 0))
        })
    }
    
    func testDidEndMultipleSelectionInteraction() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "didEndMultipleSelectionInteractionAT")
        sut.manager.didEndMultipleSelectionInteraction {
            exp.fulfill()
        }
        _ = sut.manager.tableDelegate?.tableViewDidEndMultipleSelectionInteraction(sut.tableView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testContextMenuConfiguration() throws {
        guard #available(iOS 13, *) else { return }
        var contextConfiguration : UIContextMenuConfiguration? = nil
        let conf : UIContextMenuConfiguration = UIContextMenuConfiguration(identifier: "Foo" as NSCopying, previewProvider: nil, actionProvider: nil)
        try verifyEvent(.contextMenuConfigurationForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.contextMenuConfiguration(for: NibCell.self, self.fullfill(exp, andReturn: conf))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.contextMenuConfiguration(self.fullfill(exp, andReturn: conf))}
        }, preparation: addIntItem(), action: {
            contextConfiguration = $0.manager.tableDelegate?.tableView(sut.tableView, contextMenuConfigurationForRowAt: indexPath(0, 0), point: CGPoint(x: 1, y: 1))
        })
        XCTAssertEqual(contextConfiguration?.identifier as? String, "Foo")
    }
    
    func testPreviewForHighlightingContextMenu() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "previewForHighlightingContextMenuWith")
        sut.manager.previewForHighlightingContextMenu { configuration in
            exp.fulfill()
            return nil
        }
        _ = sut.manager.tableDelegate?.tableView(sut.tableView, previewForHighlightingContextMenuWithConfiguration: .init())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPreviewForDismissingContextMenu() {
        guard #available(iOS 13, *) else { return }
        let exp = expectation(description: "previewForDismissingContextMenuWith")
        sut.manager.previewForDismissingContextMenu { configuration in
            exp.fulfill()
            return nil
        }
        _ = sut.manager.tableDelegate?.tableView(sut.tableView, previewForDismissingContextMenuWithConfiguration: .init())
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testTargetIndexPathForMoveFromTo() throws {
        try verifyEvent(.targetIndexPathForMoveFromRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.targetIndexPathForMove(NibCell.self, self.fullfill(exp, andReturn: indexPath(10, 10)))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.targetIndexPathForMove(self.fullfill(exp, andReturn: indexPath(10, 10)))}
        }, preparation: addIntItem(), action: {
            try XCTUnwrap($0.manager.tableDelegate?.tableView(sut.tableView,
                                                              targetIndexPathForMoveFromRowAt: indexPath(0, 0),
                                                              toProposedIndexPath: indexPath(1, 0)))
        }, expectedResult: indexPath(10, 10))
    }
    
    func testIndexPathForPreferredFocusedView() {
        let exp = expectation(description: "indexPathForPreferredFocusedView")
        sut.manager.indexPathForPreferredFocusedView {
            exp.fulfill()
            return nil
        }
        _ = sut.manager.tableDelegate?.indexPathForPreferredFocusedView(in: sut.tableView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
#if compiler(>=5.5)
    func testSelectionFollowsFocus() throws {
        guard #available(iOS 15, *) else { return }
        try verifyEvent(.selectionFollowsFocusForRowAtIndexPath, registration: { (sut, exp) in
            sut.manager.register(NibCell.self)
            sut.manager.selectionFollowsFocus(for: NibCell.self, self.fullfill(exp, andReturn: true))
        }, alternativeRegistration: { (sut, exp) in
            sut.manager.register(NibCell.self) { $0.selectionFollowsFocus(self.fullfill(exp, andReturn: true)) }
        }, preparation: addIntItem(), action: {
            $0.manager.tableDelegate?.tableView(sut.tableView, selectionFollowsFocusForRowAt: indexPath(0, 0))
        })
    }
#endif
    
    func testAllDelegateMethodSignatures() {
        XCTAssertEqual(String(describing: #selector(UITableViewDataSource.tableView(_:commit:forRowAt:))), EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDataSource.tableView(_:canEditRowAt:))), EventMethodSignature.canEditRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:))), EventMethodSignature.canMoveRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:))), EventMethodSignature.moveRowAtIndexPathToIndexPath.rawValue)
        #if os(iOS)
        XCTAssertEqual(String(describing: #selector(UITableViewDataSource.sectionIndexTitles(for:))), EventMethodSignature.sectionIndexTitlesForTableView.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:))), EventMethodSignature.sectionForSectionIndexTitleAtIndex.rawValue)
        #endif
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:heightForRowAt:))), EventMethodSignature.heightForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:))), EventMethodSignature.estimatedHeightForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:))), EventMethodSignature.indentationLevelForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))), EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue)
        
        #if os(iOS)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:))), EventMethodSignature.editActionsForRowAtIndexPath.rawValue)
        #endif
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:))), EventMethodSignature.accessoryButtonTappedForRowAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:willSelectRowAt:))), EventMethodSignature.willSelectRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:))), EventMethodSignature.didSelectRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:))), EventMethodSignature.willDeselectRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:))), EventMethodSignature.didDeselectRowAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:))), EventMethodSignature.heightForHeaderInSection.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:))), EventMethodSignature.heightForFooterInSection.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:))), EventMethodSignature.estimatedHeightForHeaderInSection.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:))), EventMethodSignature.estimatedHeightForFooterInSection.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:))), EventMethodSignature.willDisplayHeaderForSection.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:))), EventMethodSignature.willDisplayFooterForSection.rawValue)
        
        #if os(iOS)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:))), EventMethodSignature.willBeginEditingRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:))), EventMethodSignature.didEndEditingRowAtIndexPath.rawValue)
        #endif
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:))), EventMethodSignature.editingStyleForRowAtIndexPath.rawValue)
        #if os(iOS)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:))), EventMethodSignature.titleForDeleteButtonForRowAtIndexPath.rawValue)
        #endif
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:))), EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))), EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:))), EventMethodSignature.didEndDisplayingHeaderViewForSection.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:))), EventMethodSignature.didEndDisplayingFooterViewForSection.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:))), EventMethodSignature.shouldShowMenuForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:))), EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:))), EventMethodSignature.performActionForRowAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:))), EventMethodSignature.shouldHighlightRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:))), EventMethodSignature.didHighlightRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:))), EventMethodSignature.didUnhighlightRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:))), EventMethodSignature.targetIndexPathForMoveFromRowAtIndexPath.rawValue)
        if #available(tvOS 9.0, *) {
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:canFocusRowAt:))), EventMethodSignature.canFocusRowAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:))), EventMethodSignature.shouldUpdateFocusInContext.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:))), EventMethodSignature.didUpdateFocusInContextWithAnimationCoordinator.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:))), EventMethodSignature.indexPathForPreferredFocusedViewInTableView.rawValue)
        }
        
        // MARK: - UITableViewDragDelegate
        #if os(iOS)
        XCTAssertEqual(String(describing: #selector(UITableViewDragDelegate.tableView(_:itemsForBeginning:at:))),EventMethodSignature.itemsForBeginningDragSession.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDragDelegate.tableView(_:itemsForAddingTo:at:point:))), EventMethodSignature.itemsForAddingToDragSession.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragPreviewParametersForRowAt:))), EventMethodSignature.dragPreviewParametersForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionWillBegin:))), EventMethodSignature.dragSessionWillBegin.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionDidEnd:))), EventMethodSignature.dragSessionDidEnd.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionAllowsMoveOperation:))), EventMethodSignature.dragSessionAllowsMoveOperation.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionIsRestrictedToDraggingApplication:))), EventMethodSignature.dragSessionIsRestrictedToDraggingApplication.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDropDelegate.tableView(_:performDropWith:))), EventMethodSignature.performDropWithCoordinator.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDropDelegate.tableView(_:canHandle:))), EventMethodSignature.canHandleDropSession.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidEnter:))), EventMethodSignature.dropSessionDidEnter.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidUpdate:withDestinationIndexPath:))), EventMethodSignature.dropSessionDidUpdateWithDestinationIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidExit:))), EventMethodSignature.dropSessionDidExit.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidEnd:))), EventMethodSignature.dropSessionDidEnd.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropPreviewParametersForRowAt:))), EventMethodSignature.dropPreviewParametersForRowAtIndexPath.rawValue)
        
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:))), EventMethodSignature.leadingSwipeActionsConfigurationForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:))), EventMethodSignature.trailingSwipeActionsConfigurationForRowAtIndexPath.rawValue)
        XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:))), EventMethodSignature.shouldSpringLoadRowAtIndexPathWithContext.rawValue)
        
        if #available(iOS 13, *) {
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:))), EventMethodSignature.shouldBeginMultipleSelectionInteractionAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:))), EventMethodSignature.didBeginMultipleSelectionInteractionAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:))), EventMethodSignature.didEndMultipleSelectionInteraction.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:contextMenuConfigurationForRowAt:point:))), EventMethodSignature.contextMenuConfigurationForRowAtIndexPath.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:))), EventMethodSignature.previewForHighlightingContextMenu.rawValue)
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:))), EventMethodSignature.previewForDismissingContextMenu.rawValue)
        }
        
        if #available(iOS 15, *) {
            XCTAssertEqual(String(describing: #selector(UITableViewDelegate.tableView(_:selectionFollowsFocusForRowAt:))), EventMethodSignature.selectionFollowsFocusForRowAtIndexPath.rawValue)
        }
        
        #endif
    }
    
    func testEventsRegistrationPerfomance() {
        let manager = self.sut.manager
        manager.anomalyHandler.anomalyAction = { _ in }
        measure {
            manager.commitEditingStyle(for: NibCell.self, { _,_,_,_ in })
            manager.canEditCell(withItem: Int.self, { _,_ in return true })
            manager.canMove(NibCell.self, { _,_,_ in return true })
            manager.heightForCell(withItem: Int.self, { _,_ in return 44 })
            manager.estimatedHeightForCell(withItem: Int.self, { _,_ in return 44 })
            manager.indentationLevelForCell(withItem: Int.self,  { _,_ in return 0})
            manager.willDisplay(NibCell.self, { _,_,_ in })
            manager.accessoryButtonTapped(in: NibCell.self, { _,_,_ in })
            manager.willSelect(NibCell.self, {_,_,_ in return indexPath(0, 0)})
            manager.didSelect(NibCell.self, {_,_,_ in})
            manager.willDeselect(NibCell.self, {_,_,_ in return indexPath(0, 0)} )
            manager.didDeselect(NibCell.self, { _,_,_ in return })
            manager.heightForHeader(withItem: Int.self, { _,_ in return 20 })
            manager.heightForFooter(withItem: Int.self, { _,_ in return 20 })
            manager.estimatedHeightForHeader(withItem: Int.self, { _,_ in return 20 })
            manager.estimatedHeightForFooter(withItem: Int.self, { _,_ in return 20 })
            manager.willDisplayHeaderView(NibHeaderFooterView.self, { _,_,_ in })
            manager.willDisplayFooterView(NibHeaderFooterView.self, { _,_,_ in})
            manager.editingStyle(forItem: Int.self, { _,_ in return .none })
            manager.shouldIndentWhileEditing(NibCell.self, { _,_,_ in return true })
            manager.didEndDisplaying(NibCell.self, { _,_,_ in })
            manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { _,_,_ in })
            manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { _,_,_ in })
            manager.shouldShowMenu(for: NibCell.self, { _,_,_ in return true})
            manager.canPerformAction(for: NibCell.self, { _,_,_,_,_ in return true })
            manager.performAction(for: NibCell.self, { _,_,_,_,_ in })
            manager.shouldHighlight(NibCell.self, { _,_,_ in return true })
            manager.didHighlight(NibCell.self, { _,_,_ in })
            manager.didUnhighlight(NibCell.self, { _,_,_ in })
            #if os(iOS)
            manager.itemsForBeginningDragSession(from: NibCell.self, { (_, _, _, _) in [] })
            manager.itemsForAddingToDragSession(from: NibCell.self, { (_, _, _, _, _) in [] })
            manager.dragPreviewParameters(for: NibCell.self, { (_, _, _) in nil })
            manager.dragSessionWillBegin{ _ in }
            manager.dragSessionDidEnd{ _ in }
            manager.dragSessionAllowsMoveOperation{ _ in false }
            manager.dragSessionIsRestrictedToDraggingApplication{ _ in false }
            #endif
        }
    }
    
    func testSearchForEventPerfomance() {
        let manager = self.sut.manager
        sut.tableView = UITableView()
        manager.anomalyHandler.anomalyAction = { _ in }
        manager.commitEditingStyle(for: NibCell.self, { _,_,_,_ in })
        manager.canEditCell(withItem: Int.self, { _,_ in return true })
        manager.canMove(NibCell.self, { _,_,_ in return true })
        manager.heightForCell(withItem: Int.self, { _,_ in return 44 })
        manager.estimatedHeightForCell(withItem: Int.self, { _,_ in return 44 })
        manager.indentationLevelForCell(withItem: Int.self,  { _,_ in return 0})
        manager.willDisplay(NibCell.self, { _,_,_ in })
        manager.accessoryButtonTapped(in: NibCell.self, { _,_,_ in })
        manager.willSelect(NibCell.self, {_,_,_ in return indexPath(0, 0)})
        manager.didSelect(NibCell.self, {_,_,_ in})
        manager.willDeselect(NibCell.self, {_,_,_ in return indexPath(0, 0)} )
        manager.didDeselect(NibCell.self, { _,_,_ in return })
        manager.heightForHeader(withItem: Int.self, { _,_ in return 20 })
        manager.heightForFooter(withItem: Int.self, { _,_ in return 20 })
        manager.estimatedHeightForHeader(withItem: Int.self, { _,_ in return 20 })
        manager.estimatedHeightForFooter(withItem: Int.self, { _,_ in return 20 })
        manager.willDisplayHeaderView(NibHeaderFooterView.self, { _,_,_ in })
        manager.willDisplayFooterView(NibHeaderFooterView.self, { _,_,_ in})
        manager.editingStyle(forItem: Int.self, { _,_ in return .none })
        manager.shouldIndentWhileEditing(NibCell.self, { _,_,_ in return true })
        manager.didEndDisplaying(NibCell.self, { _,_,_ in })
        manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { _,_,_ in })
        manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { _,_,_ in })
        manager.shouldShowMenu(for: NibCell.self, { _,_,_ in return true})
        manager.canPerformAction(for: NibCell.self, { _,_,_,_,_ in return true })
        manager.performAction(for: NibCell.self, { _,_,_,_,_ in })
        manager.shouldHighlight(NibCell.self, { _,_,_ in return true })
        manager.didHighlight(NibCell.self, { _,_,_ in })
        manager.didUnhighlight(NibCell.self, { _,_,_ in })
        
        manager.register(NibCell.self)
        manager.memoryStorage.addItem(5)
        measure {
            manager.tableDelegate?.tableView(self.sut.tableView, didSelectRowAt: indexPath(0, 0))
        }
    }
    
    func testModelEventCalledWithCellTypeLeadsToAnomaly() {
        let exp = expectation(description: "Model event called with cell")
        let anomaly = DTTableViewManagerAnomaly.modelEventCalledWithCellClass(modelType: "NibCell", methodName: "canEditCell(withItem:_:)", subclassOf: "UITableViewCell")
        sut.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        sut.manager.canEditCell(withItem: NibCell.self) { _, _ in true }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "    ⚠️[DTTableViewManager] Event canEditCell(withItem:_:) registered with model type, that happens to be a subclass of UITableViewCell: NibCell.\n\n    This is likely not what you want, because this event expects to receive model type used for current indexPath instead of cell/view.\n    Reasoning behind it is the fact that for some events views have not yet been created(for example: tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)).\n    Because they are not created yet, this event cannot be called with cell/view object, and even it\'s type is unknown at this point, as the mapping resolution will happen later.\n\n    Most likely you need to use model type, that will be passed to this cell/view through ModelTransfer protocol.\n    For example, for height of cell that expects to receive model Int, event would look like so:\n            \n        manager.heightForCell(withItem: Int.self) { model, indexPath in\n            return 44\n        }")
    }
    
    func testUnusedEventLeadsToAnomaly() {
        let exp = expectation(description: "Unused event")
        let anomaly = DTTableViewManagerAnomaly.unusedEventDetected(viewType: "StringCell", methodName: "didSelect(_:_:)")
        sut.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        sut.manager.didSelect(StringCell.self) { _, _, _ in }
        waitForExpectations(timeout: 1.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] didSelect(_:_:) event registered for StringCell, but there were no view mappings registered for StringCell type. This event will never be called.")
    }
    
    func testUnregisteredMappingCausesAnomalyWhenEventIsRegistered() {
        let exp = expectation(description: "No mappings found")
        let anomaly = DTTableViewManagerAnomaly.eventRegistrationForUnregisteredMapping(viewClass: "StringCell", signature: EventMethodSignature.didSelectRowAtIndexPath.rawValue)
        sut.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        sut.manager.didSelect(StringCell.self) { _, _, _ in
            
        }
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] While registering event reaction for tableView:didSelectRowAtIndexPath:, no view mapping was found for view: StringCell")
    }
}

