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
        WindowGroup { EmptyView().destroyViewWindow() }
    }
}
