//
//  SettingsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 4 — App settings (Theme switch, AI toggle, API Key, and Demo Data).
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Storyboard)
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
        
        appearanceCard?.applyCardStyle(cornerRadius: 14)
        aiSettingsCard?.applyCardStyle(cornerRadius: 14)
        dataManagementCard?.applyCardStyle(cornerRadius: 14)
        
        versionLabel?.text = "StudyMate AI v1.0 • Built with UIKit & CoreData"
    }
    
    private func loadCurrentSettings() {
        // Load Theme (0: System, 1: Light, 2: Dark)
        themeSegmentedControl?.selectedSegmentIndex = UserDefaultsManager.shared.themeStyle
        
        // Load AI status
        aiSwitch?.isOn = UserDefaultsManager.shared.isAIEnabled
        
        // Load API Key
        apiKeyTextField?.text = UserDefaultsManager.shared.customAPIKey
    }
    
    // MARK: - IBActions (Connect in Storyboard)
    
    @IBAction func themeChanged(_ sender: UISegmentedControl) {
        UserDefaultsManager.shared.themeStyle = sender.selectedSegmentIndex
    }
    
    @IBAction func aiSwitchChanged(_ sender: UISwitch) {
        UserDefaultsManager.shared.isAIEnabled = sender.isOn
    }
    
    @IBAction func saveApiKeyTapped(_ sender: UIButton) {
        let key = apiKeyTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaultsManager.shared.customAPIKey = key?.isEmpty == true ? nil : key
        view.endEditing(true)
        showAlert(title: "Settings Saved", message: "Your AI API configuration has been updated.")
    }
    
    @IBAction func loadSampleDataTapped(_ sender: UIButton) {
        CoreDataManager.shared.createSampleDataIfEmpty()
        showAlert(title: "Sample Data Loaded", message: "Sample courses, topics, and study tasks have been populated successfully!")
    }
    
    @IBAction func resetAllDataTapped(_ sender: UIButton) {
        showConfirmationAlert(
            title: "Reset All Data?",
            message: "This will permanently delete all courses, topics, tasks, and notes from Core Data.",
            confirmTitle: "Reset All",
            isDestructive: true,
            onConfirm: { [weak self] in
                let courses = CoreDataManager.shared.fetchCourses()
                courses.forEach { CoreDataManager.shared.deleteCourse($0) }
                self?.showAlert(title: "Reset Complete", message: "All app data has been cleared.")
            }
        )
    }
}
