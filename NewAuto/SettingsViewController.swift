//
//  SettingsViewController.swift
//  NewAuto
//
//  Created by Johnson Zhou on 22/10/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    
    var delegate: SettingsDelegate!
    @IBOutlet weak var numField: NSTextField!
    @IBOutlet weak var pwField: NSSecureTextField!
    
    var num: String!
    var pw: String!
    
    @IBAction func saveAction(_ sender: NSButton) {
        delegate.username = numField.stringValue
        delegate.password = pwField.stringValue
        dismiss(self)
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        dismiss(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        numField.stringValue = num
        pwField.stringValue = pw
    }
    
}
