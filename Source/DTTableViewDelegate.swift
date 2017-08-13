//
//  DTTableViewDelegate.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 13.08.17.
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

import UIKit
import DTModelStorage

open class DTTableViewDelegate : DTTableViewDelegateWrapper, UITableViewDelegate {
    override func delegateWasReset() {
        tableView?.delegate = nil
        tableView?.delegate = self
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = tableViewEventReactions.performReaction(of: .cell, signature: EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.willDisplayHeaderForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, willDisplayFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.willDisplayFooterForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if configuration.sectionHeaderStyle == .title { return nil }
        
        if let model = self.headerModel(forSection:section) {
            let view : UIView?
            do {
                view = try self.viewFactory.headerViewForModel(model, atIndexPath: IndexPath(index: section))
            } catch let error as DTTableViewFactoryError {
                handleTableViewFactoryError(error)
                view = nil
            } catch {
                view = nil
            }
            
            if let createdView = view
            {
                _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionHeader),
                                                            signature: EventMethodSignature.configureHeader.rawValue,
                                                            view: createdView, model: model, location: IndexPath(item: 0, section: section))
            }
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if configuration.sectionFooterStyle == .title { return nil }
        
        if let model = self.footerModel(forSection: section) {
            let view : UIView?
            do {
                view = try self.viewFactory.footerViewForModel(model, atIndexPath: IndexPath(index: section))
            } catch let error as DTTableViewFactoryError {
                handleTableViewFactoryError(error)
                view = nil
            } catch {
                view = nil
            }
            
            if let createdView = view
            {
                _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionFooter),
                                                            signature: EventMethodSignature.configureFooter.rawValue,
                                                            view: createdView, model: model, location: IndexPath(item: 0, section: section))
            }
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = performHeaderReaction(.heightForHeaderInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        if let height = (delegate as? UITableViewDelegate)?.tableView?(tableView, heightForHeaderInSection: section) {
            return height
        }
        if configuration.sectionHeaderStyle == .title {
            if let _ = self.headerModel(forSection:section)
            {
                return UITableViewAutomaticDimension
            }
            return CGFloat.leastNormalMagnitude
        }
        
        if let _ = self.headerModel(forSection:section)
        {
            return self.tableView?.sectionHeaderHeight ?? CGFloat.leastNormalMagnitude
        }
        return CGFloat.leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let height = performHeaderReaction(.estimatedHeightForHeaderInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? tableView.estimatedSectionHeaderHeight
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let height = performFooterReaction(.heightForFooterInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        if let height = (delegate as? UITableViewDelegate)?.tableView?(tableView, heightForFooterInSection: section) {
            return height
        }
        if configuration.sectionFooterStyle == .title {
            if let _ = self.footerModel(forSection:section) {
                return UITableViewAutomaticDimension
            }
            return CGFloat.leastNormalMagnitude
        }
        
        if let _ = self.footerModel(forSection:section) {
            return self.tableView?.sectionFooterHeight ?? CGFloat.leastNormalMagnitude
        }
        return CGFloat.leastNormalMagnitude
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let height = performFooterReaction(.estimatedHeightForFooterInSection, location: section, provideView: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? tableView.estimatedSectionFooterHeight
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let eventReaction = cellReaction(.willSelectRowAtIndexPath, location: indexPath) {
            return performCellReaction(eventReaction, location: indexPath, provideCell: true) as? IndexPath
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, willSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let eventReaction = cellReaction(.willDeselectRowAtIndexPath, location: indexPath) {
            return performCellReaction(eventReaction, location: indexPath, provideCell: true) as? IndexPath
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, willDeselectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = performCellReaction(.didSelectRowAtIndexPath, location: indexPath, provideCell: true)
        (self.delegate as? UITableViewDelegate)?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        _ = performCellReaction(.didDeselectRowAtIndexPath, location: indexPath, provideCell: true)
        (self.delegate as? UITableViewDelegate)?.tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = performCellReaction(.heightForRowAtIndexPath, location: indexPath, provideCell: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = performCellReaction(.estimatedHeightForRowAtIndexPath, location: indexPath, provideCell: false) as? CGFloat {
            return height
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? tableView.estimatedRowHeight
    }
    
    open func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if let level = performCellReaction(.indentationLevelForRowAtIndexPath, location: indexPath, provideCell: false) as? Int {
            return level
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, indentationLevelForRowAt: indexPath) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        _ = performCellReaction(.accessoryButtonTappedForRowAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UITableViewDelegate)?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let eventReaction = cellReaction(.editActionsForRowAtIndexPath, location: indexPath) {
            return performCellReaction(eventReaction, location: indexPath, provideCell: true) as? [UITableViewRowAction]
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, editActionsForRowAt: indexPath)
    }
    #endif
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        _ = performCellReaction(.willBeginEditingRowAtIndexPath, location: indexPath, provideCell: true)
        (delegate as? UITableViewDelegate)?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }
    #endif
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndEditingRowAt: indexPath) }
        guard let indexPath = indexPath else { return }
        _ = performCellReaction(.didEndEditingRowAtIndexPath, location: indexPath, provideCell: true)
    }
    #endif
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if let editingStyle = performCellReaction(.editingStyleForRowAtIndexPath, location: indexPath, provideCell: true) as? UITableViewCellEditingStyle {
            return editingStyle
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, editingStyleForRowAt: indexPath) ?? .none
    }
    
    #if os(iOS)
    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let eventReaction = cellReaction(.titleForDeleteButtonForRowAtIndexPath, location: indexPath) {
            return performCellReaction(eventReaction, location: indexPath, provideCell: true) as? String
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath)
    }
    #endif
    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.shouldIndentWhileEditingRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldIndentWhileEditingRowAt: indexPath) ?? tableView.cellForRow(at: indexPath)?.shouldIndentWhileEditing ?? true
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath) }
        guard let model = storage.item(at: indexPath) else { return }
        _ = tableViewEventReactions.performReaction(of: .cell, signature: EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue, view: cell, model: model, location: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.headerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionHeader), signature: EventMethodSignature.didEndDisplayingHeaderViewForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section) }
        guard let model = (storage as? HeaderFooterStorage)?.footerModel(forSection: section) else { return }
        _ = tableViewEventReactions.performReaction(of: .supplementaryView(kind: DTTableViewElementSectionFooter), signature: EventMethodSignature.didEndDisplayingFooterViewForSection.rawValue, view: view, model: model, location: IndexPath(item: 0, section: section))
    }
    
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.shouldShowMenuForRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldShowMenuForRowAt: indexPath) ?? false
    }
    
    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let item = storage.item(at: indexPath), let model = RuntimeHelper.recursivelyUnwrapAnyValue(item),
            let cell = tableView.cellForRow(at: indexPath)
            else { return false }
        if let reaction = tableViewEventReactions.reaction(of: .cell, signature: EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue, forModel: model, view: cell) as? FiveArgumentsEventReaction {
            return reaction.performWithArguments((action,sender as Any,cell,model,indexPath)) as? Bool ?? false
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) ?? false
    }
    
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender) }
        guard let item = storage.item(at: indexPath), let model = RuntimeHelper.recursivelyUnwrapAnyValue(item),
            let cell = tableView.cellForRow(at: indexPath)
            else { return }
        if let reaction = tableViewEventReactions.reaction(of: .cell, signature: EventMethodSignature.performActionForRowAtIndexPath.rawValue, forModel: model, view: cell) as? FiveArgumentsEventReaction {
            _ = reaction.performWithArguments((action,sender as Any,cell,model,indexPath))
        }
    }
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.shouldHighlightRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, shouldHighlightRowAt: indexPath) ?? true
    }
    
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didHighlightRowAt: indexPath) }
        _ = performCellReaction(.didHighlightRowAtIndexPath, location: indexPath, provideCell: true)
    }
    
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        defer { (delegate as? UITableViewDelegate)?.tableView?(tableView, didUnhighlightRowAt: indexPath) }
        _ = performCellReaction(.didUnhighlightRowAtIndexPath, location: indexPath, provideCell: true)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if let should = performCellReaction(.canFocusRowAtIndexPath, location: indexPath, provideCell: true) as? Bool {
            return should
        }
        return (delegate as? UITableViewDelegate)?.tableView?(tableView, canFocusRowAt: indexPath) ?? tableView.cellForRow(at: indexPath)?.canBecomeFocused ?? true
    }
}
