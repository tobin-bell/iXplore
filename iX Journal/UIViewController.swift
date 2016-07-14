//
//  UIViewController.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alert(title title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}