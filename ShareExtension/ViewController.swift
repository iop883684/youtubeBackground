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


class ViewController: UIViewController {
    
    @IBOutlet var searchText:UITextField!
    @IBOutlet var btSearch:UIButton!
    @IBOutlet var indicator:UIActivityIndicatorView!
    
    @IBOutlet var imgThumb:UIImageView!
    @IBOutlet var lbTitle:UILabel!
    
    @IBOutlet var btClearUrl:UIButton!
    @IBOutlet var qualitySwitch: UISwitch!
    @IBOutlet var playerContainer: UISwitch!
    
    @IBOutlet var tableView:UITableView!
    
    var listVideo = [Data]()
    var listUrl = [AnyHashable: URL]()
    var currenLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btSearch.layer.cornerRadius = 5
        btClearUrl.layer.cornerRadius = 5
        
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "VideoCell")
        tableView.tableFooterView = UIView(frame: .zero)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        setupPlayer()
    }
    
    
    @objc func appBecomeActive(){
        if let url = UserDefaults.standard.string(forKey: "save_url"){
            searchText.text = url
            if listUrl.count == 0 || currenLink != url{
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
        indicator.startAnimating()
        
        XCDYouTubeClient.default().getVideoWithIdentifier(playId) { [weak self] (video, error ) in
            
            guard let sSelf = self else {return}
            sSelf.indicator.stopAnimating()
            
            if let er = error {
                
                let alertVC = UIAlertController(title: "Error", message: er.localizedDescription, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertVC.addAction(cancelAction)
                sSelf.present(alertVC, animated: true, completion: nil)
                print(er)
                
            } else if let video = video {
                
                
                
                sSelf.listUrl = video.streamURLs;
                //                for streamLink in video.streamURLs{
                //                    print(streamLink.key)
                //                    print(streamLink.value)
                //                }
                //                print(video.streamURLs)
                
                sSelf.updateThumbTitle(video: video, link: link)
                
                AVPlayerViewControllerManager.shared.lowQualityMode = sSelf.qualitySwitch.isOn
                AVPlayerViewControllerManager.shared.video = video
                
            }
            
            sSelf.currenLink = ytLink
        }
        
    }
    
    func updateThumbTitle(video: XCDYouTubeVideo, link: String?){
        
        
        lbTitle.text = video.title
        
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
        
        do{
            let saveVideo = Video(title: video.title, thumbUrl: video.thumbnailURL?.absoluteString ?? "", url: link ?? "")
            let encoded = try JSONEncoder().encode(saveVideo)
            VideoCache.appendData(value: encoded, type: .playing)
        }catch{
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.listVideo = VideoCache.getData(type: .playing)
            print("item", self.listVideo.count)
            self.tableView.reloadData()
        }
        
        
        
        
    }
    
    @IBAction func channgeQuality(sender: UISwitch){
        AVPlayerViewControllerManager.shared.lowQualityMode = sender.isOn
    }
    
    @IBAction func channgeAudioPiority(sender: UISwitch){
        AVPlayerViewControllerManager.shared.piorityAudio = sender.isOn
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

extension ViewController: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listVideo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        cell.setDataCell(data: listVideo[indexPath.row])
        return cell
    }
    
}

extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        do{
            let video =  try JSONDecoder().decode(Video.self, from: listVideo[indexPath.row])
            getStreamingLink(video.url)
        }catch{
            print(error.localizedDescription)
            
        }
        
    }
    
}
