//
//  AppDelegate.swift
//  Example
//
//  Created by Denys Telezhkin on 26.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,  didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        CoreDataManager.sharedInstance.preloadData()
        return true
    }

}

