//
//  XcodeFile.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/1/26.
//

import SwiftUI

struct XcodeFile: Identifiable {
    let id = UUID()
    var url: URL
    
    var displayChar: String {
        String(rawValue.first ?? "X")
    }
    
    var displayPath: String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return url.path.replacingOccurrences(of: home, with: "~")
    }
    
    public var rawValue: String {
        url
            .lastPathComponent
            .replacingOccurrences(of: ".xcodeproj", with: "")
            .replacingOccurrences(of: ".xcworkspace", with: "")
    }
    
    private var rawURL: String {
        url.lastPathComponent
    }
    
    var color: Color {
        if isXcodeProject { return Color(hex: "1D77F2")! }
        if isXcodeWorkspace { return Color(hex: "8A45D9")! }
        if isSwiftPackage { return Color.orange }
        return Color(hex: "1D77F2")!
    }
    
    var isXcodeProject: Bool {
        rawURL.hasSuffix(".xcodeproj")
    }
    var isXcodeWorkspace: Bool {
        rawURL.hasSuffix(".xcworkspace")
    }
    var isSwiftPackage: Bool {
        !isXcodeProject && !isXcodeWorkspace
    }
}
