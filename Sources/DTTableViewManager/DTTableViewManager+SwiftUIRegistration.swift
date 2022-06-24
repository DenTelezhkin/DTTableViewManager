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

// swiftlint:disable missing_docs

@available(iOS 13, tvOS 13, *)
public extension DTTableViewManager {
    func registerHostingCell<Content:View, Model>(for model: Model.Type, content: @escaping (Model, IndexPath) -> Content, mapping: ((HostingCellViewModelMapping<Content, Model>) -> Void)? = nil) {
        viewFactory.registerHostingCell(content, parentViewController: delegate as? UIViewController, hostingControllerMaker: defaultHostingControllerMaker as? (AnyView) -> UIHostingController<AnyView>, mapping: mapping)
    }
}
