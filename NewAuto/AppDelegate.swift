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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
        let windows = NSApplication.shared.windows
        windows.last?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let launcherAppId = "JZ.Launcher"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        var autoStart: Bool!
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("wireless-signal"))
            button.action = #selector(printQuote(_:))
        }
        
        if Storage.fileExists("info.json", in: .documents) {
            if let user =  Storage.retrieve("info.json", from: .documents, as: UserInfo.self) {
                autoStart = user.autoStart
            } else {
                autoStart = false
            }
            
        } else {
            autoStart = false
        }
        
        SMLoginItemSetEnabled(launcherAppId as CFString, autoStart)
        UserDefaults.standard.set("\(autoStart)", forKey: "appLoginStart")

        
        if isRunning {
            print("Is Running")
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            let windows = sender.windows
            sender.windows.last?.makeKeyAndOrderFront(self)
            return true
        }
    }

}

extension AppDelegate {
    
    
}

