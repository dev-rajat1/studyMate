//
//  TaskDetailViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Modal screen for Creating or Editing a Task with notes and status.
//

import UIKit

class TaskDetailViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Storyboard)
    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var notesTextView: UITextView?
    @IBOutlet weak var isDoneSwitch: UISwitch?
    
    // MARK: - Properties
    var topic: Topic!
    var taskToEdit: Task?
    var onSaveCompleted: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateExistingData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = taskToEdit == nil ? "New Task" : "Edit Task"
        view.backgroundColor = .systemGroupedBackground
        
        // Navigation Bar Buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        
        // TextView border & styling
        notesTextView?.layer.cornerRadius = 8
        notesTextView?.layer.borderColor = UIColor.separator.cgColor
        notesTextView?.layer.borderWidth = 0.5
        notesTextView?.layer.masksToBounds = true
    }
    
    private func populateExistingData() {
        if let task = taskToEdit {
            titleTextField?.text = task.title
            notesTextView?.text = task.notes
            isDoneSwitch?.isOn = task.isDone
        }
    }
    
    // MARK: - Actions
    @IBAction @objc func saveTapped(_ sender: Any) {
        guard let title = titleTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for this study task.")
            return
        }
        
        let notes = notesTextView?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let isDone = isDoneSwitch?.isOn ?? false
        
        if let existingTask = taskToEdit {
            CoreDataManager.shared.updateTask(existingTask, title: title, notes: notes, isDone: isDone)
        } else {
            CoreDataManager.shared.createTask(title: title, notes: notes, isDone: isDone, topic: self.topic)
        }
        
        onSaveCompleted?()
        dismiss(animated: true)
    }
    
    @IBAction @objc func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
