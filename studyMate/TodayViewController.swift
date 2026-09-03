//
//  TodayViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 1 — Premium Study Planner with Gradient Hero Card, Streak Badge, Pill Segment Bar, and Animated Empty States.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: - Views
    var tableView: UITableView!
    var emptyStateLabel: UILabel?

    // MARK: - Properties
    private var currentTimeframe: StudyTimeframe = .today
    private var filteredTasks: [Task] = []
    
    // Search
    private var searchController: UISearchController!
    private var searchedTasks: [Task] = []
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    // Custom Pill Segment Container
    private let segmentScrollView = UIScrollView()
    private let pillStack = UIStackView()
    private var pillButtons: [UIButton] = []
    private let pillLabels = ["📅 Today", "🌅 Tomorrow", "📆 Week", "🗓️ Month", "📋 All"]
    private var activePillIndex: Int = 0

    // Empty State View
    private let emptyStateAreaGuide = UILayoutGuide()
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
        setupSearchController()
        setupPillSegmentBar()
        setupEmptyStateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasksForCurrentTimeframe()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDashboardHeaderFrame()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateDashboardHeaderFrame()
        }, completion: nil)
    }

    private func updateDashboardHeaderFrame() {
        guard let header = tableView.tableHeaderView else { return }
        let currentWidth = tableView.bounds.width
        guard currentWidth > 0 else { return }
        if header.frame.width != currentWidth {
            header.frame.size.width = currentWidth
            layoutPills()
            header.setNeedsLayout()
            header.layoutIfNeeded()
            tableView.tableHeaderView = header
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "Study Planner"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        let tv = UITableView(frame: view.bounds, style: .plain)
        tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tv)
        tableView = tv
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.backgroundColor = .systemGroupedBackground
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 90, right: 0)
    }
    
    // MARK: - Search Controller
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search upcoming lessons & tasks..."
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.tintColor = DesignSystem.Colors.primary
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    // MARK: - Multi-Timeframe Pill Bar (Horizontal Scroll)
    private func setupPillSegmentBar() {
        segmentScrollView.showsHorizontalScrollIndicator = false
        segmentScrollView.backgroundColor = .clear
        segmentScrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        pillStack.axis = .horizontal
        pillStack.spacing = 8
        pillStack.alignment = .center
        pillStack.distribution = .fillProportionally
        segmentScrollView.addSubview(pillStack)

        pillButtons.removeAll()
        for (index, title) in pillLabels.enumerated() {
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            btn.layer.cornerRadius = 16
            btn.layer.borderWidth = 1
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
            btn.tag = index
            btn.addTarget(self, action: #selector(pillTapped(_:)), for: .touchUpInside)

            if index == 0 {
                // Active pill styling
                btn.backgroundColor = DesignSystem.Colors.primary
                btn.setTitleColor(.white, for: .normal)
                btn.layer.borderColor = UIColor.clear.cgColor
                btn.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 16)
                DesignSystem.Shadow.applyGlow(to: btn.layer, color: DesignSystem.Colors.primary)
            } else {
                // Inactive pill styling
                btn.backgroundColor = .secondarySystemGroupedBackground
                btn.setTitleColor(.secondaryLabel, for: .normal)
                btn.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
            }

            pillButtons.append(btn)
            pillStack.addArrangedSubview(btn)
        }
    }

    private func layoutPills() {
        pillStack.frame = CGRect(x: 16, y: 0, width: 0, height: 44)
        pillStack.sizeToFit()
        segmentScrollView.contentSize = CGSize(width: pillStack.frame.width + 32, height: 44)
    }

    @objc private func pillTapped(_ sender: UIButton) {
        guard sender.tag != activePillIndex else { return }
        HapticHelper.lightImpact()

        // Update previous active button
        let prevBtn = pillButtons[activePillIndex]
        prevBtn.backgroundColor = .secondarySystemGroupedBackground
        prevBtn.setTitleColor(.secondaryLabel, for: .normal)
        prevBtn.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        prevBtn.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        prevBtn.layer.shadowOpacity = 0

        // Update newly tapped button
        activePillIndex = sender.tag
        sender.backgroundColor = DesignSystem.Colors.primary
        sender.setTitleColor(.white, for: .normal)
        sender.layer.borderColor = UIColor.clear.cgColor
        sender.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 16)
        DesignSystem.Shadow.applyGlow(to: sender.layer, color: DesignSystem.Colors.primary)

        // Scroll pill into view smoothly
        segmentScrollView.scrollRectToVisible(sender.frame.insetBy(dx: -20, dy: 0), animated: true)

        // Map index to StudyTimeframe
        currentTimeframe = StudyTimeframe(rawValue: sender.tag) ?? .today
        loadTasksForCurrentTimeframe()
    }

    // MARK: - Dynamic Hero Greeting Card
    private func setupDashboardHeader() {
        let (coursesCount, _, totalTasks, completedTasks, _) = CoreDataManager.shared.getAppStats()
        let pct = totalTasks > 0 ? Float(completedTasks) / Float(totalTasks) : 0.0

        let headerWidth = tableView.bounds.width > 0 ? tableView.bounds.width : view.bounds.width
        let headerHeight: CGFloat = 246
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight))
        headerView.backgroundColor = .clear

        // Add segment pill bar to header
        segmentScrollView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(segmentScrollView)

        // Hero Card (Dynamic Time Greeting)
        let heroCard = UIView()
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.applyCardStyle(cornerRadius: 20)
        heroCard.clipsToBounds = true
        heroCard.backgroundColor = DesignSystem.Colors.navy
        heroCard.applyGradientBackground(
            colors: DesignSystem.Gradients.hero,
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 1),
            cornerRadius: 20
        )
        headerView.addSubview(heroCard)

        // Greeting Header
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        switch hour {
        case 5..<12: greeting = "Good Morning ☀️"
        case 12..<17: greeting = "Good Afternoon 🌤️"
        case 17..<21: greeting = "Good Evening 🌅"
        default: greeting = "Good Night 🌙"
        }

        let greetingLabel = UILabel()
        greetingLabel.text = greeting
        greetingLabel.font = .systemFont(ofSize: 22, weight: .black)
        greetingLabel.textColor = .white

        let subGreetingLabel = UILabel()
        let dueCount = filteredTasks.count
        subGreetingLabel.text = dueCount == 0 ? "All caught up for \(currentTimeframe.title)!" : "⚡ \(dueCount) \(dueCount == 1 ? "Lesson" : "Lessons") Scheduled"
        subGreetingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subGreetingLabel.textColor = UIColor.white.withAlphaComponent(0.80)

        let greetingStack = UIStackView.make(axis: .vertical, spacing: 3)
        greetingStack.addArrangedSubview(greetingLabel)
        greetingStack.addArrangedSubview(subGreetingLabel)

        // Progress Ring inside hero
        let progressRing = ProgressRingView(frame: CGRect(x: 0, y: 0, width: 62, height: 62))
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        progressRing.lineWidth = 6
        progressRing.configure(progress: CGFloat(pct), ringColor: DesignSystem.Colors.teal)

        let heroTopRow = UIStackView.make(axis: .horizontal, spacing: 12, alignment: .center)
        heroTopRow.addArrangedSubview(greetingStack)
        heroTopRow.addArrangedSubview(progressRing)
        NSLayoutConstraint.activate([
            progressRing.widthAnchor.constraint(equalToConstant: 62),
            progressRing.heightAnchor.constraint(equalToConstant: 62)
        ])

        // Hero Stats Bar: Courses enrolled & overall completion rate
        let coursesStat = buildHeroPill(icon: "book.closed.fill", text: "\(coursesCount) Courses")
        let completedStat = buildHeroPill(icon: "checkmark.circle.fill", text: "\(completedTasks)/\(totalTasks) Done")
        let paceStat = buildHeroPill(icon: "chart.line.uptrend.xyaxis", text: "\(Int(pct * 100))% Mastered")

        let statsBar = UIStackView.make(axis: .horizontal, spacing: 8, alignment: .center, distribution: .fillEqually)
        statsBar.addArrangedSubview(coursesStat)
        statsBar.addArrangedSubview(completedStat)
        statsBar.addArrangedSubview(paceStat)

        let mainStack = UIStackView.make(axis: .vertical, spacing: 14)
        mainStack.addArrangedSubview(heroTopRow)
        mainStack.addArrangedSubview(statsBar)
        heroCard.addSubview(mainStack)

        NSLayoutConstraint.activate([
            segmentScrollView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4),
            segmentScrollView.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            segmentScrollView.trailingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            segmentScrollView.heightAnchor.constraint(equalToConstant: 44),

            heroCard.topAnchor.constraint(equalTo: segmentScrollView.bottomAnchor, constant: 10),
            heroCard.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            heroCard.trailingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            heroCard.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),

            mainStack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            mainStack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),
            mainStack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 18),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: heroCard.bottomAnchor, constant: -16)
        ])

        tableView.tableHeaderView = headerView
    }

    private func buildHeroPill(icon: String, text: String) -> UIView {
        let hStack = UIStackView.make(axis: .horizontal, spacing: 6)
        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = UIColor.white.withAlphaComponent(0.6)
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.9)
        hStack.addArrangedSubview(img)
        hStack.addArrangedSubview(lbl)
        return hStack
    }

    // MARK: - Premium Empty State View
    private func setupEmptyStateView() {
        view.addLayoutGuide(emptyStateAreaGuide)

        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainer.backgroundColor = .clear
        emptyStateContainer.isHidden = true
        view.addSubview(emptyStateContainer)

        emptyStateIconContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateIconContainer.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.12)
        emptyStateIconContainer.layer.cornerRadius = 38
        emptyStateIconContainer.clipsToBounds = false
        emptyStateIconContainer.layer.shadowColor = DesignSystem.Colors.primary.cgColor
        emptyStateIconContainer.layer.shadowOpacity = 0.28
        emptyStateIconContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        emptyStateIconContainer.layer.shadowRadius = 16

        emptyStateIconView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateIconView.contentMode = .scaleAspectFit
        emptyStateIconView.tintColor = DesignSystem.Colors.primary
        emptyStateIconContainer.addSubview(emptyStateIconView)

        emptyStateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emptyStateTitleLabel.textColor = .label
        emptyStateTitleLabel.textAlignment = .center

        emptyStateMsgLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateMsgLabel.font = .systemFont(ofSize: 14, weight: .regular)
        emptyStateMsgLabel.textColor = .secondaryLabel
        emptyStateMsgLabel.textAlignment = .center
        emptyStateMsgLabel.numberOfLines = 0

        emptyStateExploreButton.translatesAutoresizingMaskIntoConstraints = false
        emptyStateExploreButton.setTitle("📚 Explore Courses", for: .normal)
        emptyStateExploreButton.setTitleColor(.white, for: .normal)
        emptyStateExploreButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        emptyStateExploreButton.layer.cornerRadius = 22
        emptyStateExploreButton.clipsToBounds = false
        emptyStateExploreButton.contentEdgeInsets = UIEdgeInsets(top: 11, left: 22, bottom: 11, right: 22)
        emptyStateExploreButton.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 22)
        DesignSystem.Shadow.applyGlow(to: emptyStateExploreButton.layer, color: DesignSystem.Colors.primary)
        emptyStateExploreButton.addTarget(self, action: #selector(exploreCoursesTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            emptyStateIconContainer,
            emptyStateTitleLabel,
            emptyStateMsgLabel,
            emptyStateExploreButton
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.setCustomSpacing(14, after: emptyStateIconContainer)
        stack.setCustomSpacing(16, after: emptyStateMsgLabel)
        emptyStateContainer.addSubview(stack)

        let centerYConstraint = emptyStateContainer.centerYAnchor.constraint(equalTo: emptyStateAreaGuide.centerYAnchor)
        centerYConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            // Layout guide covers the visible region between bottom of greeting header and bottom tab bar
            emptyStateAreaGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 250),
            emptyStateAreaGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyStateAreaGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emptyStateAreaGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            emptyStateContainer.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateAreaGuide.leadingAnchor, constant: 24),
            emptyStateContainer.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateAreaGuide.trailingAnchor, constant: -24),
            emptyStateContainer.centerXAnchor.constraint(equalTo: emptyStateAreaGuide.centerXAnchor),
            centerYConstraint,
            emptyStateContainer.topAnchor.constraint(greaterThanOrEqualTo: emptyStateAreaGuide.topAnchor, constant: 12),
            emptyStateContainer.bottomAnchor.constraint(lessThanOrEqualTo: emptyStateAreaGuide.bottomAnchor, constant: -12),
            emptyStateContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 400),

            stack.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: emptyStateContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor),

            emptyStateIconContainer.widthAnchor.constraint(equalToConstant: 76),
            emptyStateIconContainer.heightAnchor.constraint(equalToConstant: 76),
            emptyStateIconView.centerXAnchor.constraint(equalTo: emptyStateIconContainer.centerXAnchor),
            emptyStateIconView.centerYAnchor.constraint(equalTo: emptyStateIconContainer.centerYAnchor),
            emptyStateIconView.widthAnchor.constraint(equalToConstant: 34),
            emptyStateIconView.heightAnchor.constraint(equalToConstant: 34),

            emptyStateExploreButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func exploreCoursesTapped() {
        HapticHelper.mediumImpact()
        tabBarController?.selectedIndex = 1
    }

    // MARK: - Data Loading
    private func loadTasksForCurrentTimeframe() {
        filteredTasks = CoreDataManager.shared.fetchTasks(for: currentTimeframe)
        if isSearching {
            filterContentForSearchText(searchController.searchBar.text!)
        }
        setupDashboardHeader()
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if filteredTasks.isEmpty {
            emptyStateContainer.isHidden = false
            emptyStateLabel?.isHidden = true
            tableView.isScrollEnabled = false

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
                msgText = "Zero lessons scheduled tomorrow.\nTake a breather or get a head-start!"
            case .thisWeek:
                iconName = "checkmark.seal.fill"
                titleText = "📆 All Weekly Goals Met!"
                msgText = "You're on pace with this week's study plan.\nGreat consistency!"
            case .thisMonth:
                iconName = "calendar.badge.checkmark"
                titleText = "🗓️ Curriculum Up to Date!"
                msgText = "No lessons due this month.\nExplore new subjects or review AI summaries."
            case .all:
                iconName = "books.vertical.fill"
                titleText = "📚 All Lessons Completed!"
                msgText = "Your curriculum is in perfect shape.\nHead to courses to add new subjects."
            }

            let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .bold)
            emptyStateIconView.image = UIImage(systemName: iconName, withConfiguration: config)
            emptyStateTitleLabel.text = titleText
            emptyStateMsgLabel.text = msgText

            emptyStateContainer.alpha = 0
            emptyStateContainer.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            UIView.animate(withDuration: 0.40, delay: 0.08, usingSpringWithDamping: 0.78, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.emptyStateContainer.alpha = 1.0
                self.emptyStateContainer.transform = .identity
            }
        } else {
            emptyStateContainer.isHidden = true
            emptyStateLabel?.isHidden = true
        }
        
        if isSearching && searchedTasks.isEmpty {
            emptyStateContainer.isHidden = true // Hide default empty state
            // Optionally, show a custom "No search results" state here if needed
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? searchedTasks.count : filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = isSearching ? searchedTasks[indexPath.row] : filteredTasks[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleDone = { [weak self] in
                guard let self = self else { return }
                HapticHelper.success()
                CoreDataManager.shared.toggleTaskDone(task)
                self.loadTasksForCurrentTimeframe()
                self.showToast(message: "✅ Lesson Completed!", icon: "checkmark.circle.fill", tintColor: DesignSystem.Colors.success)
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
        let task = isSearching ? searchedTasks[indexPath.row] : filteredTasks[indexPath.row]
        HapticHelper.lightImpact()

        let detailVC = TaskDetailViewController()
        detailVC.topic = task.topic
        detailVC.taskToEdit = task
        detailVC.onSaveCompleted = { [weak self] in
            self?.loadTasksForCurrentTimeframe()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = isSearching ? searchedTasks[indexPath.row] : filteredTasks[indexPath.row]

        let completeAction = UIContextualAction(style: .normal, title: task.isDone ? "Undo" : "Done") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.toggleTaskDone(task)
            self.loadTasksForCurrentTimeframe()
            self.showToast(message: task.isDone ? "Lesson Marked Done!" : "Lesson Marked Pending", icon: task.isDone ? "checkmark.circle.fill" : "circle", tintColor: task.isDone ? DesignSystem.Colors.success : .systemGray)
            completion(true)
        }
        completeAction.backgroundColor = task.isDone ? .systemGray : DesignSystem.Colors.success
        completeAction.image = UIImage(systemName: task.isDone ? "arrow.uturn.backward" : "checkmark.circle.fill")

        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}

// MARK: - UISearchResultsUpdating
extension TodayViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            searchedTasks = filteredTasks
        } else {
            searchedTasks = filteredTasks.filter { task in
                let titleMatch = task.title?.lowercased().contains(searchText.lowercased()) ?? false
                let notesMatch = task.notes?.lowercased().contains(searchText.lowercased()) ?? false
                return titleMatch || notesMatch
            }
        }
        tableView.reloadData()
        updateEmptyState()
    }
}
