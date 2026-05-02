//
//  AppCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import Foundation

@MainActor
class AppCoordinator {
    
    var appSettings: AppSettings
    /// Initialize on start
    var hotkeyCoordinator : HotkeyCoordinator?
    
    let windowCoordinator = WindowCoordinator()
    let panelCoordinator  = PanelCoordinator()
    
    /// Coordinators
    var whitespaceNormalizationCoordinator: WhitespaceNormalizationCoordinator
    var cropOCRCoordinator : CropOCRCoordinator
    var xcodeRecentCoordinator: XcodeRecentCoordinator
    
    var appSettingsCoordinator : AppSettingsCoordinator
    
    /// Windowing
    let windowCore = WindowCore()
    
    init(appSettings: AppSettings) {
        
        self.appSettings = appSettings
        
        self.whitespaceNormalizationCoordinator = WhitespaceNormalizationCoordinator(
            windowCoordinator: windowCoordinator,
            windowCore: windowCore
        )
        self.cropOCRCoordinator = CropOCRCoordinator(
            windowCoordinator: windowCoordinator
        )
        self.xcodeRecentCoordinator = XcodeRecentCoordinator(
            windowCoordinator: windowCoordinator
        )
        self.appSettingsCoordinator = AppSettingsCoordinator(
            windowCoordinator: windowCoordinator,
            appSettings: appSettings
        )
    }
    
    public func showMainWindow() {
        self.appSettingsCoordinator.show()
    }
    
    public func start() {
        self.hotkeyCoordinator = HotkeyCoordinator(
            onWhiteSpaceNormalization: {
                self.whitespaceNormalizationCoordinator.open()
            },
            onCropOCR: {
                self.cropOCRCoordinator.show()
            },
            onRecentXcodeProjects: {
                self.xcodeRecentCoordinator.open()
            }
        )
        showMainWindow()
    }
}
