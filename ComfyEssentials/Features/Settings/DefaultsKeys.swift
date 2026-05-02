//
//  DefaultsKeys.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/2/26.
//

import Defaults
import SwiftUI

extension Defaults.Keys {
    static let showMenuBar = Key<Bool>("ShowMenuBar", default: true)
}

@Observable
@MainActor
class AppSettings {
    var showMenubar: Bool = Defaults[.showMenuBar] {
        didSet {
            Defaults[.showMenuBar] = showMenubar
        }
    }
}
