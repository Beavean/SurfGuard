//
//  AppDelegate.swift
//  WebsiteFilter
//
//  Created by Beavean on 23.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        let navigationController = UINavigationController(rootViewController: WebPageViewController())
        window?.rootViewController = navigationController
        window?.tintColor = .tintColor
        window?.backgroundColor = .backgroundColor
        return true
    }
}
