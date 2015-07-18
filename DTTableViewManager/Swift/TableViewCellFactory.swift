//
//  TableViewCellFactory.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 13.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import Foundation
import DTModelStorage
import Swift

class TableViewFactory
{
    private let tableView: UITableView
    
    private var mappings = [ViewModelMapping]()
    
    init(tableView: UITableView)
    {
        self.tableView = tableView
    }
    
    private func classClusterReflectionFromMirrorType(mirror: MirrorType) -> MirrorType
    {
        let typeReflection = reflect(mirror.value).summary
        switch typeReflection
        {
        case "__NSCFBoolean": fallthrough
        case "__NSCFNumber":
            return reflect(NSNumber)
        
        case "__NSCFConstantString": fallthrough
        case "Swift.String": fallthrough
        case "__NSCFString":
            return reflect(NSString)
            
        case "NSConcreteAttributedString": fallthrough
        case "NSConcreteMutableAttributedString":
            return reflect(NSAttributedString)
            
        case "__NSDictionaryM": fallthrough
        case "__NSDictionaryI":
            return reflect(NSDictionary)
            
        case "__NSArrayM": fallthrough
        case "__NSArrayI":
            return reflect(NSArray)
            
        case "__NSTaggedDate": fallthrough
        case "__NSDate":
            return reflect(NSDate)
            
        default:
//            println("Not found reflection for summary \(reflect(mirror.value).summary)")
            return mirror
        }
    }
    
    private func mappingForViewType(type: ViewType,modelTypeMirror: MirrorType) -> ViewModelMapping?
    {
        var adjustedModelTypeMirror = modelTypeMirror
        if modelTypeMirror.disposition == .Aggregate {
            // Possibly, Objective-C class clusters 
            adjustedModelTypeMirror = self.classClusterReflectionFromMirrorType(modelTypeMirror)
        }
        return self.mappings.filter({ (mapping) -> Bool in
            return mapping.viewType == type && mapping.modelTypeMirror.summary == adjustedModelTypeMirror.summary
        }).first
    }
    
    private func addMappingForViewType<T:ModelTransfer>(type: ViewType, viewClass : T.Type)
    {
        if self.mappingForViewType(type, modelTypeMirror: reflect(T.CellModel.self)) == nil
        {
            self.mappings.append(ViewModelMapping(viewType : type,
                viewTypeMirror : reflect(T),
                modelTypeMirror: reflect(T.CellModel.self),
                updateBlock: { (view, model) in
                    (view as! T).updateWithModel(model as! T.CellModel)
            }))
        }
    }
    
    func registerCellClass<T:ModelTransfer where T: UITableViewCell>(cellType : T.Type)
    {
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(reflect(cellType))
        if self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) == nil
        {
            // Storyboard prototype cell
            self.tableView.registerClass(T.self, forCellReuseIdentifier: reuseIdentifier)
            
            if UINib.nibExistsWithNibName(reuseIdentifier, inBundle: NSBundle(forClass: T.self)) {
                self.registerNibNamed(reuseIdentifier, forCellType: T.self)
            }
        }
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T: UITableViewCell>(nibName : String, forCellType cellType: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: NSBundle(forClass: T.self)), "Register cell nib method should be called only if nib exists")
        
        let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: T.self))
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(reflect(cellType))
        self.tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        self.addMappingForViewType(.Cell, viewClass: T.self)
    }
    
    func registerHeaderClass<T:ModelTransfer where T: UIView>(headerType : T.Type)
    {
        self.registerNibNamed(RuntimeHelper.classNameFromReflection(reflect(headerType)), forHeaderType: headerType)
    }
    
    func registerFooterClass<T:ModelTransfer where T:UIView>(footerType: T.Type)
    {
        self.registerNibNamed(RuntimeHelper.classNameFromReflection(reflect(footerType)), forFooterType: footerType)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forHeaderType headerType: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: NSBundle(forClass: T.self)), "Register header nib method should be called only if nib exists")
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(reflect(headerType))
        
        if T.isSubclassOfClass(UITableViewHeaderFooterView.self) {
            self.tableView.registerNib(UINib(nibName: nibName, bundle: NSBundle(forClass: T.self)), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        self.addMappingForViewType(.Header, viewClass: T.self)
    }
    
    func registerNibNamed<T:ModelTransfer where T:UIView>(nibName: String, forFooterType footerType: T.Type)
    {
        assert(UINib.nibExistsWithNibName(nibName, inBundle: NSBundle(forClass: T.self)), "Register footer nib method should be called only if nib exists")
        let reuseIdentifier = RuntimeHelper.classNameFromReflection(reflect(footerType))
        
        if T.isSubclassOfClass(UITableViewHeaderFooterView.self) {
            self.tableView.registerNib(UINib(nibName: nibName, bundle: NSBundle(forClass: T.self)), forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        }
        self.addMappingForViewType(.Footer, viewClass: T.self)
    }
    
    func cellForModel(model: Any, atIndexPath indexPath:NSIndexPath) -> UITableViewCell
    {
        // MARK: TODO replace with guard in Swift 2
        let unwrappedModel = recursiveUnwrapAnyValue(model)
        if unwrappedModel == nil {
            assertionFailure("Received nil model at indexPath: \(indexPath)")
        }
        
        let typeMirror = reflect(unwrappedModel!.dynamicType)
        if let mapping = self.mappingForViewType(.Cell, modelTypeMirror: typeMirror)
        {
            let cellClassName = RuntimeHelper.classNameFromReflection(mapping.viewTypeMirror)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellClassName, forIndexPath: indexPath) as! UITableViewCell
            mapping.updateBlock(cell, unwrappedModel!)
            return cell
        }
        
        assertionFailure("Unable to find cell mappings for type: \(reflect(typeMirror.value).summary)")
        
        return UITableViewCell()
    }
    
    func headerFooterViewWithMapping(mapping: ViewModelMapping, unwrappedModel: Any) -> UIView?
    {
        let viewClassName = RuntimeHelper.classNameFromReflection(mapping.viewTypeMirror)
        var view = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(viewClassName) as? UIView
        if view == nil {
            if let type = mapping.viewTypeMirror.value as? UIView.Type {
                view = type.dt_loadFromXib()
            }
        }
        precondition(view != nil,"failed creating view of type: \(viewClassName) for model: \(unwrappedModel)")
        
        mapping.updateBlock(view!,unwrappedModel)
        return view
    }
    
    func headerViewForModel(model: Any) -> UIView?
    {
        let unwrappedModel = recursiveUnwrapAnyValue(model)
        if unwrappedModel == nil {
            assertionFailure("Received nil model for headerViewModel")
        }
        
        let typeMirror = reflect(unwrappedModel!.dynamicType)
        
        if let mapping = self.mappingForViewType(.Header, modelTypeMirror: typeMirror) {
            return self.headerFooterViewWithMapping(mapping, unwrappedModel: unwrappedModel!)
        }
        
        return nil
    }
    
    func footerViewForModel(model: Any) -> UIView?
    {
        let unwrappedModel = recursiveUnwrapAnyValue(model)
        if unwrappedModel == nil {
            assertionFailure("Received nil model for footerViewModel")
        }
        
        let typeMirror = reflect(unwrappedModel!.dynamicType)
        
        if let mapping = self.mappingForViewType(.Footer, modelTypeMirror: typeMirror) {
            return self.headerFooterViewWithMapping(mapping, unwrappedModel: unwrappedModel!)
        }
        
        return nil
    }
}
