//
//  UIView.swift
//  iXplore
//
//  Created by Tobin Bell on 7/12/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit

extension UIView {
    
    func addOverlay() -> UIView {
        endEditing(true)
        userInteractionEnabled = false
        
        let overlay = UIView(frame: bounds)
        overlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        addSubview(overlay)
        
        let spinner = UIActivityIndicatorView(frame: overlay.bounds)
        spinner.activityIndicatorViewStyle = .WhiteLarge
        spinner.startAnimating()
        overlay.addSubview(spinner)
        
        return overlay
    }
    
    func removeOverlay(overlay: UIView) {
        userInteractionEnabled = true
        overlay.removeFromSuperview()
    }
    
}