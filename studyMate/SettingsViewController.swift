//
//  SettingsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 4 — Modern Settings screen with Theme switch, Gemini AI engine config, and Data management.
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
        setupTapToDismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateCardsEntrance()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        appearanceCard?.applyCardStyle(cornerRadius: 18)
        aiSettingsCard?.applyCardStyle(cornerRadius: 18)
        dataManagementCard?.applyCardStyle(cornerRadius: 18)
        
        apiKeyTextField?.layer.cornerRadius = 12
        apiKeyTextField?.backgroundColor = .tertiarySystemGroupedBackground
        apiKeyTextField?.layer.borderWidth = 0.5
        apiKeyTextField?.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        
        themeSegmentedControl?.selectedSegmentTintColor = .systemPurple
        themeSegmentedControl?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        versionLabel?.text = "StudyMate AI v1.0 • Built with UIKit & CoreData\n⚡ Powered by Google Gemini 3.7 Flash"
        versionLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        versionLabel?.textColor = .tertiaryLabel
        versionLabel?.textAlignment = .center
        versionLabel?.numberOfLines = 2
    }
    
    private func setupTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func animateCardsEntrance() {
        let cards = [appearanceCard, aiSettingsCard, dataManagementCard].compactMap { $0 }
        for (index, card) in cards.enumerated() {
            card.alpha = 0.0
            card.transform = CGAffineTransform(translationX: 0, y: 26)
            
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.08, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                card.alpha = 1.0
                card.transform = .identity
            }, completion: nil)
        }
    }
    
    private func loadCurrentSettings() {
        themeSegmentedControl?.selectedSegmentIndex = UserDefaultsManager.shared.themeStyle
        aiSwitch?.isOn = UserDefaultsManager.shared.isAIEnabled
        apiKeyTextField?.text = UserDefaultsManager.shared.customAPIKey
    }
    
    // MARK: - IBActions
    
    @IBAction func themeChanged(_ sender: UISegmentedControl) {
        HapticHelper.selection()
        UserDefaultsManager.shared.themeStyle = sender.selectedSegmentIndex
        showToast(message: "Theme Updated!", icon: "paintpalette.fill", tintColor: .systemPurple)
    }
    
    @IBAction func aiSwitchChanged(_ sender: UISwitch) {
        HapticHelper.lightImpact()
        UserDefaultsManager.shared.isAIEnabled = sender.isOn
        showToast(
            message: sender.isOn ? "Gemini AI Enabled" : "AI Features Disabled",
            icon: sender.isOn ? "sparkles" : "xmark.circle",
            tintColor: sender.isOn ? .systemPurple : .systemGray
        )
    }
    
    @IBAction func saveApiKeyTapped(_ sender: UIButton) {
        HapticHelper.success()
        let key = apiKeyTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaultsManager.shared.customAPIKey = key?.isEmpty == true ? nil : key
        view.endEditing(true)
        showToast(message: "Gemini API Key Saved!", icon: "key.fill", tintColor: .systemGreen)
    }
    
    @IBAction func loadSampleDataTapped(_ sender: UIButton) {
        HapticHelper.success()
        CoreDataManager.shared.createSampleDataIfEmpty()
        showToast(message: "Sample Study Data Loaded!", icon: "arrow.clockwise.circle.fill", tintColor: .systemBlue)
    }
    
    @IBAction func resetAllDataTapped(_ sender: UIButton) {
        HapticHelper.warning()
        showConfirmationAlert(
            title: "Reset All Study Data?",
            message: "This will permanently clear all courses, modules, lessons, and AI summaries from Core Data.",
            confirmTitle: "Reset All",
            isDestructive: true,
            onConfirm: { [weak self] in
                let courses = CoreDataManager.shared.fetchCourses()
                courses.forEach { CoreDataManager.shared.deleteCourse($0) }
                self?.showToast(message: "All Data Cleared.", icon: "trash.fill", tintColor: .systemRed)
            }
        )
    }
}

