//
//  HostingTableViewCell.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 22.06.2022.
//  Copyright © 2022 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

@available(iOS 13, tvOS 13, *)
/// Cell subclass, that allows hosting SwiftUI content inside UITableViewCell.
open class HostingTableViewCell<Content: View, Model>: UITableViewCell {

    private var hostingController: UIHostingController<Content>?
    
    /// Updates cell with new SwiftUI view. If the cell is being reused, it's hosting controller will also be reused.
    /// - Parameters:
    ///   - rootView: SwiftUI view
    ///   - configuration: configuration to use while updating
    open func updateWith(rootView: Content, configuration: HostingTableViewCellConfiguration<Content>) {
        
        if let existingHosting = hostingController {
            existingHosting.rootView = rootView
            hostingController?.view.invalidateIntrinsicContentSize()
            configuration.configureCell(self)
        } else {
            let hosting = configuration.hostingControllerMaker(rootView)
            hostingController = hosting
            if let backgroundColor = configuration.backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let hostingBackgroundColor = configuration.hostingViewBackgroundColor {
                hostingController?.view.backgroundColor = hostingBackgroundColor
            }
            if let contentViewBackgroundColor = configuration.contentViewBackgroundColor {
                contentView.backgroundColor = contentViewBackgroundColor
            }
            selectionStyle = configuration.selectionStyle
            
            hostingController?.view.invalidateIntrinsicContentSize()
            
            hosting.willMove(toParent: configuration.parentController)
            configuration.parentController?.addChild(hosting)
            contentView.addSubview(hosting.view)
            
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hosting.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            hosting.didMove(toParent: configuration.parentController)
            
            configuration.configureCell(self)
        }
    }
}
