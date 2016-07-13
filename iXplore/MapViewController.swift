//
//  MapViewController.swift
//  iXplore
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, EntryViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var entries: [Entry] = {
        
        let manager = NSFileManager.defaultManager()
        let documents = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        var entries = [Entry]()
        
        do {
            let files = try manager.contentsOfDirectoryAtURL(documents, includingPropertiesForKeys: [], options: [])
            
            
            for file in files {
                if let entry = NSKeyedUnarchiver.unarchiveObjectWithFile(file.path!) as? Entry {
                    entries.append(entry)
                }
            }
            entries.sortInPlace()
            entries = entries.reverse()
        } catch {
            print("Could not load entries")
        }
        
        return entries
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.tintColor = .sky
        mapView.addAnnotations(entries)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let entry = entries.first {
            mapView.region = MKCoordinateRegion(center: entry.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let photo = entries[indexPath.row].photo {
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotoEntryCell", forIndexPath: indexPath) as! EntryCell
            let entry = entries[indexPath.row]
            cell.title = entry.title ?? "Untitled"
            cell.subtitle = entry.subtitle!
            cell.photo = photo
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("EntryCell", forIndexPath: indexPath) as! EntryCell
            let entry = entries[indexPath.row]
            cell.title = entry.title ?? "Untitled"
            cell.subtitle = entry.subtitle!
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mapView.setCenterCoordinate(entries[indexPath.row].coordinate, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("EntryPin") else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "EntryPin")
            annotationView.pinTintColor = .scarlet
            annotationView.canShowCallout = true
            return annotationView
        }
        annotationView.annotation = annotation
        return annotationView
    }
    
    func added(entry: Entry, from addEntryViewController: AddEntryViewController) {
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
    
    func updated(entry: Entry, from addEntryViewController: AddEntryViewController) {
        if let index = entries.indexOf(entry) {
            let path = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([path], withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? AddEntryViewController {
            controller.delegate = self
        }
    }
    
    // MARK: Persistence
    
    func unsave(entry: Entry) {
        let manager = NSFileManager.defaultManager()
        let documents = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let file = documents.URLByAppendingPathComponent(entry.ID.UUIDString)
        
        do {
            try manager.removeItemAtURL(file)
        } catch {}
    }
    
    func save(entry: Entry) {
        let documents = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let file = documents.URLByAppendingPathComponent(entry.ID.UUIDString)
        NSKeyedArchiver.archiveRootObject(entry, toFile: file.path!)
    }
}

