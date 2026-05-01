//
//  WhitespaceNormalizationCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import AppKit
import ComfyWindowKit

@MainActor
class WhitespaceNormalizationCoordinator {
    
    var vm = WhitespaceNormalizationVM()
    let windowCoordinator : WindowCoordinator
    let windowCore: WindowCore
    
    init(
        windowCoordinator: WindowCoordinator,
        windowCore: WindowCore
    ) {
        self.windowCoordinator = windowCoordinator
        self.windowCore = windowCore
    }
    
    private var isOpen = false
    private var windowToFocusOnClose: ComfyWindow?
    
    let windowID = UUID().uuidString
    var loadWindowTask : Task<Void, Never>?
    
    public func open() {
        if isOpen { return }
        
        loadWindowTask?.cancel()
        loadWindowTask = Task {
            await windowCore.loadWindows()
        }
        
        windowCoordinator.showWindow(
            id: windowID,
            title: "Whitespace Normalization",
            content: WhitespaceNormalizationView(
                vm: vm,
                windowCore: windowCore,
                closeWindow: {
                    self.windowCoordinator.closeWindow(id: self.windowID)
                },
                focusOnceCloseWindow: { win in
                    self.windowToFocusOnClose = win
                }
            ),
            onOpen: { [weak self] in
                guard let self else { return }
                self.isOpen = true
            },
            onClose: { [weak self] in
                guard let self else { return }
                self.isOpen = false
                
                if let windowToFocusOnClose {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        windowToFocusOnClose.focusWindow()
                    }
                }
                self.loadWindowTask?.cancel()
                self.loadWindowTask = nil
                
            }, onBlur: { [weak self] in
                guard let self else { return }
                self.windowCoordinator.closeWindow(id: self.windowID)
            }
        )
    }
}
