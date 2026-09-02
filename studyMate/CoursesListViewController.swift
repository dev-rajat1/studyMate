//
//  CoursesListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Hierarchy Level 1 — Lists all Courses with progress and handles Course creation/deletion.
//

import UIKit

class CoursesListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    private var courses: [Course] = []
    
    // Bottom Floating Action Button
    private let addCourseFAB = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAddCourseFAB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCourses()
        setupHeaderView()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Courses"
        navigationItem.backButtonTitle = "Courses"
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
        tableView.estimatedRowHeight = 116
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 84, right: 0)
    }
    
    // MARK: - Bottom Floating Action Button (Add Course)
    private func setupAddCourseFAB() {
        addCourseFAB.translatesAutoresizingMaskIntoConstraints = false
        addCourseFAB.setTitle("➕ Add Course", for: .normal)
        addCourseFAB.setTitleColor(.white, for: .normal)
        addCourseFAB.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        addCourseFAB.backgroundColor = .systemBlue
        addCourseFAB.layer.cornerRadius = 24
        addCourseFAB.clipsToBounds = false
        addCourseFAB.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
        // Shadow & Aesthetics
        addCourseFAB.layer.shadowColor = UIColor.systemBlue.cgColor
        addCourseFAB.layer.shadowOpacity = 0.35
        addCourseFAB.layer.shadowOffset = CGSize(width: 0, height: 6)
        addCourseFAB.layer.shadowRadius = 12
        
        addCourseFAB.addTarget(self, action: #selector(addCourseTapped), for: .touchUpInside)
        addCourseFAB.addTarget(self, action: #selector(fabTouchDown), for: [.touchDown, .touchDragEnter])
        addCourseFAB.addTarget(self, action: #selector(fabTouchUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
        
        view.addSubview(addCourseFAB)
        
        NSLayoutConstraint.activate([
            addCourseFAB.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            addCourseFAB.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            addCourseFAB.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func fabTouchDown() {
        addCourseFAB.bounceTouchDown()
    }
    
    @objc private func fabTouchUp() {
        addCourseFAB.bounceTouchUp()
    }
    
    // MARK: - Summary Header (Consistent with Planner & Analytics Tabs)
    private func setupHeaderView() {
        guard !courses.isEmpty else {
            tableView.tableHeaderView = nil
            return
        }
        
        let (coursesCount, modulesCount, tasksCount, _, overallRate) = CoreDataManager.shared.getAppStats()
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 156))
        headerView.backgroundColor = .clear
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 18)
        headerView.addSubview(card)
        
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .equalSpacing
        topStack.alignment = .center
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Curriculum Pill Badge
        let badgePill = UIView()
        badgePill.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        badgePill.layer.cornerRadius = 6
        badgePill.clipsToBounds = true
        
        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = "📚 ENROLLED CURRICULUM"
        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .systemBlue
        badgePill.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            badgeLabel.leadingAnchor.constraint(equalTo: badgePill.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgePill.trailingAnchor, constant: -8),
            badgeLabel.topAnchor.constraint(equalTo: badgePill.topAnchor, constant: 3),
            badgeLabel.bottomAnchor.constraint(equalTo: badgePill.bottomAnchor, constant: -3)
        ])
        
        let dateLabel = UILabel()
        dateLabel.text = "🗓️ ACTIVE SEMESTER"
        dateLabel.font = .systemFont(ofSize: 11, weight: .bold)
        dateLabel.textColor = .secondaryLabel
        
        topStack.addArrangedSubview(badgePill)
        topStack.addArrangedSubview(dateLabel)
        card.addSubview(topStack)
        
        // Title
        let greetingLabel = UILabel()
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.text = "⚡ \(coursesCount) \(coursesCount == 1 ? "Subject" : "Subjects") Enrolled"
        greetingLabel.font = .systemFont(ofSize: 17, weight: .bold)
        greetingLabel.textColor = .label
        card.addSubview(greetingLabel)
        
        // Subtitle
        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.text = "Select a subject to explore chapters, study lessons, and launch AI Tutor."
        subLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 2
        card.addSubview(subLabel)
        
        // Bottom Mini Stats Row
        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.distribution = .equalSpacing
        statsStack.spacing = 8
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let modChip = createChip(text: "📖 \(modulesCount) Modules", color: .systemPurple)
        let lesChip = createChip(text: "📝 \(tasksCount) Lessons", color: .systemBlue)
        let rateChip = createChip(text: "🎯 \(Int(overallRate))% Mastered", color: .systemGreen)
        
        statsStack.addArrangedSubview(modChip)
        statsStack.addArrangedSubview(lesChip)
        statsStack.addArrangedSubview(rateChip)
        card.addSubview(statsStack)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4),
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
            subLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            statsStack.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            statsStack.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 8),
            statsStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -10)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func createChip(text: String, color: UIColor) -> UIView {
        let pill = UIView()
        pill.backgroundColor = color.withAlphaComponent(0.10)
        pill.layer.cornerRadius = 6
        pill.clipsToBounds = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = color
        pill.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -6),
            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -3)
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
                message: "Tap '➕ Add Course' at the bottom right\nto create your first study course."
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
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                return
            }
            
            if isEditing, let course = existingCourse {
                CoreDataManager.shared.updateCourse(course, name: name, colorTag: course.colorTag ?? "Blue")
                self?.loadCourses()
                self?.showToast(message: "Course updated!", icon: "checkmark.circle.fill", tintColor: .systemBlue)
            } else {
                self?.showColorSelectionActionSheet(courseName: name)
            }
        }))
        
        present(alert, animated: true)
    }
    
    private func showColorSelectionActionSheet(courseName: String) {
        let actionSheet = UIAlertController(title: "Choose Color Theme", message: "Assign an accent color for \(courseName)", preferredStyle: .actionSheet)
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let topicsVC = storyboard.instantiateViewController(withIdentifier: "TopicsListViewController") as? TopicsListViewController {
            topicsVC.course = selectedCourse
            navigationController?.pushViewController(topicsVC, animated: true)
        }
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
                    self?.showToast(message: "Course deleted.", icon: "trash.fill", tintColor: .systemRed)
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showCoursePrompt(existingCourse: course)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}


