//
//  XcodeRecentsView.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/1/26.
//

import SwiftUI
import ComfyEssentialsUI

struct XcodeRecentsView: View {
    
    let parser: XcodeRecentParser
    @State private var projects: [XcodeFile] = []
    @State private var isLoading = false
    @State private var selected: XcodeFile.ID? = nil
    @State private var filterProjects: String = ""
    @FocusState private var focusedList
    @FocusState private var focusedFilter
    
    @State private var keyMonitor: Any?

    var body: some View {
        VStack(spacing: 0) {
            
            TextField("Filter [f]", text: $filterProjects)
                .focused($focusedFilter)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black.opacity(0.18))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            
            List(projects, selection: $selected) { file in
                
                XcodeRecentRow(
                    title: file.rawValue,
                    label: file.displayPath,
                    displayChar: file.displayChar,
                    color: file.color
                )
                .tag(file.id)
            }
            .focused($focusedList)
            
            if let id = selected, let file = projects.first(where: { $0.id == id }) {
                Divider()
                HStack {
                    Spacer()
                    Button("Open in Xcode") {
                        NSWorkspace.shared.open(file.url)
                    }
                    .keyboardShortcut(.return, modifiers: [])
                    .padding(10)
                }
            }
        }
        .frame(width: 300, height: 400)
        .task {
            loadProjects()
        }
        .onAppear {
            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.charactersIgnoringModifiers == "f" {
                    focusedFilter = true
                    return nil
                }
                return event
            }
        }
        .onDisappear {
            if let monitor = keyMonitor {
                NSEvent.removeMonitor(monitor)
                keyMonitor = nil
            }
        }
    }
    
    
    public func loadProjects() {
        if isLoading { return }
        isLoading = true
        Task {
            if let projects = await parser.getXcodeItems() {
                self.projects = projects
                if let first = projects.first {
                    self.selected = first.id
                    focusedList = true
                }
            }
            self.isLoading = false
        }
    }
}
