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
    var status: Bool!
    
    
    @IBOutlet weak var saveBtn: NSButton!
    
    @IBAction func saveAction(_ sender: NSButton) {
        delegate.username = numField.stringValue
        delegate.password = pwField.stringValue
        switch AutoStartButton.state {
        case .on: delegate.autoStart = true
        case .off: delegate.autoStart = false
        default:
            break
        }
        switch showStatusButton.state {
        case .on: delegate.statusBar = true
        case .off: delegate.statusBar = false
        default:
            break
        }
        
        delegate.save()
        
        dismiss(self)
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        dismiss(self)
    }
    
    @IBOutlet weak var AutoStartButton: NSButton!
    @IBOutlet weak var showStatusButton: NSButton!
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        return true
    }
    
    
    func controlTextDidEndEditing(_ obj: Notification) {
        saveAction(saveBtn)
    }
    
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
        switch status {
        case true:
            showStatusButton.state = .on
        case false:
            showStatusButton.state = .off
        default:
            break
        }
        
        // numField.delegate = self
        pwField.delegate = self
    }
    
}
