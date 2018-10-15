//
//  AppDelegate.swift
//  ARKitCoreML
//
//  Created by Jason Clark on 10/11/18.
//  Copyright © 2018 Raizlabs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ARSceneViewController())
        window?.makeKeyAndVisible()
        return true
    }

}

