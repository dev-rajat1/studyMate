//
//  TodayViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 1 — Modern Interactive Study Planner (Today, Tomorrow, Weekly, Monthly, All)
//  Features: Custom Capsule Segment Control, Perfectly Proportioned Hero Card, and State-of-the-Art Empty State.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    private var currentTimeframe: StudyTimeframe = .today
    private var filteredTasks: [Task] = []
    
    // Modern Capsule Segmented Bar
    private let segmentContainer = UIView()
    private let timeframeSegmentedControl = UISegmentedControl(items: ["📅 Today", "🌅 Tomorrow", "📆 Week", "🗓️ Month", "📋 All"])
    
    // Empty State Dedicated Container
    private let emptyStateContainer = UIView()
    private let emptyStateIconContainer = UIView()
    private let emptyStateIconView = UIImageView()
    private let emptyStateTitleLabel = UILabel()
    private let emptyStateMsgLabel = UILabel()
    private let emptyStateExploreButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSegmentedBar()
        setupEmptyStateView()
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
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
    }
    
    // MARK: - Modern Capsule Segmented Control
    private func setupSegmentedBar() {
        segmentContainer.translatesAutoresizingMaskIntoConstraints = false
        segmentContainer.backgroundColor = .clear
        
        timeframeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        timeframeSegmentedControl.selectedSegmentIndex = currentTimeframe.rawValue
        timeframeSegmentedControl.backgroundColor = UIColor.secondarySystemGroupedBackground
        timeframeSegmentedControl.selectedSegmentTintColor = .systemPurple
        timeframeSegmentedControl.layer.cornerRadius = 12
        timeframeSegmentedControl.layer.masksToBounds = true
        timeframeSegmentedControl.layer.borderWidth = 1
        timeframeSegmentedControl.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        
        timeframeSegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ], for: .selected)
        
        timeframeSegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ], for: .normal)
        
        timeframeSegmentedControl.addTarget(self, action: #selector(timeframeChanged(_:)), for: .valueChanged)
        
        segmentContainer.addSubview(timeframeSegmentedControl)
        
        NSLayoutConstraint.activate([
            timeframeSegmentedControl.topAnchor.constraint(equalTo: segmentContainer.topAnchor, constant: 4),
            timeframeSegmentedControl.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 16),
            timeframeSegmentedControl.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor, constant: -16),
            timeframeSegmentedControl.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: -4),
            timeframeSegmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    // MARK: - Header with Proportional Hero Target Card
    private func setupDashboardHeader() {
        let count = filteredTasks.count
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 176))
        headerView.backgroundColor = .clear
        
        // 1. Add Segmented Bar
        headerView.addSubview(segmentContainer)
        segmentContainer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        
        // 2. Hero Progress Card with clean height & insets
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 18)
        headerView.addSubview(card)
        
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .equalSpacing
        topStack.alignment = .center
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Target Pill Badge
        let badgePill = UIView()
        badgePill.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        badgePill.layer.cornerRadius = 6
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
            badgeLabel.topAnchor.constraint(equalTo: badgePill.topAnchor, constant: 3),
            badgeLabel.bottomAnchor.constraint(equalTo: badgePill.bottomAnchor, constant: -3)
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
            subLabel.text = count == 0 ? "Great job! Review notes, test with AI quiz, or plan ahead." : "Focus on high-priority items and check off lessons as you finish."
        case .tomorrow:
            subLabel.text = count == 0 ? "No immediate deadlines tomorrow. Relax or prepare ahead!" : "Get a head-start on tomorrow's lessons today."
        case .thisWeek:
            subLabel.text = count == 0 ? "All weekly targets met! Outstanding consistency." : "Keep a steady daily pace to conquer all weekly goals."
        case .thisMonth:
            subLabel.text = count == 0 ? "Monthly curriculum completed! Great momentum." : "Track your monthly academic roadmap and master all topics."
        case .all:
            subLabel.text = count == 0 ? "No pending lessons found! Create a course to start learning." : "Complete curriculum roadmap across all enrolled subjects."
        }
        subLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 2
        card.addSubview(subLabel)
        
        NSLayoutConstraint.activate([
            // Segment Container
            segmentContainer.topAnchor.constraint(equalTo: headerView.topAnchor),
            segmentContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            segmentContainer.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            segmentContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Hero Card
            card.topAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 4),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),
            
            topStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            topStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            topStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            greetingLabel.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            greetingLabel.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 6),
            greetingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            subLabel.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 3),
            subLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Premium Empty State View
    private func setupEmptyStateView() {
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainer.backgroundColor = .clear
        emptyStateContainer.isHidden = true
        view.addSubview(emptyStateContainer)
        
        // 1. Glowing Circular Badge
        emptyStateIconContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateIconContainer.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        emptyStateIconContainer.layer.cornerRadius = 36
        emptyStateIconContainer.clipsToBounds = false
        
        emptyStateIconContainer.layer.shadowColor = UIColor.systemPurple.cgColor
        emptyStateIconContainer.layer.shadowOpacity = 0.25
        emptyStateIconContainer.layer.shadowOffset = CGSize(width: 0, height: 6)
        emptyStateIconContainer.layer.shadowRadius = 16
        
        emptyStateIconView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateIconView.contentMode = .scaleAspectFit
        emptyStateIconView.tintColor = .systemPurple
        emptyStateIconContainer.addSubview(emptyStateIconView)
        
        // 2. Title Label
        emptyStateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emptyStateTitleLabel.textColor = .label
        emptyStateTitleLabel.textAlignment = .center
        
        // 3. Subtitle / Message Label
        emptyStateMsgLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateMsgLabel.font = .systemFont(ofSize: 13, weight: .regular)
        emptyStateMsgLabel.textColor = .secondaryLabel
        emptyStateMsgLabel.textAlignment = .center
        emptyStateMsgLabel.numberOfLines = 0
        
        // 4. Action Button
        emptyStateExploreButton.translatesAutoresizingMaskIntoConstraints = false
        emptyStateExploreButton.setTitle("📚 Explore Subjects & Modules", for: .normal)
        emptyStateExploreButton.setTitleColor(.white, for: .normal)
        emptyStateExploreButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        emptyStateExploreButton.backgroundColor = .systemPurple
        emptyStateExploreButton.layer.cornerRadius = 20
        emptyStateExploreButton.clipsToBounds = false
        emptyStateExploreButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        emptyStateExploreButton.layer.shadowColor = UIColor.systemPurple.cgColor
        emptyStateExploreButton.layer.shadowOpacity = 0.35
        emptyStateExploreButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        emptyStateExploreButton.layer.shadowRadius = 12
        
        emptyStateExploreButton.addTarget(self, action: #selector(exploreCoursesTapped), for: .touchUpInside)
        
        // Assemble Stack
        let stack = UIStackView(arrangedSubviews: [
            emptyStateIconContainer,
            emptyStateTitleLabel,
            emptyStateMsgLabel,
            emptyStateExploreButton
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(16, after: emptyStateIconContainer)
        stack.setCustomSpacing(18, after: emptyStateMsgLabel)
        
        emptyStateContainer.addSubview(stack)
        
        NSLayoutConstraint.activate([
            emptyStateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            emptyStateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            emptyStateContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 190),
            emptyStateContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            stack.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: emptyStateContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor),
            
            emptyStateIconContainer.widthAnchor.constraint(equalToConstant: 72),
            emptyStateIconContainer.heightAnchor.constraint(equalToConstant: 72),
            
            emptyStateIconView.centerXAnchor.constraint(equalTo: emptyStateIconContainer.centerXAnchor),
            emptyStateIconView.centerYAnchor.constraint(equalTo: emptyStateIconContainer.centerYAnchor),
            emptyStateIconView.widthAnchor.constraint(equalToConstant: 34),
            emptyStateIconView.heightAnchor.constraint(equalToConstant: 34),
            
            emptyStateExploreButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func exploreCoursesTapped() {
        HapticHelper.mediumImpact()
        tabBarController?.selectedIndex = 1 // Switch directly to Courses Tab
    }
    
    // MARK: - Actions
    @objc private func timeframeChanged(_ sender: UISegmentedControl) {
        HapticHelper.lightImpact()
        if let selected = StudyTimeframe(rawValue: sender.selectedSegmentIndex) {
            currentTimeframe = selected
            
            // Subtle spring reload animation
            UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.loadTasksForCurrentTimeframe()
            }, completion: nil)
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
            emptyStateContainer.isHidden = false
            emptyStateLabel?.isHidden = true
            
            let iconName: String
            let titleText: String
            let msgText: String
            
            switch currentTimeframe {
            case .today:
                iconName = "sparkles"
                titleText = "✨ Clean Study Slate!"
                msgText = "No pending lessons due today.\nEverything is complete and on track!"
            case .tomorrow:
                iconName = "sun.max.fill"
                titleText = "🌅 No Deadlines Tomorrow!"
                msgText = "You have zero lessons scheduled for tomorrow.\nTake a breather or get a head-start!"
            case .thisWeek:
                iconName = "checkmark.seal.fill"
                titleText = "📆 All Weekly Goals Met!"
                msgText = "You're completely on pace with this week's study plan.\nGreat consistency!"
            case .thisMonth:
                iconName = "calendar.badge.checkmark"
                titleText = "🗓️ Curriculum Up to Date!"
                msgText = "No lessons due for the rest of this month.\nExplore new subjects or review AI summaries."
            case .all:
                iconName = "books.vertical.fill"
                titleText = "📚 No Active Lessons Found!"
                msgText = "Create your first Course and add modules\nto start organizing your study roadmap."
            }
            
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
            emptyStateIconView.image = UIImage(systemName: iconName, withConfiguration: iconConfig)
            emptyStateTitleLabel.text = titleText
            emptyStateMsgLabel.text = msgText
            
            // Animate empty state entrance
            emptyStateContainer.alpha = 0
            emptyStateContainer.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            UIView.animate(withDuration: 0.35, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.emptyStateContainer.alpha = 1.0
                self.emptyStateContainer.transform = .identity
            }, completion: nil)
            
        } else {
            emptyStateContainer.isHidden = true
            emptyStateLabel?.isHidden = true
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
