//
//  ComfyEssentialsSettings.swift
//  ComfyEssentials
//
//  Created by Aryan Rogye on 5/2/26.
//

import SwiftUI

struct ComfyEssentialsSettings: View {
    
    @Bindable var appSettings: AppSettings
    
    var body: some View {
        VStack {
            Toggle("Show Menubar", isOn: $appSettings.showMenubar)
                .toggleStyle(.switch)
        }
        .frame(width: 500, height: 500)
    }
}
