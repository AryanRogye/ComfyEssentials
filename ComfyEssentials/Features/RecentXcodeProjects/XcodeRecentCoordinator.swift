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
    var vm : XcodeRecentViewModel
    let windowCoordinator : WindowCoordinator
    let parser = XcodeRecentParser()
    
    init(windowCoordinator: WindowCoordinator) {
        self.windowCoordinator = windowCoordinator
        self.vm = XcodeRecentViewModel(parser: parser)
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
                vm: vm,
                onClose: { [weak self] in
                    guard let self else { return }
                    windowCoordinator.closeWindow(id: windowID)
                }
            ),
            onOpen: { [weak self] in
                guard let self else { return }
                isOpen = true
                vm.attachMonitors()
            },
            onClose: { [weak self] in
                guard let self else { return }
                isOpen = false
                vm.removeMonitors()
            }, onBlur: { [weak self] in
                guard let self else { return }
                self.windowCoordinator.closeWindow(id: self.windowID)
            }
        )
        NSApp.activate(ignoringOtherApps: true)
    }
}
