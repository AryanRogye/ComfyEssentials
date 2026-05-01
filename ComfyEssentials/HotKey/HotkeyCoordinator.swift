//
//  HotkeyCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/1/26.
//

import KeyboardShortcuts

class HotkeyCoordinator {
    init(
        onWhiteSpaceNormalization: @escaping () -> Void = {},
        onCropOCR: @escaping () -> Void = {},
        onRecentXcodeProjects: @escaping () -> Void = {}
    ) {
        KeyboardShortcuts.onKeyDown(for: .WhitespaceNormalization, action: {
            onWhiteSpaceNormalization()
        })
        KeyboardShortcuts.onKeyDown(for: .CropOCR, action: {
            onCropOCR()
        })
        KeyboardShortcuts.onKeyDown(for: .RecentXcodeProjects, action: {
            onRecentXcodeProjects()
        })
    }
}
