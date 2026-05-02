//
//  AppSettingsCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/2/26.
//

import AppKit

@MainActor
final class AppSettingsCoordinator {
    let windowCoordinator : WindowCoordinator
    var appSettings       : AppSettings
    
    init(windowCoordinator: WindowCoordinator, appSettings: AppSettings) {
        self.windowCoordinator = windowCoordinator
        self.appSettings       = appSettings
    }
    
    let windowID = UUID().uuidString
    
    public func show() {
        windowCoordinator.showWindow(
            id: windowID,
            title: "ComfyEssentials Settings",
            content: ComfyEssentialsSettings(appSettings: appSettings),
            makeGlass: true
        )
    }
}
