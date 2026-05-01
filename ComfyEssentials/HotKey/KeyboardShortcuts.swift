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
    static let RecentXcodeProjects = Self(
        "RecentXcodeProjects",
        default: .init(.x, modifiers: [.command, .shift])
    )
}
