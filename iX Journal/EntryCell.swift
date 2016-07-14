//
//  EntryCell.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit

class EntryCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var photoView: UIImageView!
    
    var title: String {
        get {
            return titleLabel.text!
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var subtitle: String {
        get {
            return subtitleLabel.text!
        }
        set {
            subtitleLabel.text = newValue
        }
    }
    
    var photo: UIImage? {
        get {
            return photoView.image!
        }
        set {
            photoView.image = newValue
        }
    }

}
