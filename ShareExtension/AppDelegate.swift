//
//  AppDelegate.swift
//  ShareExtension
//
//  Created by LeDo on 2/1/20.
//  Copyright © 2020 LeDo. All rights reserved.
//

import UIKit
import AVFoundation

let kNotiLoadVideo = Notification.Name("load_video")

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
        UIPasteboard.general.string = "https://www.youtube.com/watch?v=zZ2SNihQ03w"
        #endif
        
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let ytActionUrl = url.absoluteString.replacingOccurrences(of: "shareUrl://", with: "")
        if ytActionUrl.contains("add") {
            let ytUrl = url.absoluteString.replacingOccurrences(of: "add/", with: "")
            NotificationCenter.default.post(name: kNotiLoadVideo, object: nil,
                                            userInfo: [
                                                "action": ActionType.add.rawValue,
                                                "url": ytUrl]
            )
        } else if ytActionUrl.contains("play"){
            let ytUrl = url.absoluteString.replacingOccurrences(of: "play/", with: "")
            NotificationCenter.default.post(name: kNotiLoadVideo, object: nil,
                                            userInfo: [
                                                "action": ActionType.playAndAdd.rawValue,
                                                "url": ytUrl]
            )
        } else if ytActionUrl.contains("youtube"){
            NotificationCenter.default.post(name: kNotiLoadVideo, object: nil,
                                            userInfo: [
                                                "action": ActionType.none.rawValue,
                                                "url": ytActionUrl]
            )
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

