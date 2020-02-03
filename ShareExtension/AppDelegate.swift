//
//  AppDelegate.swift
//  ShareExtension
//
//  Created by LeDo on 2/1/20.
//  Copyright © 2020 LeDo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let ytUrl = url.absoluteString.replacingOccurrences(of: "shareUrl://", with: "")
        let alertController = UIAlertController(title: "Url", message: "\(ytUrl)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(okAction)
        
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
        return true
    }


}

