//
//  TodayViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 1 — Premium Study Planner with Gradient Hero Card, Streak Badge, Pill Segment Bar, and Animated Empty States.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?

    // MARK: - Properties
    private var currentTimeframe: StudyTimeframe = .today
    private var filteredTasks: [Task] = []

    // Custom Pill Segment Container
    private let segmentScrollView = UIScrollView()
    private var pillButtons: [UIButton] = []
    private let pillLabels = ["📅 Today", "🌅 Tomorrow", "📆 Week", "🗓️ Month", "📋 All"]
    private var activePillIndex: Int = 0

    // Empty State View
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
        setupPillSegmentBar()
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
        tableView.backgroundColor = .systemGroupedBackground
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 28, right: 0)
    }

    // MARK: - Custom Pill Segment Bar
    private func setupPillSegmentBar() {
        segmentScrollView.showsHorizontalScrollIndicator = false
        segmentScrollView.showsVerticalScrollIndicator = false
        segmentScrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        segmentScrollView.alwaysBounceHorizontal = true

        for (index, label) in pillLabels.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(label, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            btn.layer.cornerRadius = 16
            btn.clipsToBounds = true
            btn.tag = index
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
            btn.addTarget(self, action: #selector(pillTapped(_:)), for: .touchUpInside)
            segmentScrollView.addSubview(btn)
            pillButtons.append(btn)
        }
        updatePillAppearance()
    }

    private func layoutPills() {
        var x: CGFloat = 0
        for btn in pillButtons {
            btn.sizeToFit()
            let width = btn.intrinsicContentSize.width + 28
            btn.frame = CGRect(x: x, y: 4, width: width, height: 32)
            x += width + 8
        }
        segmentScrollView.contentSize = CGSize(width: x, height: 40)
    }

    private func updatePillAppearance() {
        for (i, btn) in pillButtons.enumerated() {
            if i == activePillIndex {
                btn.backgroundColor = DesignSystem.Colors.primary // Fallback
                btn.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 16)
                btn.setTitleColor(.white, for: .normal)
                DesignSystem.Shadow.applyGlow(to: btn.layer, color: DesignSystem.Colors.primary)
            } else {
                btn.layer.sublayers?.removeAll(where: { $0.name == "SMGradientLayer" })
                btn.backgroundColor = UIColor.secondarySystemGroupedBackground
                btn.setTitleColor(.secondaryLabel, for: .normal)
                btn.layer.shadowOpacity = 0
            }
        }
    }

    @objc private func pillTapped(_ sender: UIButton) {
        HapticHelper.lightImpact()
        activePillIndex = sender.tag
        if let tf = StudyTimeframe(rawValue: sender.tag) {
            currentTimeframe = tf
        }
        updatePillAppearance()
        UIView.transition(with: tableView, duration: 0.22, options: .transitionCrossDissolve, animations: {
            self.loadTasksForCurrentTimeframe()
        }, completion: nil)
    }

    // MARK: - Gradient Hero Header
    private func setupDashboardHeader() {
        let count = filteredTasks.count
        let doneCount = filteredTasks.filter { $0.isDone }.count
        let total = filteredTasks.count
        let pct: Float = total > 0 ? Float(doneCount) / Float(total) : 0

        // Dynamic height based on content
        let headerHeight: CGFloat = 210
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight))
        headerView.backgroundColor = .clear

        // ---- Pill Segment Scroll Bar ----
        segmentScrollView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        headerView.addSubview(segmentScrollView)
        layoutPills()

        // ---- Gradient Hero Card ----
        let heroCard = UIView()
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.layer.cornerRadius = 24
        heroCard.layer.masksToBounds = false
        heroCard.clipsToBounds = true
        headerView.addSubview(heroCard)

        // Gradient background
        heroCard.backgroundColor = DesignSystem.Colors.primary // Fallback
        heroCard.applyGradientBackground(
            colors: DesignSystem.Gradients.hero,
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 1),
            cornerRadius: 24
        )

        // Shadow
        heroCard.layer.masksToBounds = false
        heroCard.clipsToBounds = true

        // Date label (top left)
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = Date().formattedGreetingDate()
        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.70)
        heroCard.addSubview(dateLabel)

        // Greeting
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting = hour < 12 ? "Good Morning ☀️" : hour < 17 ? "Good Afternoon ⚡" : "Good Evening 🌙"
        let greetingLabel = UILabel()
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.text = greeting
        greetingLabel.font = .systemFont(ofSize: 22, weight: .black)
        greetingLabel.textColor = .white
        heroCard.addSubview(greetingLabel)

        // Target label
        let targetLabel = UILabel()
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        if count == 0 {
            targetLabel.text = "🎉 All caught up for \(currentTimeframe.title.lowercased())!"
            targetLabel.textColor = DesignSystem.Colors.teal
        } else {
            targetLabel.text = "⚡ \(count) \(count == 1 ? "Lesson" : "Lessons") Scheduled"
            targetLabel.textColor = UIColor.white.withAlphaComponent(0.90)
        }
        targetLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        heroCard.addSubview(targetLabel)

        // Sub label
        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = UIColor.white.withAlphaComponent(0.60)
        subLabel.numberOfLines = 2
        switch currentTimeframe {
        case .today:
            subLabel.text = count == 0 ? "Review notes or test yourself with an AI quiz." : "Focus and check off each lesson as you finish."
        case .tomorrow:
            subLabel.text = count == 0 ? "No deadlines tomorrow — relax or plan ahead!" : "Get a head-start on tomorrow's lessons today."
        case .thisWeek:
            subLabel.text = count == 0 ? "All weekly targets met! Outstanding consistency." : "Steady daily pace to conquer all weekly goals."
        case .thisMonth:
            subLabel.text = count == 0 ? "Monthly curriculum complete! Great momentum." : "Track your monthly roadmap and master all topics."
        case .all:
            subLabel.text = count == 0 ? "No lessons found. Create a course to start." : "Complete curriculum roadmap across all subjects."
        }
        heroCard.addSubview(subLabel)

        // Mini circular progress (right side)
        let progressRing = ProgressRingView()
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        progressRing.lineWidth = 7
        progressRing.ringColor = DesignSystem.Colors.teal
        progressRing.trackColor = UIColor.white.withAlphaComponent(0.15)
        heroCard.addSubview(progressRing)

        NSLayoutConstraint.activate([
            heroCard.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 48),
            heroCard.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            heroCard.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            heroCard.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),

            dateLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            dateLabel.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 18),

            greetingLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            greetingLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            greetingLabel.trailingAnchor.constraint(equalTo: progressRing.leadingAnchor, constant: -12),

            targetLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            targetLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 10),
            targetLabel.trailingAnchor.constraint(equalTo: progressRing.leadingAnchor, constant: -12),

            subLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 6),
            subLabel.trailingAnchor.constraint(equalTo: progressRing.leadingAnchor, constant: -12),
            subLabel.bottomAnchor.constraint(lessThanOrEqualTo: heroCard.bottomAnchor, constant: -16),

            progressRing.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),
            progressRing.centerYAnchor.constraint(equalTo: heroCard.centerYAnchor),
            progressRing.widthAnchor.constraint(equalToConstant: 72),
            progressRing.heightAnchor.constraint(equalToConstant: 72)
        ])

        tableView.tableHeaderView = headerView

        // Animate progress ring after layout
        DispatchQueue.main.async {
            progressRing.setNeedsLayout()
            progressRing.layoutIfNeeded()
            progressRing.configure(progress: CGFloat(pct), ringColor: DesignSystem.Colors.teal)
        }
    }

    // MARK: - Premium Empty State View
    private func setupEmptyStateView() {
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainer.backgroundColor = .clear
        emptyStateContainer.isHidden = true
        view.addSubview(emptyStateContainer)

        emptyStateIconContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateIconContainer.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.12)
        emptyStateIconContainer.layer.cornerRadius = 42
        emptyStateIconContainer.clipsToBounds = false
        emptyStateIconContainer.layer.shadowColor = DesignSystem.Colors.primary.cgColor
        emptyStateIconContainer.layer.shadowOpacity = 0.28
        emptyStateIconContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        emptyStateIconContainer.layer.shadowRadius = 18

        emptyStateIconView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateIconView.contentMode = .scaleAspectFit
        emptyStateIconView.tintColor = DesignSystem.Colors.primary
        emptyStateIconContainer.addSubview(emptyStateIconView)

        emptyStateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
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
        emptyStateExploreButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
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
        stack.spacing = 14
        stack.setCustomSpacing(18, after: emptyStateIconContainer)
        stack.setCustomSpacing(20, after: emptyStateMsgLabel)
        emptyStateContainer.addSubview(stack)

        NSLayoutConstraint.activate([
            emptyStateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emptyStateContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220),
            emptyStateContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            stack.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: emptyStateContainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor),

            emptyStateIconContainer.widthAnchor.constraint(equalToConstant: 84),
            emptyStateIconContainer.heightAnchor.constraint(equalToConstant: 84),
            emptyStateIconView.centerXAnchor.constraint(equalTo: emptyStateIconContainer.centerXAnchor),
            emptyStateIconView.centerYAnchor.constraint(equalTo: emptyStateIconContainer.centerYAnchor),
            emptyStateIconView.widthAnchor.constraint(equalToConstant: 38),
            emptyStateIconView.heightAnchor.constraint(equalToConstant: 38),

            emptyStateExploreButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func exploreCoursesTapped() {
        HapticHelper.mediumImpact()
        tabBarController?.selectedIndex = 1
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
                titleText = "📚 No Active Lessons!"
                msgText = "Create your first Course and add modules\nto start your study roadmap."
            }

            let iconConfig = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
            emptyStateIconView.image = UIImage(systemName: iconName, withConfiguration: iconConfig)
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
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTasks.count
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
            self.showToast(message: "🎉 Lesson Completed!", icon: "sparkles", tintColor: DesignSystem.Colors.success)
            completion(true)
        }
        completeAction.backgroundColor = DesignSystem.Colors.success
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")

        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}
