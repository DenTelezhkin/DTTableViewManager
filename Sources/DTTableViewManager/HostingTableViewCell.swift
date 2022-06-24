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

// swiftlint:disable missing_docs

@available(iOS 13, tvOS 13, *)
open class HostingTableViewCell<Content: View, Model>: UITableViewCell {

    private var hostingController: UIHostingController<AnyView>?
    
    open func updateWith(rootView: Content, configuration: HostingTableViewCellConfiguration) {
        if let existingHosting = hostingController {
            existingHosting.rootView = AnyView(rootView)
            hostingController?.view.invalidateIntrinsicContentSize()
        } else {
            let hosting = configuration.hostingControllerMaker(AnyView(rootView))
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
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil
    }

}
