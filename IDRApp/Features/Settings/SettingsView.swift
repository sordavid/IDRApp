//
//  SettingsView.swift
//  IDRApp
//
//  Created by David Sor on 3/31/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        Form {
            Toggle("Enable notifications", isOn: $notificationsEnabled)
            Toggle("Dark Mode", isOn: $darkModeEnabled)
        }
        .navigationTitle(Text("Settings"))
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}

