//
//  SettingsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 4 — App settings (Theme switch, AI toggle, API Key, and Demo Data).
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var themeSegmentedControl: UISegmentedControl?
    @IBOutlet weak var aiSwitch: UISwitch?
    @IBOutlet weak var apiKeyTextField: UITextField?
    @IBOutlet weak var versionLabel: UILabel?
    
    @IBOutlet weak var appearanceCard: UIView?
    @IBOutlet weak var aiSettingsCard: UIView?
    @IBOutlet weak var dataManagementCard: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentSettings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        appearanceCard?.applyCardStyle(cornerRadius: 16)
        aiSettingsCard?.applyCardStyle(cornerRadius: 16)
        dataManagementCard?.applyCardStyle(cornerRadius: 16)
        
        versionLabel?.text = "StudyMate AI v1.0 • Built with UIKit & CoreData\nPowered by Google Gemini 3.7 Flash"
    }
    
    private func loadCurrentSettings() {
        themeSegmentedControl?.selectedSegmentIndex = UserDefaultsManager.shared.themeStyle
        aiSwitch?.isOn = UserDefaultsManager.shared.isAIEnabled
        apiKeyTextField?.text = UserDefaultsManager.shared.customAPIKey
    }
    
    // MARK: - IBActions
    
    @IBAction func themeChanged(_ sender: UISegmentedControl) {
        HapticHelper.lightImpact()
        UserDefaultsManager.shared.themeStyle = sender.selectedSegmentIndex
        showToast(message: "Theme updated!")
    }
    
    @IBAction func aiSwitchChanged(_ sender: UISwitch) {
        HapticHelper.lightImpact()
        UserDefaultsManager.shared.isAIEnabled = sender.isOn
        showToast(message: sender.isOn ? "✨ AI Features Enabled" : "AI Features Disabled")
    }
    
    @IBAction func saveApiKeyTapped(_ sender: UIButton) {
        HapticHelper.success()
        let key = apiKeyTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaultsManager.shared.customAPIKey = key?.isEmpty == true ? nil : key
        view.endEditing(true)
        showToast(message: "✅ Gemini API Key Saved!")
    }
    
    @IBAction func loadSampleDataTapped(_ sender: UIButton) {
        HapticHelper.success()
        CoreDataManager.shared.createSampleDataIfEmpty()
        showToast(message: "🌱 Sample Study Data Loaded!")
    }
    
    @IBAction func resetAllDataTapped(_ sender: UIButton) {
        HapticHelper.mediumImpact()
        showConfirmationAlert(
            title: "Reset All Study Data?",
            message: "This will permanently clear all courses, topics, study tasks, and AI notes from Core Data.",
            confirmTitle: "Reset All",
            isDestructive: true,
            onConfirm: { [weak self] in
                let courses = CoreDataManager.shared.fetchCourses()
                courses.forEach { CoreDataManager.shared.deleteCourse($0) }
                self?.showToast(message: "🗑 All Data Cleared.")
            }
        )
    }
}
