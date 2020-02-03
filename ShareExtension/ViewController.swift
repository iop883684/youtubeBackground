//
//  ViewController.swift
//  ShareExtension
//
//  Created by LeDo on 2/1/20.
//  Copyright © 2020 LeDo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    @IBAction func share(){
        
//        let text = "Hay"
        let homePage = "https://iop883684.github.io/cinemaplan/"
//        let url = URL(string:homePage)!
        
        let vc = UIActivityViewController(activityItems: [homePage], applicationActivities: [])
        present(vc, animated: true, completion: nil)
        
    }

}

