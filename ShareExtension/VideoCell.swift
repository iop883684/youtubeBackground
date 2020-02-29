//
//  VideoCell.swift
//  ShareExtension
//
//  Created by LeDo on 2/21/20.
//  Copyright © 2020 LeDo. All rights reserved.
//


import UIKit
import Kingfisher

class VideoCell: UITableViewCell {
    
    @IBOutlet var lbTitle:UILabel!
    @IBOutlet var imgThumb:UIImageView!
    @IBOutlet var lbTime:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDataCell(data: Data){
        
        do{
            let video =  try JSONDecoder().decode(Video.self, from: data)
            lbTitle.text = video.title
            lbTime.text = stringFromTimeInterval(interval: video.duration)
            imgThumb.kf.setImage(with: URL(string: video.thumbUrl),
                                 options: [.transition(ImageTransition.fade(0.5)), .forceTransition])
            
        }catch{
            print(error.localizedDescription)

        }
        
    }
    
    func stringFromTimeInterval(interval: Int) -> String {

        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: " %02d:%02d ", minutes, seconds)
    }
    
}
