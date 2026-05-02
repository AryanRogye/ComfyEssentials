//
//  PanelCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/2/26.
//

import AppKit
import SwiftUI

private class PanelDelegate: NSObject, NSWindowDelegate {
    let id: String
    weak var coordinator: PanelCoordinator?
    
    init(id: String, coordinator: PanelCoordinator) {
        self.id = id
        self.coordinator = coordinator
    }
    
    func windowDidResignKey(_ notification: Notification) {
        coordinator?.handlePanelBlur(id: id)
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        coordinator?.handlePanelOpen(id: id)
    }
    
    func windowWillClose(_ notification: Notification) {
        coordinator?.handlePanelClose(id: id)
    }
}

enum PanelSizing {
    case fixed(size: NSSize, origin: CGPoint? = nil)
    case fullscreen(screen: NSScreen = .main!)
}

// MARK: - OOP
/// PanelCoordinator manages the lifecycle of multiple floating panels.
@MainActor
class PanelCoordinator {
    
    private var panels: [String: FocusablePanel] = [:]
    
    private var onOpenAction: [String: (() -> Void)] = [:]
    private var onCloseAction: [String: (() -> Void)] = [:]
    private var onBlurAction: [String: (() -> Void)] = [:]
    
    private var delegates: [String: PanelDelegate] = [:]
    
    deinit {
        for panel in panels.values {
            DispatchQueue.main.async {
                panel.close()
            }
        }
        
        panels.removeAll()
    }
    
    func showPanel(
        id: String,
        title: String,
        content: some View,
        sizing: PanelSizing = .fixed(size: .init(width: 600, height: 400)),
        onOpen: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        onBlur: (() -> Void)? = nil
    ) {
        let rect: NSRect
        
        switch sizing {
        case .fixed(let size, let origin):
            rect = NSRect(origin: origin ?? .zero, size: size)
            
        case .fullscreen(let screen):
            rect = screen.frame
        }
        
        let panel = FocusablePanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        panel.setFrame(rect, display: true)
        
        panel.title = title
        panel.isReleasedWhenClosed = false
        panel.isFloatingPanel = true
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.overlayWindow)))
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.acceptsMouseMovedEvents = true
        
        let hostingView = NSHostingView(rootView: content)
        hostingView.wantsLayer = true
        hostingView.layer?.masksToBounds = false
        panel.contentView = hostingView
        
        panels[id] = panel
        panel.makeKeyAndOrderFront(nil)
    }
    
    func closePanel(id: String) {
        panels[id]?.close()
    }
    
    fileprivate func handlePanelBlur(id: String) {
        if let action = onBlurAction[id] {
            action()
            onBlurAction[id] = nil
        }
    }
    
    fileprivate func handlePanelOpen(id: String) {
        if let action = onOpenAction[id] {
            action()
            onOpenAction[id] = nil
        }
    }
    
    fileprivate func handlePanelClose(id: String) {
        panels[id] = nil
        delegates[id] = nil
        onOpenAction[id] = nil
        onBlurAction[id] = nil
        
        if let action = onCloseAction[id] {
            action()
            onCloseAction[id] = nil
        }
    }
}

extension PanelCoordinator {
    
    @discardableResult
    public func changePanelName(
        from oldId: String,
        to newId: String,
        newTitle: String? = nil
    ) -> Bool {
        guard let panel = panels[oldId] else { return false }
        guard panels[newId] == nil else { return false }
        
        panels.removeValue(forKey: oldId)
        panels[newId] = panel
        
        if let open = onOpenAction.removeValue(forKey: oldId) {
            onOpenAction[newId] = open
        }
        
        if let close = onCloseAction.removeValue(forKey: oldId) {
            onCloseAction[newId] = close
        }
        
        if let blur = onBlurAction.removeValue(forKey: oldId) {
            onBlurAction[newId] = blur
        }
        
        let newDelegate = PanelDelegate(id: newId, coordinator: self)
        panel.delegate = newDelegate
        delegates[oldId] = nil
        delegates[newId] = newDelegate
        
        if let title = newTitle {
            panel.title = title
        }
        
        return true
    }
    
    public func setTitle(for id: String, to title: String) {
        panels[id]?.title = title
    }
    
    public func activateWithRetry(_ tries: Int = 6) {
        guard tries > 0 else { return }
        
        if NSApp.isActive, NSApp.keyWindow != nil {
            return
        }
        
        bringAppFront()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in
            self?.activateWithRetry(tries - 1)
        }
    }
    
    public func bringAppFront() {
        NSRunningApplication.current.activate(options: [.activateAllWindows])
        NSApp.activate(ignoringOtherApps: true)
    }
}
