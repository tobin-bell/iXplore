//
//  UIImage.swift
//  iXplore
//
//  Created by Tobin Bell on 7/12/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit

extension UIImage {
    
    func scaled(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
            
        return newImage
    }
    
}
