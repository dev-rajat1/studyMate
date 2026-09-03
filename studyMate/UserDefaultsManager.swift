//
//  UserDefaultsManager.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Lightweight storage for App Settings (Theme, AI toggle, API Key, Model).
//

import UIKit

class UserDefaultsManager {
    
    // Singleton instance
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let themeStyle = "studyMate_themeStyle" // 0: System, 1: Light, 2: Dark
        static let isAIEnabled = "studyMate_isAIEnabled"
        static let aiModelName = "studyMate_aiModelName"
        static let hasSeededInitialData = "studyMate_hasSeededInitialData"
    }
    
    private init() {
        // Register default values
        defaults.register(defaults: [
            Keys.themeStyle: 0,
            Keys.isAIEnabled: true,
            Keys.aiModelName: "gemini-3.7-flash",
            Keys.hasSeededInitialData: false
        ])
    }
    
    // MARK: - Theme Preference
    /// 0 = System, 1 = Light, 2 = Dark
    var themeStyle: Int {
        get { return defaults.integer(forKey: Keys.themeStyle) }
        set {
            defaults.set(newValue, forKey: Keys.themeStyle)
            applyTheme()
        }
    }
    
    /// Applies the saved theme immediately to all connected UI scenes
    func applyTheme() {
        let style: UIUserInterfaceStyle
        switch themeStyle {
        case 1:
            style = .light
        case 2:
            style = .dark
        default:
            style = .unspecified
        }
        
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = style
                }
            }
        }
    }
    
    // MARK: - AI Settings
    var isAIEnabled: Bool {
        get { return defaults.bool(forKey: Keys.isAIEnabled) }
        set { defaults.set(newValue, forKey: Keys.isAIEnabled) }
    }
    
    var aiModelName: String {
        get { return defaults.string(forKey: Keys.aiModelName) ?? "gemini-3.7-flash" }
        set { defaults.set(newValue, forKey: Keys.aiModelName) }
    }
    
    // MARK: - Initial Seed Flag
    var hasSeededInitialData: Bool {
        get { return defaults.bool(forKey: Keys.hasSeededInitialData) }
        set { defaults.set(newValue, forKey: Keys.hasSeededInitialData) }
    }
}
