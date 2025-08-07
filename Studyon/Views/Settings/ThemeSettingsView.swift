//
//  NameSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/7/25.
//

import SwiftUI

struct ThemeSettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @EnvironmentObject var userVM: ProfileViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $settingsVM.selectedTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    ThemeSettingsView(settingsVM: SettingsViewModel())
        .environmentObject(ProfileViewModel())
}
