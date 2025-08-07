//
//  GoalsSettingsView.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/7/25.
//

import SwiftUI

struct GoalsSettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @EnvironmentObject var userVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedGoalMinutes: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text("Daily Study Goal (minutes)")) {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("Daily Study Goal (minutes)", selection: $selectedGoalMinutes) {
                        ForEach(0...240, id: \.self) { minute in
                            Text("\(minute)")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)

                }
            }
            
        }
        .onAppear {
            if let dailyGoal = userVM.user?.dailyStudyGoal {
                selectedGoalMinutes = Int(dailyGoal / 60)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    Task {
                        do {
                            try await
                            userVM.updateDailyStudyGoal(amount: Double(selectedGoalMinutes) * 60 )
                        } catch {
                            alertMessage = "Failed to update goal: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                    dismiss()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    GoalsSettingsView(settingsVM: SettingsViewModel())
        .environmentObject(ProfileViewModel())
}
