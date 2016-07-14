//
//  EntryViewControllerDelegate.swift
//  iX Journal
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import Foundation

protocol EditEntryViewControllerDelegate {
    func added(entry: Entry, from addEntryViewController: EditEntryViewController)
    func updated(entry: Entry, from addEntryViewController: EditEntryViewController)
}