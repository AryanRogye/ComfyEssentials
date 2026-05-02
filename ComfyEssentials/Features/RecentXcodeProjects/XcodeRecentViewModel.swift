//
//  XcodeRecentViewModel.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/1/26.
//

import AppKit

@Observable
@MainActor
class XcodeRecentViewModel {
    
    let parser: XcodeRecentParser
    var keyMonitor: Any?
    var onClose: (() -> Void)?
    
    var setFilterFocus: ((Bool) -> Void)?
    var setListFocus: ((Bool) -> Void)?
    var isFilterFocused: (() -> Bool)?
    
    init(parser: XcodeRecentParser) {
        self.parser = parser
    }
    
    
    var selected: XcodeFile.ID? = nil
    var projects: [XcodeFile] = []
    var isLoading = false
    var filterProjects: String = ""

    public func attachMonitors() {
        /// ok if we attach it again so dont check for nil
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return nil }
            let filterFocused = self.isFilterFocused?() ?? false
            
            if event.charactersIgnoringModifiers == "f" {
                self.setFilterFocus?(true)
                return nil
            }
            if event.charactersIgnoringModifiers == "j" && !filterFocused {
                self.moveSelection(by: 1)
                return nil
            }
            if event.charactersIgnoringModifiers == "k" && !filterFocused {
                self.moveSelection(by: -1)
                return nil
            }
            if (event.charactersIgnoringModifiers == "q" || event.keyCode == 53) && !filterFocused {
                self.removeMonitors()
                self.onClose?()
                return nil
            }
            if event.keyCode == 53 && filterFocused {
                self.setFilterFocus?(false)
                self.setListFocus?(true)
                return nil
            }
            return event
        }
    }
    
    public func removeMonitors() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
    
    func moveSelection(by offset: Int) {
        guard let current = selected,
              let currentIndex = projects.firstIndex(where: { $0.id == current }) else { return }
        let nextIndex = currentIndex + offset
        guard nextIndex >= 0 && nextIndex < projects.count else { return }
        selected = projects[nextIndex].id
    }
    
    public func loadProjects() {
        if isLoading { return }
        isLoading = true
        Task {
            if let projects = await parser.getXcodeItems() {
                self.projects = projects
                if let first = projects.first {
                    self.selected = first.id
                    self.setListFocus?(true)
                }
            }
            self.isLoading = false
        }
    }
}
