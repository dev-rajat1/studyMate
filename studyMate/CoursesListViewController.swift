//
//  CoursesListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Hierarchy Level 1 — Premium Courses list with animated stats header and gradient FAB.
//

import UIKit

class CoursesListViewController: UIViewController {

    // MARK: - Views
    var tableView: UITableView!
    var emptyStateLabel: UILabel?

    // MARK: - Properties
    private var courses: [Course] = []

    // Gradient FAB
    private let addCourseFAB = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAddCourseFAB()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        loadCourses()
        setupHeaderView()
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
        title = "Courses"
        navigationItem.backButtonTitle = "Courses"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemGroupedBackground

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.backgroundColor = .systemGroupedBackground
        navAppearance.shadowColor = .clear
        navAppearance.shadowImage = UIImage()
        navigationController?.navigationBar.standardAppearance = navAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        navigationController?.navigationBar.compactAppearance = navAppearance

        let tv = UITableView(frame: view.bounds, style: .plain)
        tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tv)
        tableView = tv
        tableView.register(CourseCell.self, forCellReuseIdentifier: "CourseCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 116
        tableView.backgroundColor = .systemGroupedBackground
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 100, right: 0)
    }

    // MARK: - Gradient FAB
    private func setupAddCourseFAB() {
        addCourseFAB.translatesAutoresizingMaskIntoConstraints = false
        addCourseFAB.setTitle("  + Add Course", for: .normal)
        addCourseFAB.setTitleColor(.white, for: .normal)
        addCourseFAB.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)

        // Set icon
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        addCourseFAB.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        addCourseFAB.tintColor = .white
        addCourseFAB.semanticContentAttribute = .forceLeftToRight
        addCourseFAB.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)

        addCourseFAB.backgroundColor = DesignSystem.Colors.primary // Fallback
        addCourseFAB.layer.cornerRadius = 26
        addCourseFAB.clipsToBounds = false
        addCourseFAB.contentEdgeInsets = UIEdgeInsets(top: 13, left: 22, bottom: 13, right: 22)
        addCourseFAB.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 26)
        DesignSystem.Shadow.applyGlow(to: addCourseFAB.layer, color: DesignSystem.Colors.primary)

        addCourseFAB.addTarget(self, action: #selector(addCourseTapped), for: .touchUpInside)
        addCourseFAB.addTarget(self, action: #selector(fabTouchDown), for: [.touchDown, .touchDragEnter])
        addCourseFAB.addTarget(self, action: #selector(fabTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])

        view.addSubview(addCourseFAB)

        NSLayoutConstraint.activate([
            addCourseFAB.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCourseFAB.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addCourseFAB.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func fabTouchDown() { addCourseFAB.bounceTouchDown() }
    @objc private func fabTouchUp() { addCourseFAB.bounceTouchUp() }

    // MARK: - Stats Header
    private func setupHeaderView() {
        guard !courses.isEmpty else {
            tableView.tableHeaderView = nil
            return
        }

        let (coursesCount, modulesCount, tasksCount, completedCount, overallRate) = CoreDataManager.shared.getAppStats()
        let headerWidth = tableView.bounds.width > 0 ? tableView.bounds.width : view.bounds.width
        let headerHeight: CGFloat = 126
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight))
        headerView.backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 16)
        headerView.addSubview(card)

        let titleLabel = UILabel()
        titleLabel.text = "📚 \(coursesCount) \(coursesCount == 1 ? "Subject" : "Subjects") Enrolled"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label

        let subLabel = UILabel()
        subLabel.text = "Tap a subject to explore modules, lessons & AI tutor."
        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .secondaryLabel

        let modChip = buildStatChip(text: "📖 \(modulesCount) Modules", color: DesignSystem.Colors.primary)
        let lesChip = buildStatChip(text: "📝 \(tasksCount) Lessons", color: DesignSystem.Colors.teal)
        let rateChip = buildStatChip(text: "🎯 \(Int(overallRate))% Mastered", color: DesignSystem.Colors.success)

        let statsStack = UIStackView.make(axis: .horizontal, spacing: 8, alignment: .center, distribution: .equalSpacing)
        statsStack.addArrangedSubview(modChip)
        statsStack.addArrangedSubview(lesChip)
        statsStack.addArrangedSubview(rateChip)

        let mainStack = UIStackView.make(axis: .vertical, spacing: 4)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(subLabel)
        mainStack.setCustomSpacing(10, after: subLabel)
        mainStack.addArrangedSubview(statsStack)

        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),

            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        tableView.tableHeaderView = headerView
    }

    private func buildStatChip(text: String, color: UIColor) -> UIView {
        let pill = UIView()
        pill.backgroundColor = color.withAlphaComponent(0.12)
        pill.layer.cornerRadius = 8
        pill.clipsToBounds = true

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = color
        pill.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4)
        ])
        return pill
    }

    // MARK: - Data Management
    private func loadCourses() {
        courses = CoreDataManager.shared.fetchCourses()
        tableView.reloadData()
        setupHeaderView()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if courses.isEmpty {
            emptyStateLabel?.isHidden = false
            tableView.setEmptyState(
                iconName: "books.vertical",
                title: "No Courses Yet",
                message: "Tap '+ Add Course' below\nto create your first study course."
            )
        } else {
            emptyStateLabel?.isHidden = true
            tableView.removeEmptyState()
        }
    }

    // MARK: - Actions
    @objc func addCourseTapped() {
        HapticHelper.lightImpact()
        showCoursePrompt(existingCourse: nil)
    }

    private func showCoursePrompt(existingCourse: Course?) {
        let isEditing = existingCourse != nil
        let alert = UIAlertController(
            title: isEditing ? "Edit Course" : "Create New Course",
            message: "Enter course name (e.g. Machine Learning, Physics).",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Course Name"
            textField.text = existingCourse?.name
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Save" : "Next: Color Tag", style: .default, handler: { [weak self] _ in
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
            if isEditing, let course = existingCourse {
                CoreDataManager.shared.updateCourse(course, name: name, colorTag: course.colorTag ?? "Purple")
                self?.loadCourses()
                self?.showToast(message: "Course updated!", icon: "checkmark.circle.fill", tintColor: DesignSystem.Colors.primary)
            } else {
                self?.showColorSelectionActionSheet(courseName: name)
            }
        }))
        present(alert, animated: true)
    }

    private func showColorSelectionActionSheet(courseName: String) {
        let actionSheet = UIAlertController(title: "Choose Color Theme", message: "Pick an accent color for \(courseName)", preferredStyle: .actionSheet)
        for colorOption in ColorHelper.availableColors {
            actionSheet.addAction(UIAlertAction(title: "● \(colorOption.name)", style: .default, handler: { [weak self] _ in
                HapticHelper.success()
                CoreDataManager.shared.createCourse(name: courseName, colorTag: colorOption.name)
                self?.loadCourses()
                self?.showToast(message: "📚 Course Created!", icon: "plus.circle.fill", tintColor: colorOption.color)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = addCourseFAB
            popover.sourceRect = addCourseFAB.bounds
        }
        present(actionSheet, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension CoursesListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { courses.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let course = courses[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseCell {
            cell.configure(with: course)
            cell.animateGlideIn(delayIndex: indexPath.row)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCourseCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCourseCell")
        cell.textLabel?.text = course.name
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        let (total, completed, _) = CoreDataManager.shared.getCourseProgress(course: course)
        cell.detailTextLabel?.text = "\(completed)/\(total) lessons completed"
        cell.accessoryType = .disclosureIndicator
        cell.animateGlideIn(delayIndex: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCourse = courses[indexPath.row]
        HapticHelper.lightImpact()
        let topicsVC = TopicsListViewController()
        topicsVC.course = selectedCourse
        navigationController?.pushViewController(topicsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let course = courses[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Course?",
                message: "Deleting '\(course.name ?? "this course")' will remove all its modules, lessons, and notes.",
                confirmTitle: "Delete All",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteCourse(course)
                    self?.loadCourses()
                    self?.showToast(message: "Course deleted.", icon: "trash.fill", tintColor: DesignSystem.Colors.coral)
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let course = courses[indexPath.row]
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showCoursePrompt(existingCourse: course)
            completion(true)
        }
        editAction.backgroundColor = DesignSystem.Colors.primary
        editAction.image = UIImage(systemName: "pencil")

        return UISwipeActionsConfiguration(actions: [editAction])
    }
}
