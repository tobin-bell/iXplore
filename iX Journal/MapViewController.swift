//
//  MapViewController.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, EditEntryViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var entries = [Entry]()
    
    var accessoryTappedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the persistent entries. (This view should only load once).
        restore()
        mapView.addAnnotations(entries)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let entry = entries.first {
            mapView.region = MKCoordinateRegion(center: entry.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
    }
    
    // MARK: IBActions
    
    // When the location button on the navigation bar is pressed, scroll to the user's location.
    @IBAction func locationButtonPressed(sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        let userLocation = mapView.userLocation
        mapView.setCenterCoordinate(userLocation.coordinate, animated: true)
    }
    
    
    // MARK: Table View Data Source
    
    // One row per journal entry.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entry = entries[indexPath.row]
        let identifer = entry.photo != nil ? "PhotoEntryCell" : "EntryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifer, forIndexPath: indexPath) as! EntryCell
        cell.title = entry.title ?? "Untitled"
        cell.subtitle = entry.subtitle!
        cell.photo = entry.photo
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let entry = entries.removeAtIndex(indexPath.row)
            unsave(entry)
            mapView.removeAnnotation(entry)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: Table View Delegate
    
    // When a row is tapped, pan the map to its matching annotation.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mapView.setCenterCoordinate(entries[indexPath.row].coordinate, animated: true)
        mapView.selectAnnotation(entries[indexPath.row], animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // When the info button is tapped for a row, open the details for that entry.
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        accessoryTappedRow = indexPath.row
        performSegueWithIdentifier("EntrySegue", sender: tableView)
    }
    
    // MARK: Map View Delegate
    
    // Create scarlet pin annotations for our entries, and enable callouts.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // If this is the user location annotation, return nil to avoid overriding the default.
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        // Attempt to reuse a pin from the map.
        guard let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("EntryPin") else {
            
            // No reusable pin was available, create a new one and configure it appropriately.
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "EntryPin")
            annotationView.pinTintColor = .scarlet
            annotationView.canShowCallout = true
            return annotationView
        }
        
        // Replace the reusable pin's old annotation with the correct one.
        annotationView.annotation = annotation
        return annotationView
    }
    
    // MARK: Entry View Controller Delegate
    
    func added(entry: Entry, from addEntryViewController: EditEntryViewController) {
        var min = 0, max = entries.count - 1
        while min < max {
            let mid = (min + max) / 2
            if entry < entries[mid] {
                min = mid + 1
            } else if entries[mid] < entry {
                max = mid - 1
            } else {
                min = mid
                break
            }
        }
        
        save(entry)
        
        mapView.addAnnotation(entry)
        entries.insert(entry, atIndex: min)
        let indexPath = NSIndexPath(forRow: min, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    // When the Edit Entry controller updates an entry, re-save (overwrite) it and reload its row in the table view.
    func updated(entry: Entry, from addEntryViewController: EditEntryViewController) {
        save(entry)
        if let index = entries.indexOf(entry) {
            let path = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([path], withRowAnimation: .Fade)
        }
    }
    
    // MARK: Navigation
    
    // When we transition to the Edit Entry view controller, become its delegate.
    // When we transition to view an entry, become its delegate and set the entry object to be displayed.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? EditEntryViewController {
            controller.delegate = self
        }
        
        if let controller = segue.destinationViewController as? EntryViewController {
            if let row = accessoryTappedRow {
                controller.entry = entries[row]
                controller.delegate = self
                accessoryTappedRow = nil
            }
        }
    }
    
    // MARK: Persistence
    
    // Save (or update/overwrite) an entry to the persistent store.
    func save(entry: Entry) {
        
        // Entries are stored by their UUID string within the Documents directory.
        // Construct a URL to the entry to be saved by appending its UUID to the Documents directory URL.
        let documents = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let file = documents.URLByAppendingPathComponent(entry.ID.UUIDString)
        
        NSKeyedArchiver.archiveRootObject(entry, toFile: file.path!)
    }
    
    // Delete an entry from the persistent store.
    func unsave(entry: Entry) {
        
        // Entries are stored by their UUID string within the Documents directory.
        // Construct a URL to the entry to be deleted by appending its UUID to the Documents directory URL.
        let manager = NSFileManager.defaultManager()
        let documents = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let file = documents.URLByAppendingPathComponent(entry.ID.UUIDString)
        
        do {
            try manager.removeItemAtURL(file)
        } catch {}
    }
    
    // Load existing entries from the persistent store into the entries array.
    func restore() {
        
        // Entries are stored by their UUID string within the Documents directory.
        // Consturct a URL to the Documents directory.
        let manager = NSFileManager.defaultManager()
        let documents = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        do {
            // Loop over the Documents directory contents and unarchive each entry individually.
            let files = try manager.contentsOfDirectoryAtURL(documents, includingPropertiesForKeys: [], options: [])
            for file in files {
                if let entry = NSKeyedUnarchiver.unarchiveObjectWithFile(file.path!) as? Entry {
                    entries.append(entry)
                }
            }
            
            // Sort the array chronologically descending.
            entries = entries.sort().reverse()
        } catch {}
    }
}

