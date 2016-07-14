//
//  AddEntryViewController.swift
//  iXplore
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit
import CoreLocation

class EditEntryViewController: UIViewController,
    CLLocationManagerDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UIDateField!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesField: UITextView!
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var coordinate: CLLocationCoordinate2D?
    
    var delegate: EntryViewControllerDelegate?
    
    var notesFieldOriginalHeight: CGFloat!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        notesFieldOriginalHeight = notesField.frame.size.height
        
        titleField.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: view.window)
    }
    
    @IBAction func titleFieldReturned(sender: UITextField) {
        dateField.becomeFirstResponder()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        if let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.CGRectValue().size.height
            notesField.frame.size.height = notesFieldOriginalHeight - keyboardHeight
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        notesField.frame.size.height = notesFieldOriginalHeight
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        guard let coordinate = coordinate else {
            alert(title: "No Location", message: "You cannot save an entry without a location.")
            return
        }
        
        let entry = Entry(title: titleField.text!,
                          notes: notesField.text!,
                          date: dateField.date,
                          coordinate: coordinate)
        
        entry.photo = photoImage.image
        
        delegate?.added(entry, from: self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let alert = UIAlertController(title: nil,
                                      message: "Would you like to take a photo with the camera, or select an existing photo from your photo library?",
                                      preferredStyle: .ActionSheet)
        
        if photoImage.image != nil {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .Destructive) { action in
                self.photoImage.image = nil
            })
        }
        
        let camera = UIAlertAction(title: "Camera", style: .Default) { action in
            picker.sourceType = .Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
        camera.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        alert.addAction(camera)
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .Default) { action in
            picker.sourceType = .PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func locationButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied || status == .Restricted {
            locationLabel.text = "Unavailable"
            locationLabel.textColor = UIColor.lightGrayColor()
            
            let alert = UIAlertController(title: "Location Unavailable",
                                          message: "In order to set your location, you must allow iXplore access to your location from within Settings.",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Open Settings", style: .Default) { action in
                if let settings = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(settings)
                }
            })
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            locationLabel.text = "Locating..."
            locationLabel.textColor = UIColor.lightGrayColor()
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = 0
        locationManager.startUpdatingLocation()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        photoImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            locationLabel.text = "Unavailable"
            locationLabel.textColor = UIColor.lightGrayColor()
        } else {
            locationLabel.text = ""
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        coordinate = locations.last!.coordinate
        
        geocoder.reverseGeocodeLocation(locations.last!) { placemarks, error in
            if let placemark = placemarks?.first {
                self.locationLabel.text = placemark.name
                self.locationLabel.textColor = UIColor.blackColor()
            } else {
                self.alert(title: "Location Unavailable", message: "There was a problem getting your location.")
            }
        }
    }

}
