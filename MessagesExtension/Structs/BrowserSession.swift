//
//  BrowserSession.swift
//  MonkeySee Browser
//
//  Created by Robert Cash on 9/5/16.
//  Copyright © 2016 Robert Cash. All rights reserved.
//

import Foundation
import UIKit


struct BrowserSession {
    
    var currentWebsite: String?
    var browserSnapshot: UIImage?
    var new: Bool?
    
    init(){
        currentWebsite = "https://google.com"
        new = true
    }
    
    init(website: String){
        currentWebsite = website
        new = false
    }
    
    mutating func snapBrowser(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.browserSnapshot = image
    }
}
