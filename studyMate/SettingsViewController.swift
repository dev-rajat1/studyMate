//
//  SettingsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 4 — Clean, Professional Native iOS InsetGrouped Settings.
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
        tableView.rowHeight = 52
        tableView.estimatedRowHeight = 52
        
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "APPEARANCE"
        case 1: return "AI STUDY ENGINE"
        case 2: return "DATA MANAGEMENT"
        case 3: return "ABOUT"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "CleanSettingsCell")
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.detailTextLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            // Theme: Light / Dark / System
            cell.textLabel?.text = "Theme"
            let segment = UISegmentedControl(items: ["Light", "Dark", "System"])
            // Map: 1 -> Light (idx 0), 2 -> Dark (idx 1), 0 -> System (idx 2)
            let current = UserDefaultsManager.shared.themeStyle
            if current == 1 { segment.selectedSegmentIndex = 0 }
            else if current == 2 { segment.selectedSegmentIndex = 1 }
            else { segment.selectedSegmentIndex = 2 }
            
            segment.selectedSegmentTintColor = .systemPurple
            segment.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .selected)
            segment.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
            segment.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
            segment.sizeToFit()
            cell.accessoryView = segment
            
        case 1:
            // AI Study Engine Toggle
            cell.textLabel?.text = "AI Study Assistant"
            let aiSwitch = UISwitch()
            aiSwitch.isOn = UserDefaultsManager.shared.isAIEnabled
            aiSwitch.onTintColor = .systemPurple
            aiSwitch.addTarget(self, action: #selector(aiToggleChanged(_:)), for: .valueChanged)
            cell.accessoryView = aiSwitch
            
        case 2:
            // Clear All Data
            cell.textLabel?.text = "Clear All Data"
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            cell.selectionStyle = .default
            cell.accessoryType = .none
            
        case 3:
            // App Version
            cell.textLabel?.text = "App Version"
            cell.detailTextLabel?.text = "1.0.0"
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 && indexPath.row == 0 {
            confirmClearData()
        }
    }
    
    // MARK: - Handlers
    @objc private func themeChanged(_ sender: UISegmentedControl) {
        HapticHelper.selection()
        // Map: idx 0 -> Light (1), idx 1 -> Dark (2), idx 2 -> System (0)
        let newStyle: Int
        if sender.selectedSegmentIndex == 0 { newStyle = 1 }
        else if sender.selectedSegmentIndex == 1 { newStyle = 2 }
        else { newStyle = 0 }
        
        UserDefaultsManager.shared.themeStyle = newStyle
        showToast(message: "Theme Updated", icon: "paintpalette.fill", tintColor: .systemPurple)
    }
    
    @objc private func aiToggleChanged(_ sender: UISwitch) {
        HapticHelper.lightImpact()
        UserDefaultsManager.shared.isAIEnabled = sender.isOn
        showToast(
            message: sender.isOn ? "AI Engine Enabled" : "AI Engine Disabled",
            icon: sender.isOn ? "sparkles" : "xmark.circle",
            tintColor: sender.isOn ? .systemPurple : .systemGray
        )
    }
    
    private func confirmClearData() {
        HapticHelper.warning()
        showConfirmationAlert(
            title: "Clear All Study Data?",
            message: "This will permanently delete all courses, modules, lessons, notes, and AI summaries.",
            confirmTitle: "Clear All",
            isDestructive: true,
            onConfirm: { [weak self] in
                let courses = CoreDataManager.shared.fetchCourses()
                courses.forEach { CoreDataManager.shared.deleteCourse($0) }
                HapticHelper.success()
                self?.showToast(message: "All Data Cleared", icon: "trash.fill", tintColor: .systemRed)
            }
        )
    }
}
