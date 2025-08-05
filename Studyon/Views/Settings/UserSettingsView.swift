//
//  UserSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 7/28/25.
//

import SwiftUI

struct UserSettingsView: View {
    var body: some View {
            
            NavigationStack {
                ZStack {
                    Color("background").ignoresSafeArea()
                    List {
                        Section(header: Text("General")) {
                           // NavigationLink("Account", destination: AccountSettingsView())
                           // NavigationLink("Notifications", destination: NotificationSettingsView())
                        }
                        

                        Section(header: Text("Appearance")) {
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
                    .navigationTitle("Settings")
                    .listStyle(.insetGrouped) // Or .grouped depending on your design
                }
                 
                    }
        
       
    }
}

#Preview {
    UserSettingsView()
}
