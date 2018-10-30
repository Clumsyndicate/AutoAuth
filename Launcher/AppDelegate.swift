//
//  AppDelegate.swift
//  Launcher
//
//  Created by Johnson Zhou on 25/10/2018.
//  Copyright © 2018 Johnson Zhou. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // @IBOutlet weak var window: NSWindow!


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    

    @objc func terminate() {
        NSApp.terminate(nil)
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let mainAppIdentifier = "JZ.NewAuto"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty
        
        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self,
                                                                selector: #selector(self.terminate),
                                                                name: .killLauncher,
                                                                object: mainAppIdentifier)
            
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            for _ in 1...4 {
                components.removeLast()
            }
            
            let newPath = NSString.path(withComponents: components)
            
            print(NSWorkspace.shared.launchApplication(newPath))
        }
        else {
            print("Terminated")
            self.terminate()
        }
    }
    
}

