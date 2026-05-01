//
//  OCRResultView.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 4/30/26.
//


import SwiftUI

struct OCRResultView: View {
    let image: CGImage
    let text: String
    
    @State private var isTextExpanded = true
    
    var body: some View {
        HSplitView {
            // Image Panel
            ImagePanel(image: image)
            
            // OCR Text Panel
            TextPanel(text: text)
        }
        .frame(minWidth: 700, minHeight: 400)
    }
}

// MARK: - Image Panel
struct ImagePanel: View {
    
    let image: CGImage
    
    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color(NSColor.underPageBackgroundColor)
            
            VStack(spacing: 0) {
                HStack {
                    Label("Preview", systemImage: "photo")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .overlay(alignment: .bottom) {
                    Divider()
                }
                
                ScrollView([.horizontal, .vertical]) {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(zoom)
                        .frame(minWidth: 400, minHeight: 300)
                        .animation(.snappy, value: zoom)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    zoom = clamp(lastZoom * value.magnification)
                                }
                                .onEnded { _ in
                                    lastZoom = zoom
                                }
                        )
                }
            }
        }
        .frame(minWidth: 400)
    }
    
    private func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, 0.4), 6.0)
    }
}

// MARK: - Text Panel

struct ReplacementText: Identifiable {
    let id = UUID()
    var replaceFromText: String = ""
    var replaceToText: String = ""
}

enum OCRFilterMode {
    case remove, replace
}

struct OCRFilterConfig {
    var isEnabled = false
    var mode: OCRFilterMode = .remove
    var removeFilterText = ""
    var replacements: [ReplacementText] = []
}

struct TextPanel: View {
    
    let text: String
    
    @State private var editableText: String = ""
    @State private var filterConfig = OCRFilterConfig()
    @State private var showFilteredPreview = true
    
    private var filteredText: String {
        var cleaned = editableText
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
        
        guard filterConfig.isEnabled else { return cleaned }
        
        if !filterConfig.removeFilterText.isEmpty {
            cleaned = cleaned.filter {
                !filterConfig.removeFilterText.contains($0)
            }
        }
        
        for replacement in filterConfig.replacements {
            guard !replacement.replaceFromText.isEmpty else { continue }
            
            cleaned = cleaned.replacingOccurrences(
                of: replacement.replaceFromText,
                with: replacement.replaceToText
            )
        }
        
        return cleaned
    }
    
    private var parsedTotal: String? {
        let pattern = /(\d+\.?\d*)\s*(kB|MB|GB)/
        var totalBytes: Double = 0
        var found = false
        
        for line in filteredText.components(separatedBy: .newlines) {
            if let match = try? pattern.firstMatch(in: line) {
                found = true
                let value = Double(match.1) ?? 0
                switch match.2 {
                case "kB": totalBytes += value * 1_000
                case "MB": totalBytes += value * 1_000_000
                case "GB": totalBytes += value * 1_000_000_000
                default: break
                }
            }
        }
        
        guard found else { return nil }
        if totalBytes >= 1_000_000_000 {
            return String(format: "%.2f GB", totalBytes / 1_000_000_000)
        } else if totalBytes >= 1_000_000 {
            return String(format: "%.2f MB", totalBytes / 1_000_000)
        } else {
            return String(format: "%.2f kB", totalBytes / 1_000)
        }
    }
    
    private var displayText: Binding<String> {
        Binding(
            get: {
                showFilteredPreview ? filteredText : editableText
            },
            set: { newValue in
                editableText = newValue
            }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            textHeader
            
            TextEditor(text: displayText)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(displayText.wrappedValue.isEmpty ? .tertiary : .primary)
                .lineSpacing(4)
                .scrollContentBackground(.hidden)
                .background(Color(NSColor.textBackgroundColor))
                .padding(12)
        }
        .frame(minWidth: 260)
        .onAppear {
            editableText = text
        }
        .onChange(of: text) { _, newText in
            editableText = newText
        }
    }
    
    private var textHeader: some View {
        VStack {
            if let parsedTotal {
                HStack(spacing: 8) {
                    Text(parsedTotal)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                    
                    Spacer()
                }
            }
            HStack(spacing: 8) {
                if filterConfig.isEnabled {
                    Picker("", selection: $filterConfig.mode) {
                        Text("Remove").tag(OCRFilterMode.remove)
                        Text("Replace").tag(OCRFilterMode.replace)
                    }
                    .pickerStyle(.menu)
                    
                    if filterConfig.mode == .remove {
                        TextField("Chars to remove", text: $filterConfig.removeFilterText)
                            .frame(maxWidth: 140)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach($filterConfig.replacements) { $replacement in
                                    TextField("From", text: $replacement.replaceFromText)
                                        .frame(width: 70)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.tertiary)
                                    
                                    TextField("To", text: $replacement.replaceToText)
                                        .frame(width: 70)
                                }
                                
                                Button {
                                    filterConfig.replacements.append(ReplacementText())
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 11))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Toggle("Preview", isOn: $showFilteredPreview)
                        .toggleStyle(.checkbox)
                        .font(.system(size: 11))
                } else {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    Text("Extracted Text")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(filteredText.count) chars")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Color.secondary.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 4)
                        )
                    
                    Button {
                        let pb = NSPasteboard.general
                        pb.clearContents()
                        pb.setString(filteredText, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .help("Copy text")
                }
                
                Button {
                    withAnimation(.snappy) {
                        filterConfig.isEnabled.toggle()
                    }
                } label: {
                    Image(systemName: "line.horizontal.3.decrease")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Filter Text")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .animation(.spring, value: parsedTotal)
        .overlay(alignment: .bottom) { Divider() }
    }
}
