//
//  UIColor.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/13/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
    
    static var charcoal: UIColor {
        return UIColor(red: 43, green: 62, blue: 66)
    }
    
    static var cream: UIColor {
        return UIColor(red: 247, green: 243, blue: 232)
    }
    
    static var scarlet: UIColor {
        return UIColor(red: 242, green: 88, blue: 62)
    }
    
    static var sky: UIColor {
        return UIColor(red: 119, green: 190, blue: 210)
    }
    
}