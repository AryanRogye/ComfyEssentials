//
//  HotkeyCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import KeyboardShortcuts
import AppKit

extension KeyboardShortcuts.Name {
    static let WhitespaceNormalization = Self(
        "WhitespaceNormalization",
        default: .init(.u, modifiers: .command)
    )
    static let CropOCR = Self(
        "CropOCR",
        default: .init(.u, modifiers: [.command, .shift])
    )
}
class HotkeyCoordinator {
    init(
        onWhiteSpaceNormalization: @escaping () -> Void = {},
        onCropOCR: @escaping () -> Void = {}
    ) {
        KeyboardShortcuts.onKeyDown(for: .WhitespaceNormalization, action: {
            onWhiteSpaceNormalization()
        })
        KeyboardShortcuts.onKeyDown(for: .CropOCR, action: {
            onCropOCR()
        })
    }
}
