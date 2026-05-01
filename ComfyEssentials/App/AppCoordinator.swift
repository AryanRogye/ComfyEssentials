//
//  AppCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import Foundation

@MainActor
class AppCoordinator {
    
    /// Initialize on start
    var hotkeyCoordinator : HotkeyCoordinator?
    
    let windowCoordinator = WindowCoordinator()
    
    /// Coordinators
    var whitespaceNormalizationCoordinator: WhitespaceNormalizationCoordinator
    var cropOCRCoordinator : CropOCRCoordinator
    var xcodeRecentCoordinator: XcodeRecentCoordinator
    
    /// Windowing
    let windowCore = WindowCore()
    
    init() {
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
    }
}
