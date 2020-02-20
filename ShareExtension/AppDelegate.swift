//
//  AppDelegate.swift
//  ShareExtension
//
//  Created by LeDo on 2/1/20.
//  Copyright © 2020 LeDo. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print("Playback error:", error)
        }
//        application.beginReceivingRemoteControlEvents()
        
        #if targetEnvironment(simulator)
        UserDefaults.standard.set("https://www.youtube.com/watch?v=yn9qhQSMCRk", forKey: "save_url")
        #endif
        
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let ytActionUrl = url.absoluteString.replacingOccurrences(of: "shareUrl://", with: "")
        if ytActionUrl.contains("add") {
            let ytUrl = url.absoluteString.replacingOccurrences(of: "add/", with: "")
            UserDefaults.standard.set(ytUrl, forKey: "save_url")
        } else if ytActionUrl.contains("play"){
            let ytUrl = url.absoluteString.replacingOccurrences(of: "play/", with: "")
            UserDefaults.standard.set(ytUrl, forKey: "save_url")
        } else if ytActionUrl.contains("youtube"){
            UserDefaults.standard.set(ytActionUrl, forKey: "save_url")
        }

        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AVPlayerViewControllerManager.shared.disconnectPlayer()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        AVPlayerViewControllerManager.shared.reconnectPlayer(rootViewController: self.window!.rootViewController!)
    }

}

