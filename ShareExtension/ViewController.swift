//
//  ViewController.swift
//  ShareExtension
//
//  Created by LeDo on 2/1/20.
//  Copyright © 2020 LeDo. All rights reserved.
//

import UIKit
import YoutubePlayerView

class ViewController: UIViewController {
    
    @IBOutlet var playerView:YoutubePlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let playerVars: [String: Any] = [
            "controls": 1,
            "modestbranding": 1,
            "playsinline": 1,
            "rel": 0,
            "showinfo": 0,
            "autoplay": 1
        ]
        playerView.loadWithVideoId("hfFCAUM7gnc", with: playerVars)
//        self.playerView.loadWithVideoId("hfFCAUM7gnc")
        self.playerView.delegate = self
        

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToBackground),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.playerView.play()
        }
    }
    


    @IBAction func share(){
        
//        let text = "Hay"
        let homePage = "https://iop883684.github.io/cinemaplan/"
//        let url = URL(string:homePage)!
        
        let vc = UIActivityViewController(activityItems: [homePage], applicationActivities: [])
        present(vc, animated: true, completion: nil)
        
    }

}

extension ViewController: YoutubePlayerViewDelegate{
    
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        
        print(state.rawValue)
        switch (state) {
        case .playing:
            break;
        case .paused:
            break;
          default:
            break;
        }
    }
    
}
