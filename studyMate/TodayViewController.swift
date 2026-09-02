//
//  TodayViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 1 — Interactive Multi-Timeframe Study Planner (Today, Tomorrow, Weekly, Monthly, All Tasks).
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    private var currentTimeframe: StudyTimeframe = .today
    private var filteredTasks: [Task] = []
    private let timeframeSegmentedControl = UISegmentedControl(items: ["📅 Today", "🌅 Tomorrow", "📆 Week", "🗓️ Month", "📋 All"])
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasksForCurrentTimeframe()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Study Planner"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        if tableView == nil {
            let tv = UITableView(frame: view.bounds, style: .plain)
            tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(tv)
            tableView = tv
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 28, right: 0)
    }
    
    // MARK: - Header with Timeframe Filter & Progress Card
    private func setupDashboardHeader() {
        let count = filteredTasks.count
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        headerView.backgroundColor = .clear
        
        // 1. Timeframe Switcher
        timeframeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        timeframeSegmentedControl.selectedSegmentIndex = currentTimeframe.rawValue
        timeframeSegmentedControl.selectedSegmentTintColor = .systemPurple
        timeframeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 12, weight: .bold)], for: .selected)
        timeframeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
        timeframeSegmentedControl.addTarget(self, action: #selector(timeframeChanged(_:)), for: .valueChanged)
        headerView.addSubview(timeframeSegmentedControl)
        
        // 2. Hero Progress Card
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 18)
        headerView.addSubview(card)
        
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .equalSpacing
        topStack.alignment = .center
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Badge
        let badgePill = UIView()
        badgePill.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        badgePill.layer.cornerRadius = 8
        badgePill.clipsToBounds = true
        
        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = "🎯 \(currentTimeframe.title.uppercased()) TARGET"
        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .systemPurple
        badgePill.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            badgeLabel.leadingAnchor.constraint(equalTo: badgePill.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgePill.trailingAnchor, constant: -8),
            badgeLabel.topAnchor.constraint(equalTo: badgePill.topAnchor, constant: 4),
            badgeLabel.bottomAnchor.constraint(equalTo: badgePill.bottomAnchor, constant: -4)
        ])
        
        let dateLabel = UILabel()
        dateLabel.text = "🗓 \(Date().formattedGreetingDate())"
        dateLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        dateLabel.textColor = .secondaryLabel
        
        topStack.addArrangedSubview(badgePill)
        topStack.addArrangedSubview(dateLabel)
        card.addSubview(topStack)
        
        // Title
        let greetingLabel = UILabel()
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        if count == 0 {
            greetingLabel.text = "🎉 All caught up for \(currentTimeframe.title.lowercased())!"
            greetingLabel.textColor = .systemGreen
        } else {
            greetingLabel.text = "⚡ \(count) \(count == 1 ? "Lesson" : "Lessons") Scheduled"
            greetingLabel.textColor = .label
        }
        greetingLabel.font = .systemFont(ofSize: 17, weight: .bold)
        card.addSubview(greetingLabel)
        
        // Subtitle
        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        switch currentTimeframe {
        case .today:
            subLabel.text = count == 0 ? "Great job! Review notes or check upcoming modules." : "Focus on high-priority items and check off lessons as you finish."
        case .tomorrow:
            subLabel.text = count == 0 ? "No immediate deadlines tomorrow. Relax or prepare ahead!" : "Get a head-start on tomorrow's lessons today."
        case .thisWeek:
            subLabel.text = "Keep a steady daily pace to conquer all weekly goals."
        case .thisMonth:
            subLabel.text = "Track your monthly academic momentum and master all topics."
        case .all:
            subLabel.text = "Complete curriculum roadmap across all enrolled subjects."
        }
        subLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 2
        card.addSubview(subLabel)
        
        NSLayoutConstraint.activate([
            // Segmented Control
            timeframeSegmentedControl.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            timeframeSegmentedControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            timeframeSegmentedControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            timeframeSegmentedControl.heightAnchor.constraint(equalToConstant: 34),
            
            // Card
            card.topAnchor.constraint(equalTo: timeframeSegmentedControl.bottomAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),
            
            topStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            topStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            topStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            greetingLabel.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            greetingLabel.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8),
            greetingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            subLabel.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            subLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Actions
    @objc private func timeframeChanged(_ sender: UISegmentedControl) {
        HapticHelper.lightImpact()
        if let selected = StudyTimeframe(rawValue: sender.selectedSegmentIndex) {
            currentTimeframe = selected
            loadTasksForCurrentTimeframe()
        }
    }
    
    // MARK: - Data Loading
    private func loadTasksForCurrentTimeframe() {
        filteredTasks = CoreDataManager.shared.fetchTasks(for: currentTimeframe)
        setupDashboardHeader()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        if filteredTasks.isEmpty {
            emptyStateLabel?.isHidden = false
            let msg: String
            switch currentTimeframe {
            case .today:
                msg = "No pending lessons due today.\nTap 'Tomorrow' or 'This Week' to plan ahead!"
            case .tomorrow:
                msg = "No lessons due tomorrow.\nYou are well ahead of schedule!"
            case .thisWeek:
                msg = "No lessons scheduled for this week.\nAdd lessons with deadlines in your Courses tab."
            case .thisMonth:
                msg = "No lessons due this month.\nEnjoy your free time or explore new topics!"
            case .all:
                msg = "No pending lessons found!\nCreate a new course or lesson to get started."
            }
            
            tableView.setEmptyState(
                iconName: "calendar.badge.clock",
                title: "🎉 Clear Schedule",
                message: msg
            )
        } else {
            emptyStateLabel?.isHidden = true
            tableView.removeEmptyState()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = filteredTasks[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleDone = { [weak self] in
                guard let self = self else { return }
                HapticHelper.success()
                CoreDataManager.shared.toggleTaskDone(task)
                self.loadTasksForCurrentTimeframe()
                self.showToast(message: "✅ Lesson Completed!", icon: "checkmark.circle.fill", tintColor: .systemGreen)
            }
            cell.animateGlideIn(delayIndex: indexPath.row)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = task.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        let topicName = task.topic?.title ?? "General"
        let courseName = task.topic?.course?.name ?? "Course"
        cell.detailTextLabel?.text = "📁 \(courseName) › \(topicName)"
        cell.accessoryType = .disclosureIndicator
        cell.animateGlideIn(delayIndex: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = filteredTasks[indexPath.row]
        HapticHelper.lightImpact()
        
        if let topic = task.topic {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tasksVC = storyboard.instantiateViewController(withIdentifier: "TasksListViewController") as? TasksListViewController {
                tasksVC.topic = topic
                navigationController?.pushViewController(tasksVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = filteredTasks[indexPath.row]
        
        let completeAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.toggleTaskDone(task)
            self.loadTasksForCurrentTimeframe()
            self.showToast(message: "🎉 Lesson Completed!", icon: "sparkles", tintColor: .systemGreen)
            completion(true)
        }
        completeAction.backgroundColor = .systemGreen
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}
