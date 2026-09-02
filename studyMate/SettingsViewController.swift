//
//  SettingsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 4 — Full-Screen InsetGrouped Settings table with Theme switcher, AI engine config, and Data management.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Properties
    private var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.keyboardDismissMode = .interactive
        
        // Footer View
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        let footerLabel = UILabel(frame: CGRect(x: 16, y: 20, width: view.bounds.width - 32, height: 40))
        footerLabel.text = "StudyMate AI v1.0 • Built with UIKit & CoreData\nDesigned for Deep Focus & Active Recall 🚀"
        footerLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        footerLabel.textColor = .tertiaryLabel
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 2
        footerLabel.autoresizingMask = [.flexibleWidth]
        footerView.addSubview(footerLabel)
        tableView.tableFooterView = footerView
        
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Appearance
        case 1: return 3 // AI Engine (Toggle, API Key, Model)
        case 2: return 2 // Data Management (Seed, Reset)
        case 3: return 2 // About
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "🎨 APPEARANCE & THEME"
        case 1: return "🤖 AI STUDY ENGINE"
        case 2: return "📦 CURRICULUM & DATA MANAGEMENT"
        case 3: return "ℹ️ ABOUT STUDYMATE"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SettingsCell")
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.selectionStyle = .default
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        cell.detailTextLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        switch (indexPath.section, indexPath.row) {
        // Section 0: Theme
        case (0, 0):
            cell.textLabel?.text = "Interface Theme"
            cell.detailTextLabel?.text = "Select your preferred color appearance"
            cell.selectionStyle = .none
            
            let segment = UISegmentedControl(items: ["System", "Light", "Dark"])
            segment.selectedSegmentIndex = UserDefaultsManager.shared.themeStyle
            segment.selectedSegmentTintColor = .systemPurple
            segment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11, weight: .bold)], for: .selected)
            segment.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: 11, weight: .medium)], for: .normal)
            segment.addTarget(self, action: #selector(themeSegmentChanged(_:)), for: .valueChanged)
            segment.sizeToFit()
            cell.accessoryView = segment
            
        // Section 1: AI Engine
        case (1, 0):
            cell.textLabel?.text = "AI Study Tutor"
            cell.detailTextLabel?.text = "Enable interactive Q&A, summaries & quizzes"
            cell.selectionStyle = .none
            
            let toggle = UISwitch()
            toggle.isOn = UserDefaultsManager.shared.isAIEnabled
            toggle.onTintColor = .systemPurple
            toggle.addTarget(self, action: #selector(aiToggleChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            
        case (1, 1):
            cell.textLabel?.text = "Gemini API Key"
            let hasKey = UserDefaultsManager.shared.customAPIKey != nil
            cell.detailTextLabel?.text = hasKey ? "●●●●●●●●●●●● (Custom Key Active)" : "Default DeepMind API Key Configured"
            cell.accessoryType = .disclosureIndicator
            
        case (1, 2):
            cell.textLabel?.text = "AI Intelligence Model"
            cell.detailTextLabel?.text = UserDefaultsManager.shared.aiModelName
            cell.accessoryType = .none
            cell.selectionStyle = .none
            
            let badge = UILabel()
            badge.text = "⚡ Flash 3.7"
            badge.font = .systemFont(ofSize: 12, weight: .bold)
            badge.textColor = .systemPurple
            badge.sizeToFit()
            cell.accessoryView = badge
            
        // Section 2: Data Management
        case (2, 0):
            cell.textLabel?.text = "📥 Seed Sample Curriculum"
            cell.detailTextLabel?.text = "Add demo courses (iOS Dev, Algorithms, System Design)"
            cell.accessoryType = .disclosureIndicator
            
        case (2, 1):
            cell.textLabel?.text = "🗑️ Clear All Study Data"
            cell.textLabel?.textColor = .systemRed
            cell.detailTextLabel?.text = "Permanently delete all courses, modules, and notes"
            cell.accessoryType = .disclosureIndicator
            
        // Section 3: About
        case (3, 0):
            cell.textLabel?.text = "App Version"
            cell.detailTextLabel?.text = "1.0.0 • Production Build"
            cell.selectionStyle = .none
            
        case (3, 1):
            cell.textLabel?.text = "AI Architecture"
            cell.detailTextLabel?.text = "Context-Grounded RAG with Note Synthesis"
            cell.selectionStyle = .none
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            showAPIKeyPrompt()
            
        case (2, 0):
            seedSampleData()
            
        case (2, 1):
            confirmResetAllData()
            
        default:
            break
        }
    }
    
    // MARK: - Actions & Handlers
    @objc private func themeSegmentChanged(_ sender: UISegmentedControl) {
        HapticHelper.selection()
        UserDefaultsManager.shared.themeStyle = sender.selectedSegmentIndex
        showToast(message: "Theme Updated!", icon: "paintpalette.fill", tintColor: .systemPurple)
    }
    
    @objc private func aiToggleChanged(_ sender: UISwitch) {
        HapticHelper.lightImpact()
        UserDefaultsManager.shared.isAIEnabled = sender.isOn
        showToast(
            message: sender.isOn ? "AI Study Assistant Enabled" : "AI Assistant Disabled",
            icon: sender.isOn ? "sparkles" : "xmark.circle",
            tintColor: sender.isOn ? .systemPurple : .systemGray
        )
    }
    
    private func showAPIKeyPrompt() {
        HapticHelper.lightImpact()
        let alert = UIAlertController(
            title: "Gemini API Key",
            message: "Enter your Google Gemini API key to power study tutor responses.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Enter API Key"
            textField.text = UserDefaultsManager.shared.customAPIKey
            textField.isSecureTextEntry = true
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save Key", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let key = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            UserDefaultsManager.shared.customAPIKey = (key?.isEmpty == false) ? key : nil
            HapticHelper.success()
            self.tableView.reloadData()
            self.showToast(message: "API Key Saved Successfully!", icon: "key.fill", tintColor: .systemGreen)
        }))
        
        present(alert, animated: true)
    }
    
    private func seedSampleData() {
        HapticHelper.success()
        CoreDataManager.shared.createSampleDataIfEmpty()
        showToast(message: "Sample Study Data Loaded!", icon: "arrow.clockwise.circle.fill", tintColor: .systemBlue)
    }
    
    private func confirmResetAllData() {
        HapticHelper.warning()
        showConfirmationAlert(
            title: "Clear All Study Data?",
            message: "This will permanently remove all courses, chapters, lessons, notes, and AI summaries from your device. This action cannot be undone.",
            confirmTitle: "Reset All",
            isDestructive: true,
            onConfirm: { [weak self] in
                let courses = CoreDataManager.shared.fetchCourses()
                courses.forEach { CoreDataManager.shared.deleteCourse($0) }
                HapticHelper.success()
                self?.showToast(message: "All Study Data Cleared.", icon: "trash.fill", tintColor: .systemRed)
            }
        )
    }
}
