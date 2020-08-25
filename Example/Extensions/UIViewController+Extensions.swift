//
//  UIViewController+Extensions.swift
//  Example
//
//  Created by Denys Telezhkin on 25.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

protocol BarButtonCreatable {}
extension BarButtonCreatable where Self: UIViewController {
    func barButton(title: String, action: @escaping (Self) -> Void) -> UIBarButtonItem {
        UIBarButtonItem(title: title, image: nil, primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            action(self)
        }), menu: nil)
    }
}
extension UIViewController : BarButtonCreatable {}
