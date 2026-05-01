//
//  XcodeRecentsView.swift
//  ComfyEssentialsUI
//
//  Created by Aryan Rogye on 5/1/26.
//


import SwiftUI

public struct XcodeRecentRow: View {
    
    let title: String
    let label: String
    let displayChar: String
    let color: Color
    
    public init(title: String, label: String, displayChar: String, color: Color) {
        self.title = title
        self.label = label
        self.displayChar = displayChar
        self.color = color
    }
    
    public var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(alignment: .center) {
                    ZStack {
                        GridLines(color: .white.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Text(displayChar)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.clear)
        }
        .frame(height: 40)
    }
}

private struct GridLines: View {
    var spacing: CGFloat = 10
    var lineWidth: CGFloat = 0.5
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            
            // Vertical lines
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            
            // Horizontal lines
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            
            context.stroke(
                path,
                with: .color(color),
                lineWidth: lineWidth
            )
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    List {
        XcodeRecentRow(title: "Something", label: "Label", displayChar: "S", color: .blue)
        XcodeRecentRow(title: "ComfyEssentials", label: "Label", displayChar: "C", color: .blue)
        XcodeRecentRow(title: "ComfyNotch", label: "Label", displayChar: "C", color: .blue)
        XcodeRecentRow(title: "ComfyTile", label: "Label", displayChar: "C", color: .blue)
        XcodeRecentRow(title: "Something", label: "Label", displayChar: "S", color: .blue)
    }
    .frame(width: 300, height: 400)
}
