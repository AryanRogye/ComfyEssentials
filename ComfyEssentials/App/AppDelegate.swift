//
//  AppDelegate.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var appSettings = AppSettings()
    let appCoordinator : AppCoordinator
    
    @MainActor
    override init() {
        NSApp.setActivationPolicy(.accessory)
        self.appCoordinator = AppCoordinator(appSettings: appSettings)
        super.init()
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        appCoordinator.start()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        appCoordinator.showMainWindow()
        return true
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
