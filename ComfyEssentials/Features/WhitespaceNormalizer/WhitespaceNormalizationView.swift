//
//  WhitespaceNormalizationView.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//


import SwiftUI
import ComfyWindowKit

struct WhitespaceNormalizationView: View {
    
    @Bindable var vm : WhitespaceNormalizationVM
    @Bindable var windowCore: WindowCore
    
    var closeWindow: (() -> Void)
    var focusOnceCloseWindow: ((ComfyWindow) -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Whitespace Normalizer")
                .font(.title2.bold())
            
            CustomTextView(
                text: $vm.text,
                isFocused: $vm.isTextViewFocused,
                onSubmit: normalizeAndCopy
            )
            .frame(height: 96)
            .padding(10)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            
            Text("Press Return to normalize + copy")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Button("Normalize") {
                    vm.normalize()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Clear") {
                    vm.text = ""
                    vm.convertedText = ""
                }
                .buttonStyle(.bordered)
                
                Picker("Return focus to", selection: $vm.selectedWindowID) {
                    Text("None").tag(String?.none)
                    
                    ForEach(windowCore.windows, id: \.id) { window in
                        Text(window.windowTitle)
                            .tag(Optional(window.id))
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: vm.selectedWindowID) {
                    guard let id = vm.selectedWindowID,
                          let window = windowCore.windows.first(where: { $0.id == id })
                    else { return }
                    
                    focusOnceCloseWindow(window)
                }
                
                Spacer()
                
                Button(vm.copied ? "Copied!" : "Copy", action: vm.copy)
                    .disabled(vm.convertedText.isEmpty)
            }
            
            if !vm.convertedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Result")
                        .font(.headline)
                    
                    Text(vm.convertedText)
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .onChange(of: vm.text) {
            vm.normalize()
        }
    }
    
    private func normalizeAndCopy() {
        vm.normalize()
        vm.copy()
        vm.text = ""
        vm.convertedText = ""
        closeWindow()
    }
}
