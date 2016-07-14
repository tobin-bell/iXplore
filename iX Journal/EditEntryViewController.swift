//
//  EditEntryViewController.swift
//  iX Journal
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
    
    var entry: Entry!
    var delegate: EditEntryViewControllerDelegate?
    
    var notesFieldOriginalHeight: CGFloat!
    
    // MARK: Life Cycle
    
    // If an entry object was given to us, set our initial values based on that.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if entry != nil {
            
            // Populate the static fields with the entry's information.
            titleField.text = entry.title
            dateField.date = entry.date
            photoImage.image = entry.photo
            notesField.text = entry.notes
            coordinate = entry.coordinate
            
            // For the location, we use our geocoder to begin the lookup.
            // If it cannot be resolved, simply mark it as "Unknown".
            locationLabel.text = "..."
            let location = CLLocation(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    self.locationLabel.textColor = .blackColor()
                    self.locationLabel.text = placemark.name
                } else {
                    self.locationLabel.text = "Unknown"
                }
            }
        }
    }
    
    // Perform various UI configurations relating to the keyboard.
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Focus the title field.
        titleField.becomeFirstResponder()
        
        // Register for keyboard hiding and showing notifications.
        // This allows us to adjust the height of the notes field when the keyboard is visible.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: view.window)
        
        // Record the notes field's starting height so we can restore it upon keyboard hiding.
        notesFieldOriginalHeight = notesField.frame.size.height
    }
    
    // MARK: Notification Handlers
    
    // When the keyboard shows, shorten the notes field by the height of the keyboard.
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        if let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.CGRectValue().size.height
            notesField.frame.size.height = notesFieldOriginalHeight - keyboardHeight
        }
    }
    
    // When the keyboard hides, restore the notes field's height to its original value.
    func keyboardWillHide(notification: NSNotification) {
        notesField.frame.size.height = notesFieldOriginalHeight
    }
    
    // MARK: IBActions
    
    // When the title field returns, focus the date field.
    @IBAction func titleFieldReturned(sender: UITextField) {
        dateField.becomeFirstResponder()
    }
    
    // When the cancel button is pressed, close all keyboards and return to wherever we came from.
    @IBAction func cancelButtonPressed(sender: UIButton) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Save or update an entry.
    // When the save button is pressed, determine whether or not we are editing or creating an entry.
    // This is determined by whether or not an entry object was given to us by our presenting view controller.
    @IBAction func saveButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        // Validation. The user must set his or her location.
        guard let coordinate = coordinate else {
            alert(title: "No Location", message: "You cannot save an entry without a location.")
            return
        }
        
        // If we have an entry object, we are updating it, rather than creating a new one.
        // Update its fields and notify our delegate.
        if entry != nil {
            
            entry.title = titleField.text
            entry.date = dateField.date
            entry.coordinate = coordinate
            entry.photo = photoImage.image
            entry.notes = notesField.text
            delegate?.updated(entry, from: self)

        } else {
            
            // If the entry property was nil, then we are creating a new entry.
            // Initialize it and notify our delegate.
            let entry = Entry(title: titleField.text!,
                              notes: notesField.text!,
                              date: dateField.date,
                              coordinate: coordinate,
                              photo: photoImage.image)
            delegate?.added(entry, from: self)
        }
        
        // Either way, return to whever we came from.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // When the camera button is pressed, allow the user to select from either the camera or their photo library.
    // Additionally, provide the option of removing the photo completely if one is already set.
    @IBAction func cameraButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        // Create an image picker controller to handle the interaction.
        let picker = UIImagePickerController()
        picker.delegate = self
        
        // Create an alert controller, offering to either take a picture or choose an existing one.
        let alert = UIAlertController(title: nil,
                                      message: "Would you like to take a photo with the camera, or select an existing photo from your photo library?",
                                      preferredStyle: .ActionSheet)
        
        // If we have a photo in the photo view, offer an option to remove it.
        if photoImage.image != nil {
            alert.addAction(UIAlertAction(title: "Remove Photo", style: .Destructive) { action in
                self.photoImage.image = nil
            })
        }
        
        // Always create an alert action option to choose the camera.
        // However, selectively disable it if a camera is not actually available on the device.
        let camera = UIAlertAction(title: "Camera", style: .Default) { action in
            picker.sourceType = .Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
        camera.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        alert.addAction(camera)
        
        // The photo library will always exist, so we can safely add an option for it.
        alert.addAction(UIAlertAction(title: "Photo Library", style: .Default) { action in
            picker.sourceType = .PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        // Present the options alert.
        // (Not the image picker, which will be indirectly presented by the various alert actions.)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // When the location button is pressed, verify that the user has not previously denied our access to location services.
    // If they have, provide a helpful alert allowing them to switch to Settings to re-enable it.
    // Otherwise, start listening for their location.
    @IBAction func locationButtonPressed(sender: UIButton) {
        view.endEditing(true)
        
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied || status == .Restricted {
            
            locationLabel.text = "Unavailable"
            locationLabel.textColor = UIColor.lightGrayColor()
            
            let alert = UIAlertController(title: "Location Unavailable",
                                          message: "In order to set your location, you must allow iX Journal access to your location from within Settings.",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Open Settings", style: .Default) { action in
                let settings = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(settings)
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
    
    // MARK: Image Picker Controller Delegate
    
    // When an image is chosen, update the photoImage field to match, and close the picker.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        photoImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Location Manager Delegate
    
    // If the user does not authorize a request for their location, update the feedback in the location label.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .Denied || status == .Restricted {
            locationLabel.text = "Unavailable"
            locationLabel.textColor = UIColor.lightGrayColor()
        } else {
            locationLabel.text = "Locating..."
        }
    }
    
    // When we recieve a location update, stop listening to the location.
    // We also perform a geocode reverse lookup to turn the coordinates into a user friendly name for the location label.
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
