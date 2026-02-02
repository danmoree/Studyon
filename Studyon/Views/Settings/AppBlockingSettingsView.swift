//
//  Created by Daniel Moreno on 2025
//  © 2025 Daniel Moreno. All rights reserved.
//  This code is proprietary and confidential.
//  Do not copy, distribute, or reuse without written permission.
//
//  AppBlockingSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 1/21/26.
//

import SwiftUI
import FamilyControls

struct AppBlockingSettingsView: View {
    @StateObject private var manager = AppBlockingManager.shared
    @State private var showAppPicker = false
    @State private var selection = FamilyActivitySelection()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showClearConfirmation = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("App Blocking")
                    .font(.title)
                    .fontWidth(.expanded)
                    .bold()

                Text("Block distracting apps during study sessions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 23)
            .padding(.top, 20)
            .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 20) {
                    // Authorization Status
                    if !manager.isAuthorized {
                        VStack(spacing: 16) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)

                            Text("Authorization Required")
                                .font(.headline)
                                .fontWidth(.expanded)

                            Text("To block apps during study sessions, you need to grant Screen Time permissions.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Button {
                                Task {
                                    do {
                                        try await manager.requestAuthorization()
                                    } catch {
                                        errorMessage = "Failed to get authorization: \(error.localizedDescription)"
                                        showError = true
                                    }
                                }
                            } label: {
                                Text("Grant Permission")
                                    .fontWidth(.expanded)
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(colorScheme == .light ? .black : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 23)
                        }
                        .padding(.vertical, 40)
                    } else {
                        // Authorized - Show configuration
                        VStack(alignment: .leading, spacing: 16) {
                            // Status indicator
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Screen Time Permission Granted")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 23)

                            Divider()
                                .padding(.horizontal, 23)

                            // Enable/Disable Toggle
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle(isOn: Binding(
                                    get: { manager.isEnabled },
                                    set: { manager.setEnabled($0) }
                                )) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Enable App Blocking")
                                            .font(.headline)
                                            .fontWidth(.expanded)
                                        Text("Turn off to disable app blocking during study sessions")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .tint(.blue)
                                .padding(.horizontal, 23)
                            }

                            Divider()
                                .padding(.horizontal, 23)

                            // Select Apps Button
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Apps to Keep Unblocked")
                                    .font(.headline)
                                    .fontWidth(.expanded)
                                    .padding(.horizontal, 23)

                                Text("Choose which apps should remain accessible during your study sessions. All other apps will be blocked.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 23)

                                Button {
                                    showAppPicker = true
                                } label: {
                                    HStack {
                                        Image(systemName: "app.badge.fill")
                                        Text("Select Exception Apps")
                                            .fontWidth(.expanded)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                                    .padding()
                                    .background(colorScheme == .light ? .black : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal, 23)
                            }

                            // Current Selection Info
                            if manager.hasAppsToBlock() {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.blue)
                                        Text("Apps configured")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 23)
                                    .padding(.top, 8)

                                    Text("Selected apps will remain accessible during study sessions. All other apps will be blocked automatically when you start a study session (solo or group).")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 23)
                                }
                            }

                            Divider()
                                .padding(.horizontal, 23)
                                .padding(.top, 8)

                            // How it works section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How it works")
                                    .font(.headline)
                                    .fontWidth(.expanded)
                                    .padding(.horizontal, 23)

                                VStack(alignment: .leading, spacing: 12) {
                                    InfoRow(icon: "play.circle.fill", text: "Apps are blocked when you start a study session")
                                    InfoRow(icon: "pause.circle.fill", text: "Apps remain blocked even if you pause")
                                    InfoRow(icon: "stop.circle.fill", text: "Apps are unblocked when you leave the session")
                                }
                                .padding(.horizontal, 23)
                            }

                            Divider()
                                .padding(.horizontal, 23)
                                .padding(.top, 8)

                            // Clear All Data Button
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reset")
                                    .font(.headline)
                                    .fontWidth(.expanded)
                                    .padding(.horizontal, 23)

                                Button {
                                    showClearConfirmation = true
                                } label: {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Clear All Settings")
                                            .fontWidth(.expanded)
                                    }
                                    .foregroundStyle(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal, 23)

                                Text("This will clear your selected apps and reset all settings")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 23)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .familyActivityPicker(isPresented: $showAppPicker, selection: $selection)
        .onChange(of: selection) { newSelection in
            manager.saveExceptionApps(newSelection)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Clear All Settings?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                manager.clearAll()
                selection = FamilyActivitySelection()
            }
        } message: {
            Text("This will remove all your app selections and reset app blocking settings. This cannot be undone.")
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AppBlockingSettingsView()
}
