//
//  ViewController.swift
//  NewAuto
//
//  Created by Johnson Zhou on 18/10/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa

protocol SettingsDelegate {
    var username: String { get set }
    var password: String { get set }
}

class ViewController: NSViewController, SettingsDelegate {
    
    let reachability = Reachability()!

    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            debugPrint("Network became unreachable")
            substatusTextField.isHidden = false
            connectivityIcon.image = NSImage(named: "off")
            statusTextField.stringValue = "Not connected to Wifi"
            substatusTextField.stringValue = "Please Connect to Wifi"
            timer?.invalidate()
        case .wifi:
            debugPrint("Network reachable through WiFi")
            substatusTextField.isHidden = true
            tryConnect()
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(tryConnect), userInfo: nil, repeats: true)
            }
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onWakeNote(note:)),
            name: NSWorkspace.didWakeNotification, object: nil)
        /*
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onSleepNote(note:)),
            name: NSWorkspace.willSleepNotification, object: nil) */
    }
    
    @objc func onWakeNote(note: NSNotification) {
        tryConnect()
    }
    /*
    @objc func onSleepNote(note: NSNotification) {
        
    } */
    
    @IBOutlet weak var connectBtn: NSButton!
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var substatusTextField: NSTextField!
    @IBOutlet weak var connectivityIcon: NSImageView!
    
    @IBAction func connect(_ sender: NSButton) {
        if sender.title == "Connect" {
            connectBtn.title = "Connecting"
            statusTextField.stringValue = "Connecting"
            tryConnect()
        } else {
            connectBtn.title = "Connect"
            statusTextField.stringValue = "Disconnected"
        }
    }
    
    var username: String = "" {
        didSet {
            user.name = username
            save()
        }
    }
    var password: String = "" {
        didSet {
            user.psword = password
            save()
        }
    }
    
    fileprivate func save() {
        Storage.store(user, to: .documents, as: "info.json")
        tryConnect()
    }
    
    var user = UserInfo(name: "", psword: "")
    
    fileprivate func connectionStatus(connected: Bool) {
        if connected {
            connectivityIcon.image = NSImage(named: "on")
            connectBtn.stringValue = "Connected"
            connectBtn.isEnabled = false
            statusTextField.stringValue = "Connected"
            substatusTextField.stringValue = "Enjoy censored YKPao Internet!"
            substatusTextField.isHidden = false
        }
    }
    
    var timer: Timer?
    
    @objc fileprivate func tryConnect() {
        DispatchQueue.main.async {
            let process = Process()
            // process.launchPath = "/usr/bin/python"
            print(Bundle.main.resourcePath!)
            guard let path = Bundle.main.path(forResource: "auth", ofType: nil, inDirectory: "auth") else {
                print("Unable to locate executable auth file")
                return
            }
            process.arguments = [self.username, self.password]
            process.launchPath = path
            
            let pipe = Pipe()
            process.standardOutput = pipe
            
            // Launch the task
            process.launch()
            
            // Get the data
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            
            if let string = output, string.range(of: "It works!") != nil {
                self.connectionStatus(connected: true)
            } else {
                self.substatusTextField.stringValue = "Having trouble connecting. VPN on?"
                self.substatusTextField.isHidden = false
            }
            
            print(output!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        startMonitoring()
        
        if Storage.fileExists("info.json", in: .documents) {
            user =  Storage.retrieve("info.json", from: .documents, as: UserInfo.self)
            username = user.name
            password = user.psword
        } else {
        }
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(tryConnect), userInfo: nil, repeats: true)
    }
    
    

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            if let vc = segue.destinationController as? SettingsViewController {
                vc.delegate = self
                vc.num = username
                vc.pw = password
            }
        }
    }

}

