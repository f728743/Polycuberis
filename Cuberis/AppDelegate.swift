//
//  AppDelegate.swift
//  Cuberis
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    let game = Game()
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let rootViewController = window?.rootViewController as? GameViewController {
            rootViewController.game = game
        }
        return true
    }

}
