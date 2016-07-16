//
//  Entry.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import Foundation
import MapKit

class Entry: NSObject, MKAnnotation, NSCoding, Comparable {
    
    var ID: NSUUID
    var title: String?
    var subtitle: String? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        return formatter.stringFromDate(date)
    }
    
    var notes: String
    var date: NSDate
    var photo: UIImage? {
        didSet {
            if let photo = photo {
                if photo.size.height < photo.size.width {
                    let ratio = 264 / photo.size.height
                    self.photo = photo.scaled(to: CGSize(width: photo.size.width * ratio, height: photo.size.height * ratio))
                } else {
                    let ratio = 264 / photo.size.width
                    self.photo = photo.scaled(to: CGSize(width: photo.size.width * ratio, height: photo.size.height * ratio))
                }
            }
        }
    }
    
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, notes: String?, date: NSDate?, coordinate: CLLocationCoordinate2D, photo: UIImage?) {
        self.ID = NSUUID()
        self.title = title ?? "Untitled"
        self.notes = notes ?? ""
        self.date = date ?? NSDate()
        self.coordinate = coordinate
        self.photo = photo
    }
    
    required init?(coder: NSCoder) {
        ID = coder.decodeObjectForKey("ID") as? NSUUID ?? NSUUID()
        title = coder.decodeObjectForKey("title") as? String ?? "Untitled"
        notes = coder.decodeObjectForKey("notes") as? String ?? ""
        photo = coder.decodeObjectForKey("photo") as? UIImage
        date = coder.decodeObjectForKey("date") as? NSDate ?? NSDate()
        
        coordinate = CLLocationCoordinate2D(
            latitude: coder.decodeObjectForKey("latitude") as? CLLocationDegrees ?? 0,
            longitude: coder.decodeObjectForKey("longitude") as? CLLocationDegrees ?? 0
        )
        
        if self.title!.isEmpty {
            self.title = "Untitled"
        }
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(ID, forKey: "ID")
        coder.encodeObject(title, forKey: "title")
        coder.encodeObject(notes, forKey: "notes")
        coder.encodeObject(date, forKey: "date")
        coder.encodeObject(photo, forKey: "photo")
        coder.encodeObject(coordinate.latitude, forKey: "latitude")
        coder.encodeObject(coordinate.longitude, forKey: "longitude")
    }
}

// Equate two entries by their IDs.
func ==(a: Entry, b: Entry) -> Bool {
    return  a.ID == b.ID
}

// Compare two entries by their dates. Earlier dates constitute "lesser" entries.
func <(a: Entry, b: Entry) -> Bool {
    return a.date.compare(b.date) == .OrderedAscending
}
