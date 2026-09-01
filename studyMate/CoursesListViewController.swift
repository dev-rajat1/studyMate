//
//  CoursesListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 2 Root — Lists all Courses with progress and handles Course creation/deletion.
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
        title = "My Courses"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        // Add Course "+" Button in Navigation Bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addCourseTapped)
        )
        
        if tableView == nil {
            let tv = UITableView(frame: view.bounds, style: .insetGrouped)
            tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(tv)
            tableView = tv
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 95
    }
    
    // MARK: - Data Management
    private func loadCourses() {
        courses = CoreDataManager.shared.fetchCourses()
        tableView.reloadData()
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
            message: "Enter course name to start organizing your study topics.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "e.g. Machine Learning, Physics"
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
                self?.showToast(message: "Course updated!")
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
                self?.showToast(message: "📚 Course Created!")
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
                message: "Deleting '\(course.name ?? "this course")' will remove all associated topics, tasks, and AI summaries.",
                confirmTitle: "Delete All",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteCourse(course)
                    self?.loadCourses()
                    self?.showToast(message: "Course deleted.")
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
