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

extension DTTableViewManager {
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didSelectRowAt:)` method is called for `cellClass`.
    open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T:UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .didSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willSelectRowAt:)` method is called for `cellClass`.
    open func willSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .willSelectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDeselectRowAt:)` method is called for `cellClass`.
    open func willDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> IndexPath?) where T:UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .willDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didDeselectRowAt:)` method is called for `cellClass`.
    open func didDeselect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T:UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .didDeselectRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine cell height in `UITableViewDelegate.tableView(_:heightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func heightForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        tableDelegate?.appendReaction(viewType: .cell, for: T.self, signature: .heightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated cell height in `UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func estimatedHeightForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat) {
        tableDelegate?.appendReaction(viewType: .cell, for: T.self, signature: .estimatedHeightForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine indentation level in `UITableViewDelegate.tableView(_:indentationLevelForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func indentationLevelForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> Int) {
        tableDelegate?.appendReaction(viewType: .cell, for: T.self, signature: .indentationLevelForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayCell:forRowAt:)` method is called for `cellClass`.
    open func willDisplay<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .willDisplayCellForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:accessoryButtonTappedForRowAt:)` method is called for `cellClass`.
    open func accessoryButtonTapped<T:ModelTransfer>(in cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .accessoryButtonTappedForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine header height in `UITableViewDelegate.tableView(_:heightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    open func heightForHeader<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: .heightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated header height in `UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)` method, when it's called for header which model is of `itemType`.
    open func estimatedHeightForHeader<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, modelClass: T.self, signature: .estimatedHeightForHeaderInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine footer height in `UITableViewDelegate.tableView(_:heightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    open func heightForFooter<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: .heightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed to determine estimated footer height in `UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)` method, when it's called for footer which model is of `itemType`.
    open func estimatedHeightForFooter<T>(withItem type: T.Type, _ closure: @escaping (T, Int) -> CGFloat) {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, modelClass: T.self, signature: .estimatedHeightForFooterInSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)` method is called for `headerClass`.
    open func willDisplayHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: .willDisplayHeaderForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)` method is called for `footerClass`.
    open func willDisplayFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: .willDisplayFooterForSection, closure: closure)
    }
    
#if os(iOS)
    @available(iOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editActionsForRowAt:)` method is called for `cellClass`.
    open func editActions<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> [UITableViewRowAction]?) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .editActionsForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willBeginEditingRowAt:)` method is called for `cellClass`.
    open func willBeginEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .willBeginEditingRowAtIndexPath, closure: closure)
    }

    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndEditingRowAt:)` method is called for `cellClass`.
    open func didEndEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .didEndEditingRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)` method is called for `cellClass`.
    open func titleForDeleteConfirmationButton<T:ModelTransfer>(in cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> String?) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .titleForDeleteButtonForRowAtIndexPath, closure: closure)
    }
#endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editingStyleForRowAt:)` method is called for cell that contains item `ofType` at `indexPath`.
    open func editingStyle<T>(forItem ofType:T.Type, _ closure: @escaping (T, IndexPath) -> UITableViewCell.EditingStyle)
    {
        tableDelegate?.appendReaction(viewType: .cell, for: T.self, signature: .editingStyleForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)` method is called for `cellClass`.
    open func shouldIndentWhileEditing<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .shouldIndentWhileEditingRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingCell:forRowAt:)` method is called for `cellClass`.
    open func didEndDisplaying<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self, signature: .didEndDisplayingCellForRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)` method is called for `headerClass`.
    open func didEndDisplayingHeaderView<T:ModelTransfer>(_ headerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionHeader, supplementaryClass: T.self, signature: .didEndDisplayingHeaderViewForSection, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)` method is called for `footerClass`.
    open func didEndDisplayingFooterView<T:ModelTransfer>(_ footerClass: T.Type, _ closure: @escaping (T, T.ModelType, Int) -> Void) where T: UIView
    {
        tableDelegate?.appendReaction(forSupplementaryKind: DTTableViewElementSectionFooter, supplementaryClass: T.self, signature: .didEndDisplayingFooterViewForSection, closure: closure)
    }
    
    @available(iOS, deprecated: 13.0)
    @available(tvOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)` method is called for `cellClass`.
    open func shouldShowMenu<T:ModelTransfer>(for cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .shouldShowMenuForRowAtIndexPath, closure: closure)
    }
    
    @available(iOS, deprecated: 13.0)
    @available(tvOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)` method is called for `cellClass`.
    open func canPerformAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell {
        tableDelegate?.append5ArgumentReaction(for: T.self,
                                               signature: .canPerformActionForRowAtIndexPath,
                                               closure: closure)
    }
    
    @available(iOS, deprecated: 13.0)
    @available(tvOS, deprecated: 13.0)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)` method is called for `cellClass`.
    open func performAction<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (Selector, Any?, T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell {
        tableDelegate?.append5ArgumentReaction(for: T.self,
                                               signature: .performActionForRowAtIndexPath,
                                               closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldHighlightRowAt:)` method is called for `cellClass`.
    open func shouldHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .shouldHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didHighlightRowAt:)` method is called for `cellClass`.
    open func didHighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .didHighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didUnhighlightRowAt:)` method is called for `cellClass`.
    open func didUnhighlight<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Void) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .didUnhighlightRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canFocusRowAt:)` method is called for `cellClass`.
    open func canFocus<T:ModelTransfer>(_ cellClass:T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self, signature: .canFocusRowAtIndexPath, closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldUpdateFocusInContext:)` method is called.
    open func shouldUpdateFocus(_ closure: @escaping (UITableViewFocusUpdateContext) -> Bool)
    {
        tableDelegate?.appendNonCellReaction(.shouldUpdateFocusInContext, closure: closure)
    }
    
    /// Registers `closure` tp be executed when `UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)` method is called.
    open func didUpdateFocus(_ closure: @escaping (UITableViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void)
    {
        tableDelegate?.appendNonCellReaction(.didUpdateFocusInContextWithAnimationCoordinator, closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.indexPathForPreferredFocusedView(in:)` method is called
    open func indexPathForPreferredFocusedView(_ closure: @escaping () -> IndexPath?)
    {
        tableDelegate?.appendNonCellReaction(.indexPathForPreferredFocusedViewInTableView, closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.targetIndexPathForMoveFromRowAt(_:toProposed:)` method is called for `cellClass`
    open func targetIndexPathForMove<T:ModelTransfer>(_ cellClass: T.Type, _ closure: @escaping (IndexPath, T, T.ModelType, IndexPath) -> IndexPath) where T:UITableViewCell {
        tableDelegate?.append4ArgumentReaction(for: T.self,
                                               signature: .targetIndexPathForMoveFromRowAtIndexPath,
                                               closure: closure)
    }
    
#if os(iOS)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)` method is called for `cellClass`
    open func leadingSwipeActionsConfiguration<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> UISwipeActionsConfiguration?) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self,
                                      signature: .leadingSwipeActionsConfigurationForRowAtIndexPath,
                                      closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)` method is called for `cellClass`
    open func trailingSwipeActionsConfiguration<T:ModelTransfer>(for cellClass: T.Type, _ closure: @escaping (T, T.ModelType, IndexPath) -> UISwipeActionsConfiguration?) where T: UITableViewCell {
        tableDelegate?.appendReaction(for: T.self,
                                      signature: .trailingSwipeActionsConfigurationForRowAtIndexPath,
                                      closure: closure)
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:)` method is called for `cellClass`.
    open func shouldSpringLoad<T:ModelTransfer>(_ cellClass: T.Type, _ closure: @escaping (UISpringLoadedInteractionContext, T, T.ModelType, IndexPath) -> Bool) where T: UITableViewCell {
        tableDelegate?.append4ArgumentReaction(for: T.self,
                                               signature: .shouldSpringLoadRowAtIndexPathWithContext,
                                               closure: closure)
    }
    
    #if compiler(>=5.1)
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    open func shouldBeginMultipleSelectionInteraction<T:ModelTransfer>(for cellClass: T.Type,
                                                              _ closure: @escaping (T, T.ModelType, IndexPath) -> Bool)
        where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self,
                                      signature: .shouldBeginMultipleSelectionInteractionAtIndexPath,
                                      closure: closure)
    }
    
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    open func didBeginMultipleSelectionInteraction<T:ModelTransfer>(for cellClass: T.Type,
                                                                    _ closure: @escaping (T, T.ModelType, IndexPath) -> Void)
        where T: UITableViewCell
    {
        tableDelegate?.appendReaction(for: T.self,
                                      signature: .didBeginMultipleSelectionInteractionAtIndexPath,
                                      closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableViewDidEndMultipleSelectionInteraction(_:)` method is called
    open func didEndMultipleSelectionInteraction(_ closure: @escaping () -> Void)
    {
        tableDelegate?.appendNonCellReaction(.didEndMultipleSelectionInteraction, closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.contextMenuConfigurationForRowAt(_:point:)` method is called
    open func contextMenuConfiguration<T:ModelTransfer>(for cellClass: T.Type,
                                                        _ closure: @escaping (CGPoint, T, T.ModelType, IndexPath) -> UIContextMenuConfiguration?)
        where T: UITableViewCell
    {
        tableDelegate?.append4ArgumentReaction(for: T.self,
                                               signature: .contextMenuConfigurationForRowAtIndexPath,
                                               closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:previewForHighlightingContextMenuWithConfiguration:)` method is called
    open func previewForHighlightingContextMenu(_ closure: @escaping (UIContextMenuConfiguration) -> UITargetedPreview?)
    {
        tableDelegate?.appendNonCellReaction(.previewForHighlightingContextMenu, closure: closure)
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:previewForDismissingContextMenuWithConfiguration:)` method is called
    open func previewForDismissingContextMenu(_ closure: @escaping (UIContextMenuConfiguration) -> UITargetedPreview?)
    {
        tableDelegate?.appendNonCellReaction(.previewForDismissingContextMenu, closure: closure)
    }
        #if compiler(<5.1.2)
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:willCommitMenuWithAnimator:)` method is called
    open func willCommitMenuWithAnimator(_ closure: @escaping (UIContextMenuInteractionCommitAnimating) -> Void)
    {
        tableDelegate?.appendNonCellReaction(.willCommitMenuWithAnimator, closure: closure)
    }
        #endif
    #endif
#endif
}

extension ViewModelMapping where T: UITableViewCell {
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didSelectRowAt:)` method is called for `cellClass`.
    open func didSelect(_ closure: @escaping (T, U, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.didSelectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willSelectRowAt:)` method is called for `cellClass`.
    open func willSelect(_ closure: @escaping (T, U, IndexPath) -> IndexPath?) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.willSelectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDeselectRowAt:)` method is called for `cellClass`.
    open func willDeselect(_ closure: @escaping (T, U, IndexPath) -> IndexPath?) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.willDeselectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didDeselectRowAt:)` method is called for `cellClass`.
    open func didDeselect(_ closure: @escaping (T, U, IndexPath) -> Void) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.didDeselectRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed to determine cell height in `UITableViewDelegate.tableView(_:heightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func heightForCell(_ closure: @escaping (U, IndexPath) -> CGFloat) {
        reactions.append(EventReaction(modelType: U.self, signature: EventMethodSignature.heightForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed to determine estimated cell height in `UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func estimatedHeightForCell(_ closure: @escaping (U, IndexPath) -> CGFloat) {
        reactions.append(EventReaction(modelType: U.self, signature: EventMethodSignature.estimatedHeightForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed to determine indentation level in `UITableViewDelegate.tableView(_:indentationLevelForRowAt:)` method, when it's called for cell which model is of `itemType`.
    open func indentationLevelForCell(_ closure: @escaping (U, IndexPath) -> Int) {
        reactions.append(EventReaction(modelType: U.self, signature: EventMethodSignature.indentationLevelForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayCell:forRowAt:)` method is called for `cellClass`.
    open func willDisplay(_ closure: @escaping (T, U, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:accessoryButtonTappedForRowAt:)` method is called for `cellClass`.
    open func accessoryButtonTapped(_ closure: @escaping (T, U, IndexPath) -> Void) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.accessoryButtonTappedForRowAtIndexPath.rawValue, closure))
    }
    
#if os(iOS)
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willBeginEditingRowAt:)` method is called for `cellClass`.
    open func willBeginEditing(_ closure: @escaping (T, U, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self, signature: EventMethodSignature.willBeginEditingRowAtIndexPath.rawValue, closure))
    }

    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndEditingRowAt:)` method is called for `cellClass`.
    open func didEndEditing(_ closure: @escaping (T, U, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self, signature: EventMethodSignature.didEndEditingRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)` method is called for `cellClass`.
    open func titleForDeleteConfirmationButton(_ closure: @escaping (T, U, IndexPath) -> String?)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.titleForDeleteButtonForRowAtIndexPath.rawValue, closure))
    }
#endif
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:editingStyleForRowAt:)` method is called for cell that contains item `ofType` at `indexPath`.
    open func editingStyle(_ closure: @escaping (U, IndexPath) -> UITableViewCell.EditingStyle)
    {
        reactions.append(EventReaction(modelType: U.self, signature: EventMethodSignature.editingStyleForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)` method is called for `cellClass`.
    open func shouldIndentWhileEditing(_ closure: @escaping (T, U, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self, signature: EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingCell:forRowAt:)` method is called for `cellClass`.
    open func didEndDisplaying(_ closure: @escaping (T, U, IndexPath) -> Void) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:shouldHighlightRowAt:)` method is called for `cellClass`.
    open func shouldHighlight(_ closure: @escaping (T, U, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.shouldHighlightRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didHighlightRowAt:)` method is called for `cellClass`.
    open func didHighlight(_ closure: @escaping (T, U, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.didHighlightRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didUnhighlightRowAt:)` method is called for `cellClass`.
    open func didUnhighlight(_ closure: @escaping (T, U, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.didUnhighlightRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:canFocusRowAt:)` method is called for `cellClass`.
    open func canFocus(_ closure: @escaping (T, U, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self, signature: EventMethodSignature.canFocusRowAtIndexPath.rawValue, closure))
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.targetIndexPathForMoveFromRowAt(_:toProposed:)` method is called for `cellClass`
    open func targetIndexPathForMove(_ closure: @escaping (IndexPath, T, U, IndexPath) -> IndexPath) {
        reactions.append(FourArgumentsEventReaction(T.self, modelType: U.self,
                                                    argument: IndexPath.self,
                                                    signature: EventMethodSignature.targetIndexPathForMoveFromRowAtIndexPath.rawValue,
                                                    closure))
    }
    
#if os(iOS)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)` method is called for `cellClass`
    open func leadingSwipeActionsConfiguration(_ closure: @escaping (T, U, IndexPath) -> UISwipeActionsConfiguration?) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.leadingSwipeActionsConfigurationForRowAtIndexPath.rawValue,
                                       closure))
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)` method is called for `cellClass`
    open func trailingSwipeActionsConfiguration(_ closure: @escaping (T, U, IndexPath) -> UISwipeActionsConfiguration?) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.trailingSwipeActionsConfigurationForRowAtIndexPath.rawValue,
                                       closure))
    }
    
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:)` method is called for `cellClass`.
    open func shouldSpringLoad(_ closure: @escaping (UISpringLoadedInteractionContext, T, U, IndexPath) -> Bool) {
        reactions.append(FourArgumentsEventReaction(T.self, modelType: U.self, argument: UISpringLoadedInteractionContext.self,
                                                    signature: EventMethodSignature.shouldSpringLoadRowAtIndexPathWithContext.rawValue,
                                                    closure))
    }
    
    #if compiler(>=5.1)
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:shouldBeginMultipleSelectionInteractionAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    open func shouldBeginMultipleSelectionInteraction(_ closure: @escaping (T, U, IndexPath) -> Bool)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.shouldBeginMultipleSelectionInteractionAtIndexPath.rawValue,
                                       closure))
    }
    
    @available(iOS 13, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.tableView(_:didBeginMultipleSelectionInteractionAt:)`method is called for `cellClass`.
    /// - Parameter Type: cell class to react for event
    /// - Parameter closure: closure to run.
    open func didBeginMultipleSelectionInteraction(_ closure: @escaping (T, U, IndexPath) -> Void)
    {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self,
                                       signature: EventMethodSignature.didBeginMultipleSelectionInteractionAtIndexPath.rawValue, closure))
    }
    
    @available(iOS 13.0, *)
    /// Registers `closure` to be executed when `UITableViewDelegate.contextMenuConfigurationForRowAt(_:point:)` method is called
    open func contextMenuConfiguration(_ closure: @escaping (CGPoint, T, U, IndexPath) -> UIContextMenuConfiguration?)
    {
        reactions.append(FourArgumentsEventReaction(T.self, modelType: U.self, argument: CGPoint.self,
                                                    signature: EventMethodSignature.contextMenuConfigurationForRowAtIndexPath.rawValue,
                                                    closure))
    }
    #endif
#endif
}

extension ViewModelMapping where T: UITableViewHeaderFooterView {
    private func appendReaction(signature: EventMethodSignature, supplementaryKind: String, _ closure: @escaping (U, Int) -> CGFloat) {
        reactions.append(EventReaction(modelType: U.self, signature: signature.rawValue, supplementaryKind: supplementaryKind, { model, indexPath in
            closure(model, indexPath.section)
        }))
    }
    
    private func appendReaction(signature: EventMethodSignature, supplementaryKind: String, _ closure: @escaping (T, U, Int) -> Void) {
        reactions.append(EventReaction(viewType: T.self, modelType: U.self, signature: signature.rawValue, supplementaryKind: supplementaryKind, { view, model, indexPath in
            closure(view, model, indexPath.section)
        }))
    }
    
    /// Registers `closure` to be executed to determine header height in `UITableViewDelegate.tableView(_:heightForHeaderInSection:)` method is called.
    open func heightForHeader(_ closure: @escaping (U, Int) -> CGFloat) {
        appendReaction(signature: .heightForHeaderInSection, supplementaryKind: DTTableViewElementSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed to determine estimated header height in `UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)` method is called.
    open func estimatedHeightForHeader(_ closure: @escaping (U, Int) -> CGFloat) {
        appendReaction(signature: .estimatedHeightForHeaderInSection, supplementaryKind: DTTableViewElementSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed to determine footer height in `UITableViewDelegate.tableView(_:heightForFooterInSection:)` method is called.
    open func heightForFooter(_ closure: @escaping (U, Int) -> CGFloat) {
        appendReaction(signature: .heightForFooterInSection, supplementaryKind: DTTableViewElementSectionFooter, closure)
    }
    
    /// Registers `closure` to be executed to determine estimated footer height in `UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)` method is called.
    open func estimatedHeightForFooter(_ closure: @escaping (U, Int) -> CGFloat) {
        appendReaction(signature: .estimatedHeightForFooterInSection, supplementaryKind: DTTableViewElementSectionFooter, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)` method is called.
    open func willDisplayHeaderView(_ closure: @escaping (T, U, Int) -> Void)
    {
        appendReaction(signature: .willDisplayHeaderForSection, supplementaryKind: DTTableViewElementSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)` method is called.
    open func willDisplayFooterView(_ closure: @escaping (T, U, Int) -> Void)
    {
        appendReaction(signature: .willDisplayFooterForSection, supplementaryKind: DTTableViewElementSectionFooter, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)` method is called.
    open func didEndDisplayingHeaderView(_ closure: @escaping (T, U, Int) -> Void)
    {
        appendReaction(signature: .didEndDisplayingHeaderViewForSection, supplementaryKind: DTTableViewElementSectionHeader, closure)
    }
    
    /// Registers `closure` to be executed, when `UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)` method is called.
    open func didEndDisplayingFooterView(_ closure: @escaping (T, U, Int) -> Void)
    {
        appendReaction(signature: .didEndDisplayingFooterViewForSection, supplementaryKind: DTTableViewElementSectionFooter, closure)
    }
}
