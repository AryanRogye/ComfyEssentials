//
//  XcodeRecentCoordinator.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/1/26.
//

import Foundation
import SwiftUI

@MainActor
final class XcodeRecentCoordinator {
    let windowCoordinator : WindowCoordinator
    let parser = XcodeRecentParser()
    
    init(windowCoordinator: WindowCoordinator) {
        self.windowCoordinator = windowCoordinator
    }
    
    let windowID = UUID().uuidString
    private var isOpen = false
    
    public func open() {
        
        if isOpen { return }
        
        print("Showing")
        windowCoordinator.showWindow(
            id: windowID,
            title: "Xcode Recent Projects",
            content: XcodeRecentsView(
                parser: parser
            ),
            onOpen: { [weak self] in
                guard let self else { return }
                isOpen = true
            },
            onClose: { [weak self] in
                guard let self else { return }
                isOpen = false
            }, onBlur: { [weak self] in
                guard let self else { return }
                self.windowCoordinator.closeWindow(id: self.windowID)
            }
        )
    }
}
