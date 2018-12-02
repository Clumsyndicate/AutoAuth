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
    var autoStart: Bool { get set }
    var statusBar: Bool { get set }
    func save()
}

class ViewController: NSViewController, SettingsDelegate {
    
    var appDelegate: AppDelegate!
    var autoStart: Bool = false
    var statusBar: Bool = true
    var statusMenu: Bool = true
    
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
            connectionStatus(connected: false)
            timer?.invalidate()
        case .wifi:
            debugPrint("Network reachable through WiFi")
            substatusTextField.isHidden = true
            tryConnect()
            addTimer()
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
        }
    }
    
    
    fileprivate func addTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(tryConnect), userInfo: nil, repeats: true)
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
        } else if sender.title == "Connected" {
            connectBtn.title = "Connect"
            statusTextField.stringValue = "Disconnected"
        } else {
            connectBtn.title = "Connecting"
            statusTextField.stringValue = "Connecting"
            tryConnect()
        }
    }
    
    var username: String = ""
    var password: String = "" 
    
    func save() {
        user.name = username
        user.psword = password
        user.autoStart = autoStart
        user.showStatus = statusBar
        
        Storage.store(user, to: .documents, as: "info.json")
        tryConnect()
    }
    func updateStatus() {
        if user.showStatus {
            
        }
    }
    
    var user = UserInfo(name: "", psword: "", autoStart: false, showStatus: true)
    
    func connectionStatus(connected: Bool) {
        if connected {
            appDelegate.statusItem?.button?.image = NSImage(named:NSImage.Name("Connected"))

            connectivityIcon.image = NSImage(named: "on")
            connectBtn.title = "Retry Connect"
            // connectBtn.isEnabled = false
            statusTextField.stringValue = "Connected"
            substatusTextField.stringValue = "Enjoy censored YKPao Internet!"
            substatusTextField.isHidden = false
        } else {
            appDelegate.statusItem?.button?.image = NSImage(named: NSImage.Name("Disconnected"))
            self.statusTextField.stringValue = "Attempting Connection"
            self.connectivityIcon.image = NSImage(named: "off")
            
            self.substatusTextField.stringValue = "Having trouble connecting. VPN on?"
            self.substatusTextField.isHidden = false
            self.connectBtn.title = "Connecting"
        }
    }
    
    var timer: Timer?
    
    func updateStatusBar(connecting: Int) {
        let menu = appDelegate.statusItem?.menu
        menu?.item(at: menu!.indexOfItem(withTag: 0))?.title = (connecting == 0) ? "Connected" : ((connecting == 1) ? "Connecting" : "Disconnected")
    }
    
    @objc func tryConnect() {
        DispatchQueue.main.async {
            /*
            self.updateStatusBar(connecting: 1)
            
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
                self.updateStatusBar(connecting: 0)
                self.connectionStatus(connected: true)
            } else {
                self.updateStatusBar(connecting: 2)
                self.connectionStatus(connected: false)
            }
            
            print(output!)
            */
            
            AutoAuth().connect(username: self.username, password: self.password)
            self.addTimer()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = NSApplication.shared.delegate as! AppDelegate

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
            addTimer()
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
        }
        
        startMonitoring()
        
        if Storage.fileExists("info.json", in: .documents) {
            if let user =  Storage.retrieve("info.json", from: .documents, as: UserInfo.self) {
                username = user.name
                password = user.psword
                autoStart = user.autoStart
                statusBar = user.showStatus
            }
        }
        
        addTimer()
        
        if username == "" && password == "" {
            firstTimeAlert()
        }
        
    }
    
    fileprivate func firstTimeAlert() {
        let alert = NSAlert()
        
        alert.messageText = "Please add your student # and password in the Settings. It will be stored and don't need to be entered again."
        alert.addButton(withTitle: "Got it")
        alert.runModal()
        
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            if let vc = segue.destinationController as? SettingsViewController {
                vc.delegate = self
                vc.num = username
                vc.pw = password
                vc.auto = autoStart
                vc.status = statusBar
            }
        }
    }

}

