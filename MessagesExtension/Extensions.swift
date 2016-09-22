//
//  Extensions.swift
//  MonkeySee Browser
//
//  Created by Robert Cash on 9/5/16.
//  Copyright © 2016 Robert Cash. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    
    var browserSession: BrowserSession {
        return BrowserSession(website:self.absoluteString)
    }
    
}

extension String {
    
    var toUrl: URL {
        return URL(string: self)!
    }
    
    var localized: String {
        return NSLocalizedString(self, comment:"")
    }
    
}

