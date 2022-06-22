//
//  DTTableViewManager+Delegate.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 26.08.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import DTModelStorage

public extension DTTableViewManager {
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didSelectRowAt:)` method is called for `cellClass`.
    func didSelect<Cell:ModelTransfer>(_ cellClass:  Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell:UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .didSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willSelectRowAt:)` method is called for `cellClass`.
    func willSelect<Cell:ModelTransfer>(_ cellClass:  Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> IndexPath?) where Cell:UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self, signature: .willSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDeselectRowAt:)` method is called for `cellClass`.
    func willDeselect<Cell:ModelTransfer>(_ cellClass:  Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> IndexPath?) where Cell:UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self, signature: .willDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didDeselectRowAt:)` method is called for `cellClass`.
    func didDeselect<Cell:ModelTransfer>(_ cellClass:  Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell:UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self, signature: .didDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine cell height in `UITableViewDelegate.tableView(_:heightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    func heightForCell<Model>(withItem itemType: Model.Type, _ closure: @escaping (Model, IndexPath) -> CGFloat) {
        tableDelegate?.appendReaction(viewType: .cell, for: Model.self, signature: .heightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated cell height in `UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    func estimatedHeightForCell<Model>(withItem itemType: Model.Type, _ closure: @escaping (Model, IndexPath) -> CGFloat) {
        tableDelegate?.appendReaction(viewType: .cell, for: Model.self, signature: .estimatedHeightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine indentation level in `UITableViewDelegate.tableView(_:indentationLevelForRowAt:)` method, when it's called for cell which model is of `itemType`.
    func indentationLevelForCell<Model>(withItem itemType: Model.Type, _ closure: @escaping (Model, IndexPath) -> Int) {
        tableDelegate?.appendReaction(viewType: .cell, for: Model.self, signature: .indentationLevelForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayCell:forRowAt:)` method is called for `cellClass`.
    func willDisplay<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .willDisplayCellForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:accessoryButtonTappedForRowAt:)` method is called for `cellClass`.
    func accessoryButtonTapped<Cell:ModelTransfer>(in cellClass: Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self, signature: .accessoryButtonTappedForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine header height in `UITableViewDelegate.tableView(_:heightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    func heightForHeader<Model>(withItem type: Model.Type, _ closure: @escaping (Model, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: Model.self, signature: .heightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated header height in `UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    func estimatedHeightForHeader<Model>(withItem type: Model.Type, _ closure: @escaping (Model, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: Model.self, signature: .estimatedHeightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine footer height in `UITableViewDelegate.tableView(_:heightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    func heightForFooter<Model>(withItem type: Model.Type, _ closure: @escaping (Model, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: Model.self, signature: .heightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated footer height in `UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    func estimatedHeightForFooter<Model>(withItem type: Model.Type, _ closure: @escaping (Model, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: Model.self, signature: .estimatedHeightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)` method is called for `headerClass`.
    func willDisplayHeaderView<View:ModelTransfer>(_ headerClass: View.Type, _ closure: @escaping (View, View.ModelType, Int) -> Void) where View: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: View.self, signature: .willDisplayHeaderForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)` method is called for `footerClass`.
    func willDisplayFooterView<View:ModelTransfer>(_ footerClass: View.Type, _ closure: @escaping (View, View.ModelType, Int) -> Void) where View: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: View.self, signature: .willDisplayFooterForSection, closure: closure)
    }
    
#if os(iOS)
    @available(iOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editActionsForRowAt:)` method is called for `cellClass`.
    func editActions<Cell:ModelTransfer>(for cellClass: Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> [UITableViewRowAction]?) where Cell: UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self, signature: .editActionsForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willBeginEditingRowAt:)` method is called for `cellClass`.
    func willBeginEditing<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .willBeginEditingRowAtIndexPath, closure: closure)
    }

    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndEditingRowAt:)` method is called for `cellClass`.
    func didEndEditing<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .didEndEditingRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)` method is called for `cellClass`.
    func titleForDeleteConfirmationButton<Cell:ModelTransfer>(in cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> String?) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .titleForDeleteButtonForRowAtIndexPath, closure: closure)
    }
#endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editingStyleForRowAt:)` method is called for cell that contains item `ofType` at `indexPath`.
    func editingStyle<Model>(forItem ofType:Model.Type, _ closure: @escaping (Model, IndexPath) -> UITableViewCell.EditingStyle)
    {
        tableDelegate?.appendReaction(viewType: .cell, for: Model.self, signature: .editingStyleForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)` method is called for `cellClass`.
    func shouldIndentWhileEditing<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Bool) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .shouldIndentWhileEditingRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingCell:forRowAt:)` method is called for `cellClass`.
    func didEndDisplaying<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self, signature: .didEndDisplayingCellForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)` method is called for `headerClass`.
    func didEndDisplayingHeaderView<View:ModelTransfer>(_ headerClass: View.Type, _ closure: @escaping (View, View.ModelType, Int) -> Void) where View: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: View.self, signature: .didEndDisplayingHeaderViewForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)` method is called for `footerClass`.
    func didEndDisplayingFooterView<View:ModelTransfer>(_ footerClass: View.Type, _ closure: @escaping (View, View.ModelType, Int) -> Void) where View: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: View.self, signature: .didEndDisplayingFooterViewForSection, closure: closure)
    }
    
    @available(iOS, deprecated: 13.0)
    @available(tvOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)` method is called for `cellClass`.
    func shouldShowMenu<Cell:ModelTransfer>(for cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Bool) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .shouldShowMenuForRowAtIndexPath, closure: closure)
    }
    
    @available(iOS, deprecated: 13.0)
    @available(tvOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)` method is called for `cellClass`.
    func canPerformAction<Cell:ModelTransfer>(for cellClass: Cell.Type, _ closure: @escaping (Selector, Any?, Cell, Cell.ModelType, IndexPath) -> Bool) where Cell: UITableViewCell {
        tableDelegate?.append5ArgumentReaction(for: Cell.self,
                                               signature: .canPerformActionForRowAtIndexPath,
                                               closure: closure)
    }
    
    @available(iOS, deprecated: 13.0)
    @available(tvOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)` method is called for `cellClass`.
    func performAction<Cell:ModelTransfer>(for cellClass: Cell.Type, _ closure: @escaping (Selector, Any?, Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell {
        tableDelegate?.append5ArgumentReaction(for: Cell.self,
                                               signature: .performActionForRowAtIndexPath,
                                               closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldHighlightRowAt:)` method is called for `cellClass`.
    func shouldHighlight<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Bool) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .shouldHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didHighlightRowAt:)` method is called for `cellClass`.
    func didHighlight<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .didHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didUnhighlightRowAt:)` method is called for `cellClass`.
    func didUnhighlight<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .didUnhighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canFocusRowAt:)` method is called for `cellClass`.
    func canFocus<Cell:ModelTransfer>(_ cellClass:Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Bool) where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self, signature: .canFocusRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldUpdateFocusInContext:)` method is called.
    func shouldUpdateFocus(_ closure: @escaping (UITableViewFocusUpdateContext) -> Bool)
    {
        tableDelegate?.appendNonCellReaction(.shouldUpdateFocusInContext, closure: closure)
    }
    
    /// Registers `closure` tp be executed when `UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)` method is called.
    func didUpdateFocus(_ closure: @escaping (UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void)
    {
        tableDelegate?.appendNonCellReaction(.didUpdateFocusInContextWithAnimationCoordinator, closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.indexPathForPreferredFocusedView(in:)` method is called
    func indexPathForPreferredFocusedView(_ closure: @escaping () -> IndexPath?)
    {
        tableDelegate?.appendNonCellReaction(.indexPathForPreferredFocusedViewInTableView, closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.targetIndexPathForMoveFromRowAt(_:toProposed:)` method is called for `cellClass`
    func targetIndexPathForMove<Cell:ModelTransfer>(_ cellClass: Cell.Type, _ closure: @escaping (IndexPath, Cell, Cell.ModelType, IndexPath) -> IndexPath) where Cell:UITableViewCell {
        tableDelegate?.append4ArgumentReaction(for: Cell.self,
                                               signature: .targetIndexPathForMoveFromRowAtIndexPath,
                                               closure: closure)
    }
    
#if os(iOS)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)` method is called for `cellClass`
    func leadingSwipeActionsConfiguration<Cell:ModelTransfer>(for cellClass: Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> UISwipeActionsConfiguration?) where Cell: UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self,
                                      signature: .leadingSwipeActionsConfigurationForRowAtIndexPath,
                                      closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)` method is called for `cellClass`
    func trailingSwipeActionsConfiguration<Cell:ModelTransfer>(for cellClass: Cell.Type, _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> UISwipeActionsConfiguration?) where Cell: UITableViewCell {
        tableDelegate?.appendReaction(for: Cell.self,
                                      signature: .trailingSwipeActionsConfigurationForRowAtIndexPath,
                                      closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:)` method is called for `cellClass`.
    func shouldSpringLoad<Cell:ModelTransfer>(_ cellClass: Cell.Type, _ closure: @escaping (UISpringLoadedInteractionContext, Cell, Cell.ModelType, IndexPath) -> Bool) where Cell: UITableViewCell {
        tableDelegate?.append4ArgumentReaction(for: Cell.self,
                                               signature: .shouldSpringLoadRowAtIndexPathWithContext,
                                               closure: closure)
    }
    
    #if compiler(>=5.1)
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    func shouldBeginMultipleSelectionInteraction<Cell:ModelTransfer>(for cellClass: Cell.Type,
                                                              _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Bool)
        where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self,
                                      signature: .shouldBeginMultipleSelectionInteractionAtIndexPath,
                                      closure: closure)
    }
    
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    func didBeginMultipleSelectionInteraction<Cell:ModelTransfer>(for cellClass: Cell.Type,
                                                                    _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Void)
        where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self,
                                      signature: .didBeginMultipleSelectionInteractionAtIndexPath,
                                      closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)` method is called
    func didEndMultipleSelectionInteraction(_ closure: @escaping () -> Void)
    {
        tableDelegate?.appendNonCellReaction(.didEndMultipleSelectionInteraction, closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.contextMenuConfigurationForRowAt(_:point:)` method is called
    func contextMenuConfiguration<Cell:ModelTransfer>(for cellClass: Cell.Type,
                                                        _ closure: @escaping (CGPoint, Cell, Cell.ModelType, IndexPath) -> UIContextMenuConfiguration?)
        where Cell: UITableViewCell
    {
        tableDelegate?.append4ArgumentReaction(for: Cell.self,
                                               signature: .contextMenuConfigurationForRowAtIndexPath,
                                               closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)` method is called
    func previewForHighlightingContextMenu(_ closure: @escaping (UIContextMenuConfiguration) -> UITargetedPreview?)
    {
        tableDelegate?.appendNonCellReaction(.previewForHighlightingContextMenu, closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)` method is called
    func previewForDismissingContextMenu(_ closure: @escaping (UIContextMenuConfiguration) -> UITargetedPreview?)
    {
        tableDelegate?.appendNonCellReaction(.previewForDismissingContextMenu, closure: closure)
    }
    #endif
    
    #if compiler(>=5.5)
    @available(iOS 15, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:selectionFollowsFocusForRowAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    func selectionFollowsFocus<Cell:ModelTransfer>(for cellClass: Cell.Type,
                                                                    _ closure: @escaping (Cell, Cell.ModelType, IndexPath) -> Bool)
        where Cell: UITableViewCell
    {
        tableDelegate?.appendReaction(for: Cell.self,
                                      signature: .selectionFollowsFocusForRowAtIndexPath,
                                      closure: closure)
    }
    #endif
#endif
}

public extension ViewModelMapping where View: UITableViewCell {
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didSelectRowAt:)` method is called.
    func didSelect(_ closure: @escaping (View, Model, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.didSelectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willSelectRowAt:)` method is called.
    func willSelect(_ closure: @escaping (View, Model, IndexPath) -> IndexPath?) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.willSelectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDeselectRowAt:)` method is called.
    func willDeselect(_ closure: @escaping (View, Model, IndexPath) -> IndexPath?) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.willDeselectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didDeselectRowAt:)` method is called.
    func didDeselect(_ closure: @escaping (View, Model, IndexPath) -> Void) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.didDeselectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed to determine cell height in `UITableViewDelegate.tableView(_:heightForRowAt:)` method, when it's called.
    func heightForCell(_ closure: @escaping (Model, IndexPath) -> CGFloat) {
        reactions.append(EventReaction(modelType: Model.self, signature: EventMethodSignature.heightForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed to determine estimated cell height in `UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)` method, when it's called.
    func estimatedHeightForCell(_ closure: @escaping (Model, IndexPath) -> CGFloat) {
        reactions.append(EventReaction(modelType: Model.self, signature: EventMethodSignature.estimatedHeightForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed to determine indentation level in `UITableViewDelegate.tableView(_:indentationLevelForRowAt:)` method, when it's called.
    func indentationLevelForCell(_ closure: @escaping (Model, IndexPath) -> Int) {
        reactions.append(EventReaction(modelType: Model.self, signature: EventMethodSignature.indentationLevelForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayCell:forRowAt:)` method is called.
    func willDisplay(_ closure: @escaping (View, Model, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:accessoryButtonTappedForRowAt:)` method is called.
    func accessoryButtonTapped(_ closure: @escaping (View, Model, IndexPath) -> Void) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.accessoryButtonTappedForRowAtIndexPath.rawValue, closure))
    }
    
#if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willBeginEditingRowAt:)` method is called.
    func willBeginEditing(_ closure: @escaping (View, Model, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self, signature: EventMethodSignature.willBeginEditingRowAtIndexPath.rawValue, closure))
    }

    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndEditingRowAt:)` method is called.
    func didEndEditing(_ closure: @escaping (View, Model, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self, signature: EventMethodSignature.didEndEditingRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)` method is called.
    func titleForDeleteConfirmationButton(_ closure: @escaping (View, Model, IndexPath) -> String?)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.titleForDeleteButtonForRowAtIndexPath.rawValue, closure))
    }
    
    #if compiler(>=5.5)
    @available(iOS 15, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:selectionFollowsFocusForRowAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    func selectionFollowsFocus(_ closure: @escaping (View, Model, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self, signature: EventMethodSignature.selectionFollowsFocusForRowAtIndexPath.rawValue, closure))
    }
    #endif

#endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editingStyleForRowAt:)` method is called.
    func editingStyle(_ closure: @escaping (Model, IndexPath) -> UITableViewCell.EditingStyle)
    {
        reactions.append(EventReaction(modelType: Model.self, signature: EventMethodSignature.editingStyleForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)` method is called.
    func shouldIndentWhileEditing(_ closure: @escaping (View, Model, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self, signature: EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingCell:forRowAt:)` method is called.
    func didEndDisplaying(_ closure: @escaping (View, Model, IndexPath) -> Void) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldHighlightRowAt:)` method is called.
    func shouldHighlight(_ closure: @escaping (View, Model, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.shouldHighlightRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didHighlightRowAt:)` method is called.
    func didHighlight(_ closure: @escaping (View, Model, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.didHighlightRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didUnhighlightRowAt:)` method is called.
    func didUnhighlight(_ closure: @escaping (View, Model, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.didUnhighlightRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canFocusRowAt:)` method is called.
    func canFocus(_ closure: @escaping (View, Model, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self, signature: EventMethodSignature.canFocusRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.targetIndexPathForMoveFromRowAt(_:toProposed:)` method is called.
    func targetIndexPathForMove(_ closure: @escaping (IndexPath, View, Model, IndexPath) -> IndexPath) {
        reactions.append(FourArgumentsEventReaction(View.self, modelType: Model.self,
                                                    argument: IndexPath.self,
                                                    signature: EventMethodSignature.targetIndexPathForMoveFromRowAtIndexPath.rawValue,
                                                    closure))
    }
    
#if os(iOS)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)` method is called.
    func leadingSwipeActionsConfiguration(_ closure: @escaping (View, Model, IndexPath) -> UISwipeActionsConfiguration?) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.leadingSwipeActionsConfigurationForRowAtIndexPath.rawValue,
                                       closure))
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)` method is called.
    func trailingSwipeActionsConfiguration(_ closure: @escaping (View, Model, IndexPath) -> UISwipeActionsConfiguration?) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.trailingSwipeActionsConfigurationForRowAtIndexPath.rawValue,
                                       closure))
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:)` method is called.
    func shouldSpringLoad(_ closure: @escaping (UISpringLoadedInteractionContext, View, Model, IndexPath) -> Bool) {
        reactions.append(FourArgumentsEventReaction(View.self, modelType: Model.self, argument: UISpringLoadedInteractionContext.self,
                                                    signature: EventMethodSignature.shouldSpringLoadRowAtIndexPathWithContext.rawValue,
                                                    closure))
    }
    
    #if compiler(>=5.1)
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)`method is called.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    func shouldBeginMultipleSelectionInteraction(_ closure: @escaping (View, Model, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.shouldBeginMultipleSelectionInteractionAtIndexPath.rawValue,
                                       closure))
    }
    
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)`method is called.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    func didBeginMultipleSelectionInteraction(_ closure: @escaping (View, Model, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self,
                                       signature: EventMethodSignature.didBeginMultipleSelectionInteractionAtIndexPath.rawValue, closure))
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.contextMenuConfigurationForRowAt(_:point:)` method is called.
    func contextMenuConfiguration(_ closure: @escaping (CGPoint, View, Model, IndexPath) -> UIContextMenuConfiguration?)
    {
        reactions.append(FourArgumentsEventReaction(View.self, modelType: Model.self, argument: CGPoint.self,
                                                    signature: EventMethodSignature.contextMenuConfigurationForRowAtIndexPath.rawValue,
                                                    closure))
    }
    #endif
#endif
}

public extension ViewModelMapping where View: UITableViewHeaderFooterView {
    private func appendReaction(signature: EventMethodSignature, _ closure: @escaping (Model, Int) -> CGFloat) {
        reactions.append(EventReaction(modelType: Model.self, signature: signature.rawValue, { model, indexPath in
            closure(model, indexPath.section)
        }))
    }
    
    private func appendReaction(signature: EventMethodSignature, supplementaryKind: String, _ closure: @escaping (View, Model, Int) -> Void) {
        reactions.append(EventReaction(viewType: View.self, modelType: Model.self, signature: signature.rawValue, { view, model, indexPath in
            closure(view, model, indexPath.section)
        }))
    }
    
    /// Registers `closure` to be executed to determine header height in `UITableViewDelegate.tableView(_:heightForHeaderInSection:)` method is called.
    func heightForHeader(_ closure: @escaping (Model, Int) -> CGFloat) {
        appendReaction(signature: .heightForHeaderInSection, closure)
    }
    
    /// Registers `closure` to be executed to determine estimated header height in `UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)` method is called.
    func estimatedHeightForHeader(_ closure: @escaping (Model, Int) -> CGFloat) {
        appendReaction(signature: .estimatedHeightForHeaderInSection, closure)
    }
    
    /// Registers `closure` to be executed to determine footer height in `UITableViewDelegate.tableView(_:heightForFooterInSection:)` method is called.
    func heightForFooter(_ closure: @escaping (Model, Int) -> CGFloat) {
        appendReaction(signature: .heightForFooterInSection, closure)
    }
    
    /// Registers `closure` to be executed to determine estimated footer height in `UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)` method is called.
    func estimatedHeightForFooter(_ closure: @escaping (Model, Int) -> CGFloat) {
        appendReaction(signature: .estimatedHeightForFooterInSection, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)` method is called.
    func willDisplayHeaderView(_ closure: @escaping (View, Model, Int) -> Void)
    {
        appendReaction(signature: .willDisplayHeaderForSection, supplementaryKind: DTTableViewElementSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)` method is called.
    func willDisplayFooterView(_ closure: @escaping (View, Model, Int) -> Void)
    {
        appendReaction(signature: .willDisplayFooterForSection, supplementaryKind: DTTableViewElementSectionFooter, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)` method is called.
    func didEndDisplayingHeaderView(_ closure: @escaping (View, Model, Int) -> Void)
    {
        appendReaction(signature: .didEndDisplayingHeaderViewForSection, supplementaryKind: DTTableViewElementSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)` method is called.
    func didEndDisplayingFooterView(_ closure: @escaping (View, Model, Int) -> Void)
    {
        appendReaction(signature: .didEndDisplayingFooterViewForSection, supplementaryKind: DTTableViewElementSectionFooter, closure)
    }
}
