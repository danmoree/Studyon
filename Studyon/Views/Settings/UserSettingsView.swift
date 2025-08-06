//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  UserSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/28/25.
//

import SwiftUI

struct UserSettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    var body: some View {
            
            NavigationStack {
                
                ZStack {
                    Color.background
                            .ignoresSafeArea()
                    
                    List {
                        Section(header: Text("Profile")) {
                            NavigationLink("Username", destination: ProfileSettingsView(settingsVM: settingsVM))
                           // NavigationLink("Notifications", destination: NotificationSettingsView())
                        }
                        

                        Section(header: Text("Appearance")) {
                          //  NavigationLink("Theme", destination: ThemeSettingsView())
                          //  NavigationLink("Font Size", destination: FontSizeSettingsView())
                        }
                        
                        Section(header: Text("Study")) {
                          //  NavigationLink("Theme", destination: ThemeSettingsView())
                          //  NavigationLink("Font Size", destination: FontSizeSettingsView())
                        }

                        Section {
                           // NavigationLink("About", destination: AboutView())
                           Button(role: .destructive) {
                                // Handle logout
                            } label: {
                                Text("Log Out")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Settings")
                    .listStyle(.insetGrouped) // Or .grouped depending on your design
                    
                }
                 
                    }
        
       
    }
}

#Preview {
    UserSettingsView(settingsVM: SettingsViewModel())
}
