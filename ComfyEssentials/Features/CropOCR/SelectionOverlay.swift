//
//  SelectionOverlay.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//

import SwiftUI

struct SelectionOverlay: View {
    @Bindable var vm: CropOCRViewModel
    
    var body: some View {
        ZStack {
            // Dim the screen
            Color.black.opacity(0.7)
            
            /// Selection rectangle If User decides to drag
            if let rect = vm.selectionRect {
                SelectionRect(rect: rect, sizeText: vm.selectionSizeText)
            }
            
            // Top bar with close
            VStack {
                topRow
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .onExitCommand(perform: vm.exit)
    }
    
    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // startLocation is stable for the whole drag
                vm.beginDrag(at: value.startLocation)
                vm.updateDrag(to: value.location)
            }
            .onEnded { value in
                vm.endDrag(at: value.location)
            }
    }
    
    private var topRow: some View {
        HStack {
            Spacer()
            Button(action: vm.captureSelection) {
                Text("Capture")
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
            .accessibilityLabel("Take A Capture Of The Selected Area")
            
            Button(action: vm.exit) {
                Image(systemName: "xmark")
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            .accessibilityLabel("Close Selection Overlay")
        }
        .padding()
    }
}


struct SelectionRect: View {
    let rect: CGRect
    let sizeText: String?
    
    var body: some View {
        Rectangle()
            .stroke(Color.white, lineWidth: 2)
            .background(
                Rectangle().fill(Color.white.opacity(0.15))
            )
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .overlay(alignment: .topLeading) {
                if let sizeText = sizeText {
                    Text(sizeText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.6))
                        .cornerRadius(6)
                        .padding(6)
                }
            }
    }
}
