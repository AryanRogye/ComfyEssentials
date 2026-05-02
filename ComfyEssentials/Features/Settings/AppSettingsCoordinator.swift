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
    
    init(windowCoordinator: WindowCoordinator) {
        self.windowCoordinator = windowCoordinator
    }
    
    let windowID = UUID().uuidString
    
    public func show() {
        windowCoordinator.showWindow(
            id: windowID,
            title: "ComfyEssentials Settings",
            content: ComfyEssentialsSettings()
        )
    }
}
