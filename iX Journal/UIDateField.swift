//
//  UIDateField.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import UIKit

class UIDateField: UITextField {
    
    var datePicker = UIDatePicker()
    
    var date: NSDate {
        get {
            return datePicker.date
        }
        set(newDate) {
            datePicker.date = newDate
            formatDateText()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let datePickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(closeDatePicker))
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        datePickerToolbar.setItems([spacer, doneButton], animated: false)
        
        doneButton.tintColor = tintColor
        
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(formatDateText), forControlEvents: .ValueChanged)
        
        inputView = datePicker
        inputAccessoryView = datePickerToolbar
        
        // Hide the cursor.
        tintColor = .clearColor()
    }
    
    func closeDatePicker() {
        formatDateText()
        resignFirstResponder()
    }
    
    func formatDateText() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        
        text = formatter.stringFromDate(datePicker.date)
    }
}