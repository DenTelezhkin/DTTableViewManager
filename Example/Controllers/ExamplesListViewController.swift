//
//  ExamplesListViewController.swift
//  Example
//
//  Created by Denys Telezhkin on 24.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTTableViewManager
import SwiftUI

class ExamplesListViewController: UITableViewController, DTTableViewManageable {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Examples"
        manager.registerHostingConfiguration(for: Example.self) { _, model, _ in
            UIHostingConfiguration {
                HStack {
                    Text(model.title)
                        .font(.system(size: 20))
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.footnote.bold())
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
        } mapping: { [weak self] in
            $0.didSelect { _, model, _ in
                self?.navigationController?.pushViewController(model.controller, animated: true)
            }
        }
        manager.memoryStorage.setItems(Example.allCases)
    }
}
