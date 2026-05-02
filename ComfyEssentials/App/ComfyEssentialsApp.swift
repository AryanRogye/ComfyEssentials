//
//  ComfyEssentialsApp.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import SwiftUI
import AppKit

@main
struct ComfyEssentialsApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra(isInserted: Binding(
            get: { appDelegate.appSettings.showMenubar },
            set: { newValue in
                appDelegate.appSettings.showMenubar = newValue
            }
        )) {
            Button("Settings") { appDelegate.appCoordinator.showMainWindow() }
        } label: {
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .semibold))
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
