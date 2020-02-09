//
//  ViewController.swift
//  ShareExtension
//
//  Created by LeDo on 2/1/20.
//  Copyright © 2020 LeDo. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVFoundation
import AVKit

struct YouTubeVideoQuality {
    static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
    static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
    static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
}


class ViewController: UIViewController {
    
    @IBOutlet var searchText:UITextField!
    @IBOutlet var btSearch:UIButton!
    
    @IBOutlet var imgThumb:UIImageView!
    @IBOutlet var lbTitle:UILabel!
    
    @IBOutlet var btClearUrl:UIButton!
    @IBOutlet var qualitySwitch: UISwitch!
    @IBOutlet var playerContainer: UIView!
    
    var listUrl = [AnyHashable: URL]()
    
    var willResume = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btSearch.layer.cornerRadius = 5
        btClearUrl.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        setupPlayer()
    }
    
    
    @objc func appBecomeActive(){
        if let url = UserDefaults.standard.string(forKey: "save_url"){
            searchText.text = url
            if listUrl.count == 0{
                getStreamingLink(searchText.text)
            }
        }   
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        searchText.text = UserDefaults.standard.string(forKey: "save_url")
        
    }
    
    @IBAction func searchBtPress(){
        
        getStreamingLink(searchText.text)
        
    }
    
    func getYoutubeId(youtubeUrl: String) -> String? {
        return URLComponents(string: youtubeUrl)?.queryItems?.first(where: { $0.name == "v" })?.value
    }
    
    func getStreamingLink(_ link: String?){
        
        guard let ytLink = link else{
            print("empty string")
            return
        }
        print(ytLink)
        let playId = getYoutubeId(youtubeUrl: ytLink)
        
        listUrl.removeAll()
        
        XCDYouTubeClient.default().getVideoWithIdentifier(playId) { [weak self] (video, error ) in
            
            guard let sSelf = self else {return}
            if let video = video {
                
                sSelf.listUrl = video.streamURLs;
                print(video.streamURLs)
                sSelf.updateThumbTitle(video: video)
                
                AVPlayerViewControllerManager.shared.lowQualityMode = sSelf.qualitySwitch.isOn
                AVPlayerViewControllerManager.shared.video = video
                
            }
        }
        
    }
    
    func updateThumbTitle(video: XCDYouTubeVideo){
        
        lbTitle.text = video.title
        
        //        if let url = video.thumbnailURL{
        //            let data = try? Data(contentsOf: url)
        //            if let imageData = data {
        //                imgThumb.image = UIImage(data: imageData)
        //            }
        //        }
        
        if let thumbnailURL = video.thumbnailURL {
            (URLSession.shared.dataTask(with: thumbnailURL, completionHandler: { data, response, error in
                if error != nil {
                    return
                }
                
                OperationQueue.main.addOperation({
                    if let imageData = data {
                        self.imgThumb.image = UIImage(data: imageData)
                    }
                })
                
            })).resume()
        }
        
    }
    
    @IBAction func channgeQuality(sender: UISwitch){
        AVPlayerViewControllerManager.shared.lowQualityMode = sender.isOn
    }
    
    func setupPlayer(){
        
        let playerViewController = AVPlayerViewControllerManager.shared.controller
        playerViewController.view.frame = playerContainer.bounds
        addChild(playerViewController)
        playerContainer.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
    }
    
    @IBAction func playBtnPress(sender:UIButton){
        
        //        self.present(AVPlayerViewControllerManager.shared.controller, animated: true) {
        //            AVPlayerViewControllerManager.shared.controller.player?.play()
        //        }
        AVPlayerViewControllerManager.shared.controller.player?.play()
        
    }
    
    @IBAction func clearUrl(){
        
        UserDefaults.standard.set("", forKey: "save_url")
        searchText.text = ""
        listUrl.removeAll()
        AVPlayerViewControllerManager.shared.video = nil
        
    }
    
}

