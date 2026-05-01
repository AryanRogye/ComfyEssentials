//
//  WhitespaceNormalizationVM.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import Foundation
import AppKit
import ComfyWindowKit

@Observable
@MainActor
final class WhitespaceNormalizationVM {
    var text: String = ""
    var convertedText: String = ""
    var isTextViewFocused = true
    var copied = false
    var selectedWindowID: String?

    
    public func copy() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(convertedText, forType: .string)
        
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.copied = false
        }
    }
    
    public func normalize() {
        convertedText = text
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
