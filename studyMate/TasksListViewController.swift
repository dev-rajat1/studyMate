//
//  TasksListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Hierarchy Level 3 — Premium Lessons list with module context banner and gradient AI/Add FABs.
//

import UIKit

class TasksListViewController: UIViewController {

    // MARK: - Views
    var tableView: UITableView!
    var progressBar: UIProgressView?
    var progressLabel: UILabel?
    var emptyStateLabel: UILabel?

    // MARK: - Properties
    var topic: Topic!
    private var tasks: [Task] = []

    // FABs
    private let addLessonFAB = UIButton(type: .system)
    private let aiTutorFAB = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBottomFABs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
        setupHeaderBanner()
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "Lessons"
        navigationItem.backButtonTitle = "Lessons"
        navigationItem.largeTitleDisplayMode = .never
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
        tableView.estimatedRowHeight = 92
        tableView.backgroundColor = .systemGroupedBackground
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 130, right: 0)
    }

    // MARK: - Dual FABs (AI Tutor + Add Lesson)
    private func setupBottomFABs() {
        // AI Tutor FAB — gradient indigo→violet
        aiTutorFAB.translatesAutoresizingMaskIntoConstraints = false
        aiTutorFAB.setTitle("  ✨ AI Tutor", for: .normal)
        aiTutorFAB.setTitleColor(.white, for: .normal)
        aiTutorFAB.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        aiTutorFAB.tintColor = .white
        aiTutorFAB.backgroundColor = DesignSystem.Colors.primary // Fallback
        aiTutorFAB.layer.cornerRadius = 24
        aiTutorFAB.clipsToBounds = false
        aiTutorFAB.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        aiTutorFAB.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 24)
        DesignSystem.Shadow.applyGlow(to: aiTutorFAB.layer, color: DesignSystem.Colors.primary)

        aiTutorFAB.addTarget(self, action: #selector(aiAssistantTapped), for: .touchUpInside)
        aiTutorFAB.addTarget(self, action: #selector(aiTouchDown), for: [.touchDown, .touchDragEnter])
        aiTutorFAB.addTarget(self, action: #selector(aiTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])

        // Add Lesson FAB — course color
        addLessonFAB.translatesAutoresizingMaskIntoConstraints = false
        addLessonFAB.setTitle("  + Lesson", for: .normal)
        addLessonFAB.setTitleColor(.white, for: .normal)
        addLessonFAB.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)

        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        addLessonFAB.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        addLessonFAB.tintColor = .white
        addLessonFAB.semanticContentAttribute = .forceLeftToRight
        addLessonFAB.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)

        let themeGradient = ColorHelper.gradientColors(named: topic?.course?.colorTag)
        let themeColor = ColorHelper.color(named: topic?.course?.colorTag)
        addLessonFAB.backgroundColor = themeColor // Fallback
        addLessonFAB.layer.cornerRadius = 24
        addLessonFAB.clipsToBounds = false
        addLessonFAB.contentEdgeInsets = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        addLessonFAB.applyGradientBackground(colors: themeGradient, cornerRadius: 24)
        DesignSystem.Shadow.applyGlow(to: addLessonFAB.layer, color: themeColor)

        addLessonFAB.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
        addLessonFAB.addTarget(self, action: #selector(addLessonTouchDown), for: [.touchDown, .touchDragEnter])
        addLessonFAB.addTarget(self, action: #selector(addLessonTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])

        // Horizontal stack of FABs at bottom right
        let stack = UIStackView(arrangedSubviews: [aiTutorFAB, addLessonFAB])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            aiTutorFAB.heightAnchor.constraint(equalToConstant: 48),
            addLessonFAB.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func addLessonTouchDown() { addLessonFAB.bounceTouchDown() }
    @objc private func addLessonTouchUp() { addLessonFAB.bounceTouchUp() }
    @objc private func aiTouchDown() { aiTutorFAB.bounceTouchDown() }
    @objc private func aiTouchUp() { aiTutorFAB.bounceTouchUp() }

    // MARK: - Module Context Header
    private func setupHeaderBanner() {
        guard let topic = topic else {
            tableView.tableHeaderView = nil
            return
        }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 110))
        headerView.backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 16)
        headerView.addSubview(card)

        let courseColor = ColorHelper.color(named: topic.course?.colorTag)
        let gradientCols = ColorHelper.gradientColors(named: topic.course?.colorTag)

        let accentBar = UIView()
        accentBar.translatesAutoresizingMaskIntoConstraints = false
        accentBar.layer.cornerRadius = 4
        accentBar.clipsToBounds = true
        accentBar.widthAnchor.constraint(equalToConstant: 6).isActive = true
        card.addSubview(accentBar)
        accentBar.applyGradientBackground(colors: gradientCols, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 4)

        let breadcrumbPill = UIView()
        breadcrumbPill.backgroundColor = courseColor.withAlphaComponent(0.10)
        breadcrumbPill.layer.cornerRadius = 7
        breadcrumbPill.clipsToBounds = true

        let breadcrumbLabel = UILabel()
        breadcrumbLabel.text = "📚 \(topic.course?.name ?? "Course")  ›  📖 \(topic.title ?? "Module")"
        breadcrumbLabel.font = .systemFont(ofSize: 11, weight: .bold)
        breadcrumbLabel.textColor = courseColor
        breadcrumbLabel.lineBreakMode = .byTruncatingTail
        breadcrumbLabel.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbPill.addSubview(breadcrumbLabel)

        NSLayoutConstraint.activate([
            breadcrumbLabel.leadingAnchor.constraint(equalTo: breadcrumbPill.leadingAnchor, constant: 8),
            breadcrumbLabel.trailingAnchor.constraint(equalTo: breadcrumbPill.trailingAnchor, constant: -8),
            breadcrumbLabel.topAnchor.constraint(equalTo: breadcrumbPill.topAnchor, constant: 4),
            breadcrumbLabel.bottomAnchor.constraint(equalTo: breadcrumbPill.bottomAnchor, constant: -4)
        ])

        let (total, completed, progress) = CoreDataManager.shared.getTopicProgress(topic: topic)
        let statusLabel = UILabel()
        statusLabel.text = total == 0 ? "No lessons yet — add your first one!" : "📝 \(completed) of \(total) Lessons Done (\(Int(progress * 100))%)"
        statusLabel.font = .systemFont(ofSize: 15, weight: .bold)
        statusLabel.textColor = (total > 0 && completed == total) ? DesignSystem.Colors.success : .label

        let pBar = UIProgressView(progressViewStyle: .default)
        pBar.progress = progress
        pBar.tintColor = courseColor
        pBar.trackTintColor = UIColor.separator.withAlphaComponent(0.12)
        pBar.layer.cornerRadius = 4
        pBar.clipsToBounds = true
        pBar.translatesAutoresizingMaskIntoConstraints = false
        pBar.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let topStack = UIStackView.make(axis: .horizontal, spacing: 8, alignment: .center)
        topStack.addArrangedSubview(breadcrumbPill)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        topStack.addArrangedSubview(spacer)

        let contentStack = UIStackView.make(axis: .vertical, spacing: 10)
        contentStack.addArrangedSubview(topStack)
        contentStack.addArrangedSubview(statusLabel)
        contentStack.addArrangedSubview(pBar)

        let mainStack = UIStackView.make(axis: .horizontal, spacing: 12, alignment: .fill)
        mainStack.addArrangedSubview(accentBar)
        mainStack.addArrangedSubview(contentStack)

        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),

            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        tableView.tableHeaderView = headerView
    }

    // MARK: - Data Management
    private func loadTasks() {
        guard let topic = topic else { return }
        tasks = CoreDataManager.shared.fetchTasks(for: topic)
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if tasks.isEmpty {
            emptyStateLabel?.isHidden = false
            tableView.setEmptyState(
                iconName: "doc.text.badge.plus",
                title: "No Lessons Yet",
                message: "Tap '+ Lesson' below to add your first\nstudy lesson and write notes!"
            )
        } else {
            emptyStateLabel?.isHidden = true
            tableView.removeEmptyState()
        }
    }

    // MARK: - Actions
    @objc func addTaskTapped() {
        HapticHelper.lightImpact()
        presentTaskDetail(taskToEdit: nil)
    }

    private func presentTaskDetail(taskToEdit: Task?) {
        let detailVC = TaskDetailViewController()
        detailVC.topic = self.topic
        detailVC.taskToEdit = taskToEdit
        detailVC.onSaveCompleted = { [weak self] in
            self?.loadTasks()
            self?.setupHeaderBanner()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc func aiAssistantTapped() {
        HapticHelper.mediumImpact()
        let aiVC = AISummaryViewController()
        aiVC.topic = self.topic
        aiVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(aiVC, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { tasks.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleDone = { [weak self] in
                HapticHelper.success()
                CoreDataManager.shared.toggleTaskDone(task)
                self?.loadTasks()
                self?.setupHeaderBanner()
                self?.showToast(
                    message: task.isDone ? "Lesson Marked Done!" : "Lesson Marked Pending",
                    icon: task.isDone ? "checkmark.circle.fill" : "circle",
                    tintColor: task.isDone ? DesignSystem.Colors.success : .systemGray
                )
            }
            cell.animateGlideIn(delayIndex: indexPath.row)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultTaskCell")
        cell.textLabel?.text = task.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cell.detailTextLabel?.text = task.notes?.isEmpty == false ? "📝 \(task.notes ?? "")" : "No notes yet"
        cell.accessoryType = task.isDone ? .checkmark : .none
        cell.animateGlideIn(delayIndex: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticHelper.lightImpact()
        presentTaskDetail(taskToEdit: tasks[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Lesson?",
                message: "Are you sure you want to delete '\(task.title ?? "this lesson")' and its notes?",
                confirmTitle: "Delete",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteTask(task)
                    self?.loadTasks()
                    self?.setupHeaderBanner()
                    self?.showToast(message: "Lesson deleted.", icon: "trash.fill", tintColor: DesignSystem.Colors.coral)
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]

        let completeAction = UIContextualAction(style: .normal, title: task.isDone ? "Undo" : "Done") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.toggleTaskDone(task)
            self.loadTasks()
            self.setupHeaderBanner()
            self.showToast(message: task.isDone ? "Lesson Marked Done!" : "Lesson Marked Pending", icon: task.isDone ? "checkmark.circle.fill" : "circle", tintColor: task.isDone ? DesignSystem.Colors.success : .systemGray)
            completion(true)
        }
        completeAction.backgroundColor = task.isDone ? .systemGray : DesignSystem.Colors.success
        completeAction.image = UIImage(systemName: task.isDone ? "arrow.uturn.backward" : "checkmark.circle.fill")

        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}
