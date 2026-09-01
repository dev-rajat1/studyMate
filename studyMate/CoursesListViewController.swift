//
//  CoursesListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 2 Root — Lists all Courses with progress and handles Course creation/deletion.
//

import UIKit

class CoursesListViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Storyboard)
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
        title = "My Courses"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add Course "+" Button in Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addCourseTapped)
        )
        
        // TableView fallback setup
        if tableView == nil {
            let tv = UITableView(frame: view.bounds, style: .insetGrouped)
            tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(tv)
            tableView = tv
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
    }
    
    // MARK: - Data Management
    private func loadCourses() {
        courses = CoreDataManager.shared.fetchCourses()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = courses.isEmpty
        emptyStateLabel?.isHidden = !isEmpty
        
        if isEmpty && emptyStateLabel == nil {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            messageLabel.text = "📚 No Courses Yet\nTap the '+' button to add your first course!"
            messageLabel.textColor = .secondaryLabel
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
            tableView.backgroundView = messageLabel
        } else if !isEmpty {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - Actions
    @objc func addCourseTapped() {
        showCoursePrompt(existingCourse: nil)
    }
    
    private func showCoursePrompt(existingCourse: Course?) {
        let isEditing = existingCourse != nil
        let alert = UIAlertController(
            title: isEditing ? "Edit Course" : "New Course",
            message: "Enter course name and select a color tag.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Course Name (e.g. Computer Science)"
            textField.text = existingCourse?.name
            textField.autocapitalizationType = .words
        }
        
        // Color selection action sheet after entering name
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Save" : "Choose Color & Add", style: .default, handler: { [weak self] _ in
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                return
            }
            
            if isEditing, let course = existingCourse {
                CoreDataManager.shared.updateCourse(course, name: name, colorTag: course.colorTag ?? "Blue")
                self?.loadCourses()
            } else {
                self?.showColorSelectionActionSheet(courseName: name)
            }
        }))
        
        present(alert, animated: true)
    }
    
    private func showColorSelectionActionSheet(courseName: String) {
        let actionSheet = UIAlertController(title: "Pick Color Tag", message: "Choose an accent color for \(courseName)", preferredStyle: .actionSheet)
        
        for colorOption in ColorHelper.availableColors {
            actionSheet.addAction(UIAlertAction(title: colorOption.name, style: .default, handler: { [weak self] _ in
                CoreDataManager.shared.createCourse(name: courseName, colorTag: colorOption.name)
                self?.loadCourses()
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad popover anchor support
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
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCourseCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCourseCell")
        cell.textLabel?.text = course.name
        let (total, completed, _) = CoreDataManager.shared.getCourseProgress(course: course)
        cell.detailTextLabel?.text = "\(completed)/\(total) tasks completed"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCourse = courses[indexPath.row]
        
        // Programmatic Navigation: Push TopicsListViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let topicsVC = storyboard.instantiateViewController(withIdentifier: "TopicsListViewController") as? TopicsListViewController {
            topicsVC.course = selectedCourse
            navigationController?.pushViewController(topicsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let course = courses[indexPath.row]
        
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Course?",
                message: "Deleting '\(course.name ?? "this course")' will also remove all its topics, tasks, and AI notes.",
                confirmTitle: "Delete All",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteCourse(course)
                    self?.loadCourses()
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        // Edit Action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showCoursePrompt(existingCourse: course)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
