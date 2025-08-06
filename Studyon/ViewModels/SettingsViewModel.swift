//
//  SettingsViewModel.swift
//  Studyon
//
//  Created by Daniel Moreno on 8/5/25.
//

import Foundation


class SettingsViewModel: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            SettingsService.shared.saveTheme(selectedTheme)
        }
    }
    
    init() {
        self.selectedTheme = SettingsService.shared.loadTheme()
    }
}
