//
//  DTTableViewManager+SwiftUIRegistration.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 22.06.2022.
//  Copyright © 2022 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// swiftlint:disable line_length

@available(iOS 13, tvOS 13, *)
/// Extension for registering SwiftUI views.
public extension DTTableViewManager {
    
    /// Register mapping from `model` type to SwiftUI view `Content`, presented in `HostingTableViewCell`.
    ///
    /// When `HostingTableViewCell` is first dequeued, `Content` view will be created and added to view hierarchy. This will also add hosting controller, that hosts this cell, as a child view controller for parent view controller, containing tableView. This is required for proper sizing and appearance events of SwiftUI view.
    ///
    /// However, adding SwiftUI hosting controller as a child may produce some unintended effects, for example showing navigation bar even though `Content` view has nothing to do with navigation stack. To avoid this problem, hosting controller may be customized. Read more about this in [Documentation](Documentation/SwiftUI.md)
    /// - Parameters:
    ///   - model: data model, mapped to cell
    ///   - content: SwiftUI view, rendered inside UITableViewCell
    ///   - mapping: mapping configuration closure, executed before any registration or dequeue is performed.
    func registerHostingCell<Content:View, Model>(for model: Model.Type, content: @escaping (Model, IndexPath) -> Content, mapping: ((HostingCellViewModelMapping<Content, Model>) -> Void)? = nil) {
        viewFactory.registerHostingCell(content, parentViewController: delegate as? UIViewController, mapping: mapping)
    }
}
