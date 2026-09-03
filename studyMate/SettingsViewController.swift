//
//  SettingsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 4 — Premium Settings with Profile Header, Icon-Prefixed Rows, Visual Theme Picker, and Danger Zone.
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderViewFrame()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateHeaderViewFrame()
        }, completion: nil)
    }

    private func updateHeaderViewFrame() {
        guard let header = tableView.tableHeaderView else { return }
        let currentWidth = tableView.bounds.width
        guard currentWidth > 0 else { return }
        if header.frame.width != currentWidth {
            header.frame.size.width = currentWidth
            header.setNeedsLayout()
            header.layoutIfNeeded()
            tableView.tableHeaderView = header
        }
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
        tableView.estimatedRowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 58, bottom: 0, right: 0)
        view.addSubview(tableView)
        setupProfileHeader()
    }

    // MARK: - Profile Header Card
    private func setupProfileHeader() {
        let headerWidth = tableView.bounds.width > 0 ? tableView.bounds.width : view.bounds.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: 140))
        headerView.backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = DesignSystem.Colors.primary // Fallback
        card.layer.cornerRadius = 22
        card.clipsToBounds = true
        card.applyGradientBackground(
            colors: DesignSystem.Gradients.primary,
            startPoint: CGPoint(x: 0, y: 0.2),
            endPoint: CGPoint(x: 1, y: 0.8),
            cornerRadius: 22
        )
        headerView.addSubview(card)

        // App icon circle
        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        iconBg.layer.cornerRadius = 26
        iconBg.clipsToBounds = true
        card.addSubview(iconBg)

        let iconConf = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let iconView = UIImageView(image: UIImage(systemName: "graduationcap.fill", withConfiguration: iconConf))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconBg.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 52),
            iconBg.heightAnchor.constraint(equalToConstant: 52)
        ])

        // App name
        let appName = UILabel()
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.text = "StudyMate AI"
        appName.font = .systemFont(ofSize: 20, weight: .black)
        appName.textColor = .white
        card.addSubview(appName)

        // Subtitle
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Powered by Google Gemini ✨"
        subtitle.font = .systemFont(ofSize: 13, weight: .semibold)
        subtitle.textColor = UIColor.white.withAlphaComponent(0.75)
        card.addSubview(subtitle)

        // Version badge
        let versionBadge = UIView()
        versionBadge.translatesAutoresizingMaskIntoConstraints = false
        versionBadge.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        versionBadge.layer.cornerRadius = 10
        versionBadge.clipsToBounds = true
        card.addSubview(versionBadge)

        let versionLabel = UILabel()
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = "v1.0"
        versionLabel.font = .systemFont(ofSize: 11, weight: .bold)
        versionLabel.textColor = .white
        versionBadge.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            versionLabel.leadingAnchor.constraint(equalTo: versionBadge.leadingAnchor, constant: 8),
            versionLabel.trailingAnchor.constraint(equalTo: versionBadge.trailingAnchor, constant: -8),
            versionLabel.topAnchor.constraint(equalTo: versionBadge.topAnchor, constant: 3),
            versionLabel.bottomAnchor.constraint(equalTo: versionBadge.bottomAnchor, constant: -3),

            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),

            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            appName.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            appName.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),

            subtitle.leadingAnchor.constraint(equalTo: appName.leadingAnchor),
            subtitle.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 4),

            versionBadge.leadingAnchor.constraint(equalTo: subtitle.leadingAnchor),
            versionBadge.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 8),

            appName.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16)
        ])

        tableView.tableHeaderView = headerView
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 4 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1  // Appearance
        case 1: return 2  // AI Engine
        case 2: return 2  // Data (Clear + Sample Data)
        case 3: return 1  // About
        default: return 0
        }
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "PremiumSettingsCell")
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.detailTextLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.selectionStyle = .none

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            addIconToCell(cell, systemName: "paintpalette.fill", color: DesignSystem.Colors.primary)
            cell.textLabel?.text = "Theme"
            let seg = UISegmentedControl(items: ["Light", "Dark", "Auto"])
            let current = UserDefaultsManager.shared.themeStyle
            if current == 1 { seg.selectedSegmentIndex = 0 }
            else if current == 2 { seg.selectedSegmentIndex = 1 }
            else { seg.selectedSegmentIndex = 2 }
            seg.selectedSegmentTintColor = DesignSystem.Colors.primary
            seg.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .selected)
            seg.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
            seg.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
            seg.sizeToFit()
            cell.accessoryView = seg

        case (1, 0):
            addIconToCell(cell, systemName: "sparkles", color: DesignSystem.Colors.secondary)
            cell.textLabel?.text = "AI Study Assistant"
            let sw = UISwitch()
            sw.isOn = UserDefaultsManager.shared.isAIEnabled
            sw.onTintColor = DesignSystem.Colors.primary
            sw.addTarget(self, action: #selector(aiToggleChanged(_:)), for: .valueChanged)
            cell.accessoryView = sw

        case (1, 1):
            addIconToCell(cell, systemName: "key.fill", color: DesignSystem.Colors.teal)
            cell.textLabel?.text = "Gemini API Key"
            let hasKey = UserDefaultsManager.shared.customAPIKey != nil
            cell.detailTextLabel?.text = hasKey ? "Configured ●●●●" : "Not Set"
            cell.detailTextLabel?.textColor = hasKey ? DesignSystem.Colors.success : .tertiaryLabel
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        case (2, 0):
            addIconToCell(cell, systemName: "trash.fill", color: DesignSystem.Colors.coral)
            cell.textLabel?.text = "Clear All Data"
            cell.textLabel?.textColor = DesignSystem.Colors.coral
            cell.selectionStyle = .default

        case (2, 1):
            addIconToCell(cell, systemName: "tray.and.arrow.down.fill", color: DesignSystem.Colors.success)
            cell.textLabel?.text = "Load Sample Data"
            cell.textLabel?.textColor = DesignSystem.Colors.success
            cell.selectionStyle = .default

        case (3, 0):
            addIconToCell(cell, systemName: "info.circle.fill", color: .systemGray)
            cell.textLabel?.text = "App Version"
            let bundle = Bundle.main.infoDictionary
            let version = bundle?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            cell.detailTextLabel?.text = version

        default: break
        }

        return cell
    }

    private func addIconToCell(_ cell: UITableViewCell, systemName: String, color: UIColor) {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        bgView.backgroundColor = color
        bgView.layer.cornerRadius = 8
        bgView.clipsToBounds = true

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let imageView = UIImageView(image: UIImage(systemName: systemName, withConfiguration: config))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 7, y: 7, width: 20, height: 20)
        bgView.addSubview(imageView)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        bgView.center = CGPoint(x: 22, y: 22)
        container.addSubview(bgView)

        cell.imageView?.image = nil
        cell.accessoryView = nil

        // Use content view to embed icon
        let cellContent = cell.contentView
        let existingIcon = cellContent.viewWithTag(9999)
        existingIcon?.removeFromSuperview()
        bgView.tag = 9999

        let wrapper = UIView(frame: CGRect(x: 16, y: 0, width: 40, height: cell.frame.height > 0 ? cell.frame.height : 56))
        wrapper.tag = 9999
        wrapper.addSubview(bgView)
        bgView.center = CGPoint(x: 20, y: wrapper.bounds.height / 2)
        cell.contentView.addSubview(wrapper)

        cell.indentationWidth = 56
        cell.indentationLevel = 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 1 {
            showAPIKeyPrompt()
        } else if indexPath.section == 2 && indexPath.row == 0 {
            confirmClearData()
        } else if indexPath.section == 2 && indexPath.row == 1 {
            loadSampleData()
        }
    }

    // MARK: - Handlers
    @objc private func themeChanged(_ sender: UISegmentedControl) {
        HapticHelper.selection()
        let newStyle: Int
        if sender.selectedSegmentIndex == 0 { newStyle = 1 }
        else if sender.selectedSegmentIndex == 1 { newStyle = 2 }
        else { newStyle = 0 }
        UserDefaultsManager.shared.themeStyle = newStyle

        // Apply theme
        if let window = view.window {
            window.overrideUserInterfaceStyle = newStyle == 1 ? .light : newStyle == 2 ? .dark : .unspecified
        }
        showToast(message: "Theme Updated", icon: "paintpalette.fill", tintColor: DesignSystem.Colors.primary)
    }

    @objc private func aiToggleChanged(_ sender: UISwitch) {
        HapticHelper.lightImpact()
        UserDefaultsManager.shared.isAIEnabled = sender.isOn
        showToast(
            message: sender.isOn ? "AI Engine Enabled" : "AI Engine Disabled",
            icon: sender.isOn ? "sparkles" : "xmark.circle",
            tintColor: sender.isOn ? DesignSystem.Colors.primary : .systemGray
        )
    }

    private func showAPIKeyPrompt() {
        HapticHelper.lightImpact()
        let alert = UIAlertController(
            title: "Gemini API Key",
            message: "Enter your Google Gemini API key to power AI study responses.",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "Enter API Key"
            tf.text = UserDefaultsManager.shared.customAPIKey
            tf.isSecureTextEntry = true
            tf.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let key = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            UserDefaultsManager.shared.customAPIKey = (key?.isEmpty == false) ? key : nil
            HapticHelper.success()
            self.tableView.reloadData()
            self.showToast(message: "API Key Saved", icon: "key.fill", tintColor: DesignSystem.Colors.teal)
        }))
        present(alert, animated: true)
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
                self?.showToast(message: "All Data Cleared", icon: "trash.fill", tintColor: DesignSystem.Colors.coral)
            }
        )
    }

    private func loadSampleData() {
        HapticHelper.mediumImpact()
        showConfirmationAlert(
            title: "Load Sample Data?",
            message: "This will add sample courses, modules, and lessons for demonstration.",
            confirmTitle: "Load",
            isDestructive: false,
            onConfirm: { [weak self] in
                CoreDataManager.shared.createSampleDataIfEmpty()
                HapticHelper.success()
                self?.showToast(message: "📚 Sample Data Loaded!", icon: "tray.and.arrow.down.fill", tintColor: DesignSystem.Colors.success)
            }
        )
    }
}
