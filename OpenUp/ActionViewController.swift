//
//  ActionViewController.swift
//  OpenUp
//
//  Created by LeDo on 2/1/20.
//  Copyright © 2020 LeDo. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var lbUrl: UILabel!
    var urlStr = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var lbUrlWeak = self.lbUrl
                    provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (result, error) in
                        if let text = result as? String, let strongUrl = lbUrlWeak {
                            self.urlStr = text
                            strongUrl.text = text
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }
    
    @IBAction func cancel(){
        self.extensionContext?.cancelRequest(withError:NSError(domain: "com.domain.name", code: 0, userInfo: nil))
    }

    @IBAction func play() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
//        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
//        self.extensionContext?.open(URL(string: "mvplanner:")!, completionHandler: nil)
        let success = openURL(URL(string: "shareUrl://\(self.urlStr)")!)
        print(success)
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)

    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

}
