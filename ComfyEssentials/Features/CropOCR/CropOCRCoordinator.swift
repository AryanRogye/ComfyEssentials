//
//  CropOCRCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import AppKit
import SwiftUI
import SnapCore
import ComfyEssentialsUI

@MainActor
class CropOCRCoordinator {
    let windowCoordinator : WindowCoordinator
    let screenshot    = ScreenshotService()
    var overlayScreen           : NSPanel!
    private var targetScreen    : NSScreen?
    private var vm              = CropOCRViewModel()
    
    init(windowCoordinator: WindowCoordinator) {
        self.windowCoordinator = windowCoordinator
    }
    
    public func setupOverlay() {
        
        guard let screen = WindowCore.screenUnderMouse() else {
            print("Cant SetupOverlay, No screen")
            return
        }
        self.targetScreen = screen
        
        overlayScreen = FocusablePanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        overlayScreen.setFrame(screen.frame, display: true)
        /// Allow content to draw outside panel bounds
        overlayScreen.contentView?.wantsLayer = true
        
        overlayScreen.registerForDraggedTypes([.fileURL])
        overlayScreen.title = "ComfyNotch"
        overlayScreen.acceptsMouseMovedEvents = true
        
        let screenSaverRaw = CGWindowLevelForKey(.screenSaverWindow)
        overlayScreen.level = NSWindow.Level(rawValue: Int(screenSaverRaw))
        
        overlayScreen.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlayScreen.isMovableByWindowBackground = false
        overlayScreen.backgroundColor = .clear
        overlayScreen.isOpaque = false
        overlayScreen.hasShadow = false
        
        let view: NSView = CrosshairHostingView(
            rootView: SelectionOverlay(
                vm: vm
            )
        )
        
        /// Allow hosting view to overflow
        view.wantsLayer = true
        view.layer?.masksToBounds = false
        
        overlayScreen.contentView = view
        // Ensure key events route into SwiftUI hosting view
        overlayScreen.initialFirstResponder = view
        self.hide()
        
        
        vm.capture = { [weak self] rect in
            guard let self else { return }
            
            self.hide()
            
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard let targetScreen = self.targetScreen else { return }
                if let image = await screenshot.takeScreenshot(
                    of: targetScreen,
                    croppingTo: rect
                ) {
                    let text = await OCRService.extractText(from: image)
                    self.showPreviewImage(image, with: text)
                }
            }
        }
        
        vm.onExit = { [weak self] in
            self?.hide()
        }
    }
    
    public func showPreviewImage(_ image: CGImage, with text: String) {
        windowCoordinator.showWindow(
            id: UUID().uuidString,
            title: "Preview",
            content: OCRResultView(image: image, text: text)
        )
    }
    
    // MARK: - Show Hide Overlay
    public func show() {
        guard let currentScreen = ScreenshotService.screenUnderMouse() else {
            print("Can't show, no screen under mouse")
            return
        }
        
        if overlayScreen == nil || targetScreen != currentScreen {
            setupOverlay() // handles targetScreen internally
        }
        
        guard let overlayScreen = self.overlayScreen else { return }
        
        if !overlayScreen.isVisible {
            NSApp.activate(ignoringOtherApps: true)
            overlayScreen.makeKeyAndOrderFront(nil)
            overlayScreen.makeFirstResponder(overlayScreen.contentView)
            overlayScreen.ignoresMouseEvents = false
            if let contentView = overlayScreen.contentView {
                overlayScreen.invalidateCursorRects(for: contentView)
            }
        }
    }
    
    public func hide() {
        guard let overlayScreen = overlayScreen else {
            print("Cant Hide, Overlay is nil")
            return
        }
        
        if overlayScreen.isVisible {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                guard let self = self else { return }
                self.overlayScreen?.orderOut(nil)
                
                self.vm.dragStart = nil
                self.vm.dragCurrent = nil
                
                NSCursor.arrow.set()
            }
        }
    }
}
