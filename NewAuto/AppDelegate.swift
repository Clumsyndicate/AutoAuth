//
//  AppDelegate.swift
//  NewAuto
//
//  Created by Johnson Zhou on 18/10/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa
import ServiceManagement
import Sparkle

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

protocol statusDelegate {
    func showConnectionStatus(connection: Bool)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem? = nil
    
    @objc func printQuote(_ sender: Any?) {
        
        let windows = NSApplication.shared.windows
        windows.last?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    var username: String!
    var psword: String!
    var showStatus: Bool!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let launcherAppId = "JZ.Launcher"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        var autoStart: Bool!
        
        if let button = statusItem?.button {
            // button.image = NSImage(named:NSImage.Name("wireless-signal"))
            button.action = #selector(printQuote(_:))
        }
        
        
        
        if Storage.fileExists("info.json", in: .documents) {
            if let user =  Storage.retrieve("info.json", from: .documents, as: UserInfo.self) {
                username = user.name
                psword = user.psword
                autoStart = user.autoStart
                showStatus = user.showStatus
            } else {
                username = ""
                psword = ""
                autoStart = false
                showStatus = true
            }
            
        } else {
            username = ""
            psword = ""
            autoStart = false
            showStatus = true
        }
        
        SMLoginItemSetEnabled(launcherAppId as CFString, autoStart)
        UserDefaults.standard.set("\(autoStart)", forKey: "appLoginStart")

        
        if isRunning {
            print("Is Running")
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
        
        if showStatus {
            menuSetup()
        }
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func toggle() {
        /*guard let vc = NSApplication.shared.windows.first?.contentViewController as? ViewController else {
            fatalError("could not get vc")
        } */
        // vc.tryConnect()
        connect()
    }
    
    func connect() {
        let process = Process()
        // process.launchPath = "/usr/bin/python"
        print(Bundle.main.resourcePath!)
        guard let path = Bundle.main.path(forResource: "auth", ofType: nil, inDirectory: "auth") else {
            print("Unable to locate executable auth file")
            return
        }
        process.arguments = [self.username, self.psword]
        process.launchPath = path
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        // Launch the task
        process.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        if let string = output, string.range(of: "It works!") != nil {
            statusItem?.button?.image = NSImage(named:NSImage.Name("Connected"))

        } else {
            statusItem?.button?.image = NSImage(named: NSImage.Name("Disconnected"))
        }
        
    }
    
    func menuSetup() {
        statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        let menu = NSMenu()
        let status = NSMenuItem()
        status.title = "Disconnected"
        status.tag = 0
        menu.addItem(status)
        menu.addItem(NSMenuItem.separator())
        // let connectItem = NSMenuItem(title: "Connect", action: #selector((NSApplication.shared.windows.first?.contentViewController as? ViewController)?.tryConnect), keyEquivalent: "R")
        let connectItem = NSMenuItem(title: "Connect", action: #selector(toggle), keyEquivalent: "R")
        connectItem.tag = 1
        menu.addItem(connectItem)
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit NewAuto", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.tag = 2
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    func tryConnect() {
        
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            sender.windows.filter({ return ($0 as? NSWindow) != nil}).first?.makeKeyAndOrderFront(self)
            return true
        }
    }

}
