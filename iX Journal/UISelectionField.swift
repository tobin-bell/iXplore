//
//  UISelectionField.swift
//
//  Created by Tobin Bell on 7/9/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import UIKit

class UISelectionField: UITextField, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var picker: UIPickerView!
    
    var options: [String] = [] {
        didSet {
            picker?.reloadAllComponents()
            text = options.first ?? ""
        }
    }
    
    override var text: String? {
        didSet {
            picker?.selectRow(options.indexOf(text ?? "") ?? 0, inComponent: 0, animated: false)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 0))
        
        if picker == nil {
            picker = UIPickerView()
            picker.selectRow(options.indexOf(text ?? "") ?? 0, inComponent: 0, animated: false)
            
            let pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(closePicker))
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            pickerToolbar.setItems([spacer, doneButton], animated: false)
            
            picker.dataSource = self
            picker.delegate = self
            
            inputView = picker
            inputAccessoryView = pickerToolbar
            
            // Hide the cursor.
            tintColor = .clearColor()
        }
    }
    
    func closePicker() {
        resignFirstResponder()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        text = options[row]
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let chevronHeight: CGFloat = 8
        let chevronInset: CGFloat = 12
        
        let centerY = frame.height / 2
        let topY = centerY - chevronHeight / 2
        let bottomY = centerY + chevronHeight / 2
        
        let leftX = chevronInset
        let centerX = leftX + chevronHeight
        let rightX = centerX + chevronHeight
        
        let indicatorPath = UIBezierPath()
        indicatorPath.moveToPoint(CGPoint(x: leftX + 1, y: topY))
        indicatorPath.addLineToPoint(CGPoint(x: leftX, y: topY + 1))
        indicatorPath.addLineToPoint(CGPoint(x: centerX, y: bottomY))
        indicatorPath.addLineToPoint(CGPoint(x: rightX, y: topY + 1))
        indicatorPath.addLineToPoint(CGPoint(x: rightX - 1, y: topY))
        indicatorPath.addLineToPoint(CGPoint(x: centerX, y: bottomY - 2))
        indicatorPath.closePath()
        
        UIColor.lightGrayColor().setFill()
        indicatorPath.fill()
    }
}
