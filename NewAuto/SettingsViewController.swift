//
//  SettingsViewController.swift
//  NewAuto
//
//  Created by Johnson Zhou on 22/10/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController, NSTextFieldDelegate {

    
    var delegate: SettingsDelegate!
    @IBOutlet weak var numField: NSTextField!
    @IBOutlet weak var pwField: NSSecureTextField!
    
    var num: String!
    var pw: String!
    var auto: Bool!
    
    
    
    @IBAction func saveAction(_ sender: NSButton) {
        delegate.username = numField.stringValue
        delegate.password = pwField.stringValue
        switch AutoStartButton.state {
        case .on: delegate.autoStart = true
        case .off: delegate.autoStart = false
        default:
            break
        }
        delegate.save()
        pwField.delegate = self
        dismiss(self)
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        dismiss(self)
    }
    
    @IBOutlet weak var AutoStartButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        numField.stringValue = num
        pwField.stringValue = pw
        switch auto {
        case true:
            AutoStartButton.state = .on
        case false:
            AutoStartButton.state = .off
        default:
            break
        }
    }
    
}
