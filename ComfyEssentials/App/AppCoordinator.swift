//
//  AppCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import Foundation

@MainActor
class AppCoordinator {
    var hotkeyCoordinator : HotkeyCoordinator?
    var cropOCRCoordinator : CropOCRCoordinator
    var whitespaceNormalizationCoordinator: WhitespaceNormalizationCoordinator
    let windowCoordinator = WindowCoordinator()
    let windowCore = WindowCore()
    
    init() {
        self.whitespaceNormalizationCoordinator = WhitespaceNormalizationCoordinator(
            windowCoordinator: windowCoordinator,
            windowCore: windowCore
        )
        self.cropOCRCoordinator = CropOCRCoordinator(
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
            }
        )
    }
}
