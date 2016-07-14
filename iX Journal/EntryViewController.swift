//
//  EntryViewController.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/14/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit
import CoreLocation

class EntryViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    var entry: Entry!
    var delegate: EditEntryViewControllerDelegate?
    
    let geocoder = CLGeocoder()
    
    // MARK: Life Cycle
    
    // When the view loads, verify that our presenting view controller gave us an entry to display.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure an entry was given to us.
        if entry == nil {
            navigationController?.popViewControllerAnimated(true)
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    // Each time the view is about to appear, populate the UI with data from the entry model.
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a date formatter for displaying the entry's date.
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        
        // Populate the static fields with relevant information.
        titleLabel.text = entry.title
        dateLabel.text = formatter.stringFromDate(entry.date)
        photoImage.image = entry.photo
        notesLabel.text = entry.notes
        
        // For the location, we use our geocoder to begin the lookup.
        // If it cannot be resolved, simply mark it as "Unknown".
        let location = CLLocation(latitude: entry.coordinate.latitude, longitude: entry.coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first?.name {
                self.locationLabel.text = "@ \(place)"
            } else {
                self.locationLabel.text = "Unknown"
            }
        }
    }
    
    // MARK: Navigation
    
    // Before we transition to the edit controller, set its delegate and entry properties to mirror our own.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let editController = segue.destinationViewController as? EditEntryViewController {
            editController.entry = entry
            editController.delegate = delegate
        }
    }
}
