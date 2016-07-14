//
//  AddEntryViewControllerDelegate.swift
//  iXplore
//
//  Created by Tobin Bell on 7/11/16.
//  Copyright © 2016 iXperience. All rights reserved.
//

import Foundation

protocol EntryViewControllerDelegate {
    func added(entry: Entry, from addEntryViewController: AddEntryViewController)
    func updated(entry: Entry, from addEntryViewController: AddEntryViewController)
}