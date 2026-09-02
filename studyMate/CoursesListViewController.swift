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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCourses()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Courses"
        navigationItem.backButtonTitle = "Courses"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        // Add Course "+" Button with custom tint in Navigation Bar
        let addBtn = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addCourseTapped)
        )
        addBtn.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = addBtn
        
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
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
    }
    
    // MARK: - Summary Header
    private func setupHeaderView() {
        guard !courses.isEmpty else {
            tableView.tableHeaderView = nil
            return
        }
        
        let (coursesCount, modulesCount, _, _, overallRate) = CoreDataManager.shared.getAppStats()
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 98))
        headerView.backgroundColor = .clear
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 16)
        headerView.addSubview(card)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Column 1: Courses
        let col1 = createStatColumn(value: "\(coursesCount)", label: "Courses", icon: "books.vertical.fill", tintColor: .systemBlue)
        // Column 2: Modules
        let col2 = createStatColumn(value: "\(modulesCount)", label: "Modules", icon: "square.stack.3d.up.fill", tintColor: .systemPurple)
        // Column 3: Overall Progress
        let col3 = createStatColumn(value: "\(Int(overallRate))%", label: "Completed", icon: "checkmark.circle.fill", tintColor: .systemGreen)
        
        stack.addArrangedSubview(col1)
        stack.addArrangedSubview(col2)
        stack.addArrangedSubview(col3)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 4),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),
            
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func createStatColumn(value: String, label: String, icon: String, tintColor: UIColor) -> UIView {
        let container = UIView()
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = tintColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let valLabel = UILabel()
        valLabel.text = value
        valLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valLabel.textColor = .label
        valLabel.textAlignment = .center
        valLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = label
        textLabel.font = .systemFont(ofSize: 11, weight: .medium)
        textLabel.textColor = .secondaryLabel
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(valLabel)
        container.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            valLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 3),
            valLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            textLabel.topAnchor.constraint(equalTo: valLabel.bottomAnchor, constant: 1),
            textLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2)
        ])
        
        return container
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
                message: "Tap the '+' button in the top right\nto create your first study course."
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
            popover.barButtonItem = navigationItem.rightBarButtonItem
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


