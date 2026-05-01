//
//  CropOCRViewModel.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import SwiftUI

@Observable
@MainActor
final class CropOCRViewModel {
    // MARK: - Outputs
    var dragStart: CGPoint?
    var dragCurrent: CGPoint?
    
    // Optional callback with final rect (in view coordinates)
    var capture: ((CGRect) -> Void)?
    var onExit: (() -> Void)?
}

// MARK: - Closures
extension CropOCRViewModel {
    public func exit() {
        onExit?()
    }
    
    public func captureSelection() {
        guard let capture = capture else { return }
        
        /// Make Sure Valid Rect
        if let rect = selectionRect, rect.width > 0, rect.height > 0 {
            capture(rect)
        }
    }
    
}

// MARK: - PublicCropOCRViewModelAPI
extension CropOCRViewModel {
    // Begin drag at point (always start a new selection)
    func beginDrag(at point: CGPoint) {
        dragStart = point
        dragCurrent = point
    }
    
    // Update drag location
    func updateDrag(to point: CGPoint) {
        dragCurrent = point
    }
    
    // End drag, emit final rect and keep it visible (consumer may clear)
    func endDrag(at point: CGPoint) {
        dragCurrent = point
    }
    
    // Clear current selection
    func clearSelection() {
        dragStart = nil
        dragCurrent = nil
    }
}

// MARK: - Derived values
extension CropOCRViewModel {
    // Normalized rect from start/current in local view coordinates
    var selectionRect: CGRect? {
        guard let s = dragStart, let c = dragCurrent else { return nil }
        let x = min(s.x, c.x)
        let y = min(s.y, c.y)
        let w = abs(c.x - s.x)
        let h = abs(c.y - s.y)
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    var selectionSizeText: String? {
        guard let rect = selectionRect, rect.width > 0, rect.height > 0 else { return nil }
        return "\(Int(rect.width)) X \(Int(rect.height))"
    }
}
