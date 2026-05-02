//
//  VisualEffectView.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/2/26.
//

import SwiftUI

struct GlassEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSGlassEffectView {
        let view = NSGlassEffectView()
        view.style = .regular
        return view
    }
    
    func updateNSView(_ nsView: NSGlassEffectView, context: Context) {}
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        view.layer?.masksToBounds = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
