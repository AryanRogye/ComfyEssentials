//
//  XcodeRecentsView.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/1/26.
//

import SwiftUI
import ComfyEssentialsUI

struct XcodeRecentsView: View {
    
    @Bindable var vm: XcodeRecentViewModel
    var onClose: () -> Void
    
    @FocusState private var focusedList
    @FocusState private var focusedFilter


    var body: some View {
        VStack(spacing: 0) {
            
            TextField("Filter [f]", text: $vm.filterProjects)
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
            
            ScrollViewReader { proxy in
                List(vm.visibleProjects, selection: $vm.selected) { file in
                    XcodeRecentRow(
                        title: file.rawValue,
                        label: file.displayPath,
                        displayChar: file.displayChar,
                        color: file.color
                    )
                    .tag(file.id)
                }
                .focused($focusedList)
                .onChange(of: vm.selected) { oldValue, newValue in
                    if let newValue {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            
            if let id = vm.selected, let file = vm.projects.first(where: { $0.id == id }) {
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
        .onAppear {
            vm.onClose = onClose
            vm.setFilterFocus = { focusedFilter = $0 }
            vm.setListFocus   = { focusedList = $0 }
            vm.isFilterFocused = { focusedFilter }
            vm.attachMonitors()
        }
        .onDisappear {
            vm.removeMonitors()
        }
        .task {
            vm.loadProjects()
        }
    }
}
