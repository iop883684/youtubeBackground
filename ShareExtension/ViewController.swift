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

enum ActionType: String {
    case none = "none"
    case play = "play"
    case add = "add"
    case playAndAdd = "playAndAdd"
}


class ViewController: UIViewController {

    @IBOutlet var btClipBoard:UIButton!
    @IBOutlet var btStop:UIButton!
    @IBOutlet var btNext:UIButton!
    
    @IBOutlet var indicator:UIActivityIndicatorView!
    
    @IBOutlet var qualitySwitch: UISwitch!
    @IBOutlet var playNextSwitch: UISwitch!
    @IBOutlet var playerContainer: UISwitch!
    
    @IBOutlet var tableView:UITableView!
    
    var listVideo = [Data]()
    var currentPlayIndex = 0
    var autoPlayNext = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btClipBoard.layer.cornerRadius = 5
        btStop.layer.cornerRadius = 5
        btNext.layer.cornerRadius = 5
        autoPlayNext = playNextSwitch.isOn
        
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "VideoCell")
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = 93
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addNewUrl(noti:)),
                                               name: kNotiLoadVideo,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
        setupPlayer()
        reloadData()
    }
    
        
    @objc func playerDidFinishPlaying(){
        print("finish playing")
        if autoPlayNext{
            nextBtnPress()
        }
    }
    
    @objc func addNewUrl(noti:Notification){
        
        guard let obj = noti.userInfo else{
            return
        }
        
        guard let url = obj["url"] as? String else{
            return
        }
        guard let actionStr = obj["action"] as? String, let action = ActionType(rawValue: actionStr)  else{
            return
        }
        
        getStreamingLink(url, action)
        
        
    }
    
    
    func getYoutubeId(youtubeUrl: String) -> String? {
        return URLComponents(string: youtubeUrl)?.queryItems?.first(where: { $0.name == "v" })?.value
    }
    
    func getStreamingLink(_ link: String?, _ action:ActionType){
        
        guard let ytLink = link, ytLink.count > 0 else{
            print("empty string")
            return
        }
        print(ytLink)
        let playId = getYoutubeId(youtubeUrl: ytLink)
        
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
                
//                print(video.streamURLs)
                
                if action == .play || action == .playAndAdd{
                    
                    AVPlayerViewControllerManager.shared.lowQualityMode = sSelf.qualitySwitch.isOn
                    AVPlayerViewControllerManager.shared.video = video
                    
                    AVPlayerViewControllerManager.shared.player?.play()
                    
                    if action == .playAndAdd{
                        //ko can -1 vi chua reload tableview
                        sSelf.currentPlayIndex = sSelf.listVideo.count
                    }
                    
                }
                
                if action == .add || action == .playAndAdd{
                    sSelf.addData(video: video, link: link)
                } else if sSelf.listVideo.count == 0{
                    sSelf.reloadData()
                }

                
            }

        }
        
    }
    
    func addData(video: XCDYouTubeVideo, link: String?){
        
        do{
            let saveVideo = Video(title: video.title, thumbUrl: video.thumbnailURL?.absoluteString ?? "", url: link ?? "", duration: Int(video.duration))
            let encoded = try JSONEncoder().encode(saveVideo)
            VideoCache.appendData(value: encoded, type: .playing)
        }catch{
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.reloadData()
        }
        
    }
    
    func reloadData(){
        self.listVideo = VideoCache.getData(type: .playing)
        print("item", self.listVideo.count)
        self.tableView.reloadData()
    }
    
    
    @IBAction func lowQualitySwitch(sender: UISwitch){
        AVPlayerViewControllerManager.shared.lowQualityMode = sender.isOn
    }
    
    @IBAction func audioPioritySwitch(sender: UISwitch){
        AVPlayerViewControllerManager.shared.piorityAudio = sender.isOn
    }
    
    @IBAction func autoPlayNextSwitch(sender: UISwitch){
        autoPlayNext = sender.isOn
    }
    
    @IBAction func btClipBoardPress(){
        
        // read from clipboard
        if let content = UIPasteboard.general.string{
            print(content)
            //https://youtu.be/zZ2SNihQ03w
            if content.contains("youtu"){
                let newUrl = content.replacingOccurrences(of: "https://youtu.be/", with: "https://www.youtube.com/watch?v=")
                getStreamingLink(newUrl, .playAndAdd)
            }
        }
        
        
    }
    
    func setupPlayer(){
        
        let playerViewController = AVPlayerViewControllerManager.shared.controller
        playerViewController.view.frame = playerContainer.bounds
        addChild(playerViewController)
        playerContainer.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
        
    }
    
     func playBtnPress(sender:UIButton){
        
        AVPlayerViewControllerManager.shared.controller.player?.play()
        
    }
    
    @IBAction func nextBtnPress(){

        if listVideo.count - 1  > currentPlayIndex {
            currentPlayIndex += 1
            tableView.selectRow(at: IndexPath(row: currentPlayIndex, section: 0), animated: true, scrollPosition: .middle)
            do{
                let video =  try JSONDecoder().decode(Video.self, from: listVideo[currentPlayIndex])
                getStreamingLink(video.url, .play)
            }catch{
                print(error.localizedDescription)

            }
        }
        
        
    }
    
    @IBAction func stopBtnPress(){

        AVPlayerViewControllerManager.shared.player?.pause()
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            listVideo.remove(at: indexPath.row)
            VideoCache.deleteData(index: indexPath.row, type: .playing)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if currentPlayIndex >= indexPath.row{
                currentPlayIndex -= 1
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentPlayIndex = indexPath.row
        do{
            let video =  try JSONDecoder().decode(Video.self, from: listVideo[indexPath.row])
            getStreamingLink(video.url, .play)
        }catch{
            print(error.localizedDescription)
            
        }
        
    }
    
}
