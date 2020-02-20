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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setDataCell(data: Data){
        
        do{
            let video =  try JSONDecoder().decode(Video.self, from: data)
            print(video.title)
            
            lbTitle.text = video.title

            imgThumb.kf.setImage(with: URL(string: video.thumbUrl),
                                 options: [.transition(ImageTransition.fade(0.5)), .forceTransition])
            
        }catch{
            print(error.localizedDescription)

        }
        
    }
    
}
