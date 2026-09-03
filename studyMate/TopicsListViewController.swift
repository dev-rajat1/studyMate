//
//  TopicsListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Hierarchy Level 2 — Premium Modules list with gradient hero banner and color-accented cards.
//

import UIKit

class TopicsListViewController: UIViewController {

    // MARK: - Views
    var tableView: UITableView!
    var emptyStateLabel: UILabel?

    // MARK: - Properties
    var course: Course!
    private var topics: [Topic] = []

    // FAB
    private let addTopicFAB = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAddTopicFAB()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTopics()
        setupHeaderBanner()
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "Modules"
        navigationItem.backButtonTitle = "Modules"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        let tv = UITableView(frame: view.bounds, style: .plain)
        tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tv)
        tableView = tv
        tableView.register(TopicCell.self, forCellReuseIdentifier: "TopicCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.backgroundColor = .systemGroupedBackground
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
    }

    // MARK: - Course-colored FAB
    private func setupAddTopicFAB() {
        addTopicFAB.translatesAutoresizingMaskIntoConstraints = false
        addTopicFAB.setTitle("  + Add Module", for: .normal)
        addTopicFAB.setTitleColor(.white, for: .normal)
        addTopicFAB.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)

        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        addTopicFAB.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        addTopicFAB.tintColor = .white
        addTopicFAB.semanticContentAttribute = .forceLeftToRight
        addTopicFAB.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)

        let themeColor = ColorHelper.color(named: course?.colorTag)
        let themeGradient = ColorHelper.gradientColors(named: course?.colorTag)
        addTopicFAB.backgroundColor = themeColor // Fallback
        addTopicFAB.layer.cornerRadius = 26
        addTopicFAB.clipsToBounds = false
        addTopicFAB.contentEdgeInsets = UIEdgeInsets(top: 13, left: 22, bottom: 13, right: 22)
        addTopicFAB.applyGradientBackground(colors: themeGradient, cornerRadius: 26)
        DesignSystem.Shadow.applyGlow(to: addTopicFAB.layer, color: themeColor)

        addTopicFAB.addTarget(self, action: #selector(addTopicTapped), for: .touchUpInside)
        addTopicFAB.addTarget(self, action: #selector(fabTouchDown), for: [.touchDown, .touchDragEnter])
        addTopicFAB.addTarget(self, action: #selector(fabTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])

        view.addSubview(addTopicFAB)

        NSLayoutConstraint.activate([
            addTopicFAB.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addTopicFAB.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addTopicFAB.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func fabTouchDown() { addTopicFAB.bounceTouchDown() }
    @objc private func fabTouchUp() { addTopicFAB.bounceTouchUp() }

    // MARK: - Gradient Hero Banner
    private func setupHeaderBanner() {
        guard let course = course else {
            tableView.tableHeaderView = nil
            return
        }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 130))
        headerView.backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = ColorHelper.color(named: course.colorTag)
        card.applyCardStyle(cornerRadius: 16)
        card.clipsToBounds = true

        let gradientCols = ColorHelper.gradientColors(named: course.colorTag)
        card.applyGradientBackground(
            colors: gradientCols,
            startPoint: CGPoint(x: 0, y: 0.2),
            endPoint: CGPoint(x: 1, y: 0.8),
            cornerRadius: 16
        )
        headerView.addSubview(card)

        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        iconCircle.layer.cornerRadius = 22
        iconCircle.clipsToBounds = true
        iconCircle.widthAnchor.constraint(equalToConstant: 44).isActive = true
        iconCircle.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: "books.vertical.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor)
        ])

        let titleLabel = UILabel()
        titleLabel.text = course.name ?? "Course"
        titleLabel.font = .systemFont(ofSize: 20, weight: .black)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1

        let (totalTasks, completedTasks, progress) = CoreDataManager.shared.getCourseProgress(course: course)
        let subLabel = UILabel()
        subLabel.text = "📖 \(topics.count) Modules  •  \(completedTasks)/\(totalTasks) Lessons (\(Int(progress * 100))%)"
        subLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        subLabel.textColor = UIColor.white.withAlphaComponent(0.80)

        let pTrack = UIView()
        pTrack.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        pTrack.layer.cornerRadius = 3
        pTrack.translatesAutoresizingMaskIntoConstraints = false
        pTrack.heightAnchor.constraint(equalToConstant: 5).isActive = true

        let pFill = UIView()
        pFill.translatesAutoresizingMaskIntoConstraints = false
        pFill.backgroundColor = UIColor.white.withAlphaComponent(0.90)
        pFill.layer.cornerRadius = 3
        pTrack.addSubview(pFill)

        NSLayoutConstraint.activate([
            pFill.leadingAnchor.constraint(equalTo: pTrack.leadingAnchor),
            pFill.topAnchor.constraint(equalTo: pTrack.topAnchor),
            pFill.bottomAnchor.constraint(equalTo: pTrack.bottomAnchor),
            pFill.widthAnchor.constraint(equalTo: pTrack.widthAnchor, multiplier: max(CGFloat(progress), 0.02))
        ])

        let rightContentStack = UIStackView.make(axis: .vertical, spacing: 4)
        rightContentStack.addArrangedSubview(titleLabel)
        rightContentStack.addArrangedSubview(subLabel)
        rightContentStack.setCustomSpacing(10, after: subLabel)
        rightContentStack.addArrangedSubview(pTrack)

        let mainStack = UIStackView.make(axis: .horizontal, spacing: 12, alignment: .center)
        mainStack.addArrangedSubview(iconCircle)
        mainStack.addArrangedSubview(rightContentStack)

        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),

            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        tableView.tableHeaderView = headerView
    }

    // MARK: - Data Management
    private func loadTopics() {
        guard let course = course else { return }
        topics = CoreDataManager.shared.fetchTopics(for: course)
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if topics.isEmpty {
            emptyStateLabel?.isHidden = false
            tableView.setEmptyState(
                iconName: "square.stack.3d.up",
                title: "No Modules Added",
                message: "Tap '+ Add Module' below to create\nyour first chapter for \(course?.name ?? "this course")."
            )
        } else {
            emptyStateLabel?.isHidden = true
            tableView.removeEmptyState()
        }
    }

    // MARK: - Actions
    @objc func addTopicTapped() {
        HapticHelper.lightImpact()
        showTopicPrompt(existingTopic: nil)
    }

    private func showTopicPrompt(existingTopic: Topic?) {
        let isEditing = existingTopic != nil
        let alert = UIAlertController(
            title: isEditing ? "Edit Module" : "Create New Module",
            message: "Enter module title for \(course?.name ?? "Course").",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "e.g. Module 1: Binary Trees"
            textField.text = existingTopic?.title
            textField.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Save" : "Add Module", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else { return }
            HapticHelper.success()
            if isEditing, let topic = existingTopic {
                CoreDataManager.shared.updateTopic(topic, title: title, deadline: topic.deadline)
                self?.showToast(message: "Module updated!", icon: "checkmark.circle.fill", tintColor: DesignSystem.Colors.primary)
            } else if let course = self?.course {
                CoreDataManager.shared.createTopic(title: title, deadline: nil, course: course)
                self?.showToast(message: "📖 Module Created!", icon: "plus.circle.fill", tintColor: ColorHelper.color(named: course.colorTag))
            }
            self?.loadTopics()
            self?.setupHeaderBanner()
        }))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TopicsListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { topics.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topic = topics[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? TopicCell {
            cell.configure(with: topic)
            cell.animateGlideIn(delayIndex: indexPath.row)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTopicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultTopicCell")
        cell.textLabel?.text = topic.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        let (total, completed, _) = CoreDataManager.shared.getTopicProgress(topic: topic)
        cell.detailTextLabel?.text = "\(completed)/\(total) lessons completed"
        cell.accessoryType = .disclosureIndicator
        cell.animateGlideIn(delayIndex: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTopic = topics[indexPath.row]
        HapticHelper.lightImpact()
        let tasksVC = TasksListViewController()
        tasksVC.topic = selectedTopic
        navigationController?.pushViewController(tasksVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let topic = topics[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Module?",
                message: "Deleting '\(topic.title ?? "this module")' will remove all its lessons and notes.",
                confirmTitle: "Delete All",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteTopic(topic)
                    self?.loadTopics()
                    self?.setupHeaderBanner()
                    self?.showToast(message: "Module deleted.", icon: "trash.fill", tintColor: DesignSystem.Colors.coral)
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showTopicPrompt(existingTopic: topic)
            completion(true)
        }
        editAction.backgroundColor = DesignSystem.Colors.primary
        editAction.image = UIImage(systemName: "pencil")

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
