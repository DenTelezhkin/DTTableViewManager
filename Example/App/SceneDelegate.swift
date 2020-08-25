//
//  SceneDelegate.swift
//  Example
//
//  Created by Denys Telezhkin on 23.08.2020.
//  Copyright © 2020 Denys Telezhkin. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: ExamplesListViewController(style: .plain))
        window?.makeKeyAndVisible()
    }
}
