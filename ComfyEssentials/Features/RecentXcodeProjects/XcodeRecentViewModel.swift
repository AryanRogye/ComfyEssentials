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
    
    var visibleProjects: [XcodeFile] {
        let query = filterProjects.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else { return projects }
        
        return projects.filter {
            $0.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    var selected: XcodeFile.ID? = nil
    var projects: [XcodeFile] = []
    var isLoading = false
    var filterProjects: String = ""

    var setFilterFocus: ((Bool) -> Void)?
    var setListFocus: ((Bool) -> Void)?
    var isFilterFocused: (() -> Bool)?
    
    init(parser: XcodeRecentParser) {
        self.parser = parser
    }
    
    public func attachMonitors() {
        guard keyMonitor == nil else { return }
        
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            
            let filterFocused = self.isFilterFocused?() ?? false
            let key = event.charactersIgnoringModifiers
            
            if key == "f", !filterFocused {
                self.setFilterFocus?(true)
                return nil
            }
            
            if key == "j", !filterFocused {
                self.moveSelection(by: 1)
                return nil
            }
            
            if key == "k", !filterFocused {
                self.moveSelection(by: -1)
                return nil
            }
            
            if event.keyCode == 53 {
                if filterFocused {
                    self.setFilterFocus?(false)
                    self.setListFocus?(true)
                } else {
                    self.removeMonitors()
                    self.onClose?()
                }
                return nil
            }
            
            if key == "q", !filterFocused {
                self.removeMonitors()
                self.onClose?()
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
        let list = visibleProjects
        guard !list.isEmpty else {
            selected = nil
            return
        }
        
        guard let current = selected,
              let currentIndex = list.firstIndex(where: { $0.id == current }) else {
            selected = list.first?.id
            return
        }
        
        let nextIndex = currentIndex + offset
        
        guard nextIndex >= 0 && nextIndex < list.count else { return }
        
        selected = list[nextIndex].id
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
