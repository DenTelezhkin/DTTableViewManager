//
//  Example.swift
//  Example
//
//  Created by Denys Telezhkin on 24.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit

enum Example: CaseIterable {
    
    case addRemoveSelect
    case reorder
    case customViews
    case coreDataSearch
    case diffableCoreDataSearch
    case singleSectionDiffing
    case multiSectionDiffing
    
    var title: String {
        switch self {
            case .addRemoveSelect: return "Add/remove/select items"
            case .reorder: return "Editing/reorder"
            case .customViews: return "Custom views"
            case .coreDataSearch: return "CoreData search"
            case .diffableCoreDataSearch: return "Diffable CoreData search"
            case .singleSectionDiffing: return "Single section diffing"
            case .multiSectionDiffing: return "Multi section diffing"
        }
    }
    
    var controller: UIViewController {
        let viewController: UIViewController
        switch self {
            case .addRemoveSelect: viewController = AddRemoveViewController()
            case .reorder: viewController = ReorderViewController()
            case .customViews: viewController = CustomViewsController()
            case .coreDataSearch: viewController = CoreDataSearchViewController()
            case .diffableCoreDataSearch: viewController = DiffableCoreDataViewController()
            case .singleSectionDiffing: viewController = AutoDiffSearchViewController()
            case .multiSectionDiffing: viewController = MultiSectionDiffingTableViewController()
        }
        viewController.navigationItem.title = title
        return viewController
    }
}
