//
//  TasksListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Displays all Tasks under a Topic, shows topic progress, and triggers AI Summary/Quiz.
//

import UIKit

class TasksListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView?
    @IBOutlet weak var progressLabel: UILabel?
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    var topic: Topic!
    private var tasks: [Task] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = topic?.title ?? "Tasks"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackgroundColor
        
        let aiButton = UIBarButtonItem(
            image: UIImage(systemName: "sparkles"),
            style: .plain,
            target: self,
            action: #selector(aiAssistantTapped)
        )
        aiButton.tintColor = .systemPurple
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTaskTapped)
        )
        
        navigationItem.rightBarButtonItems = [addButton, aiButton]
        
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
        tableView.estimatedRowHeight = 75
    }
    
    // MARK: - Data Management
    private func loadTasks() {
        guard let topic = topic else { return }
        tasks = CoreDataManager.shared.fetchTasks(for: topic)
        tableView.reloadData()
        updateProgress()
        updateEmptyState()
    }
    
    private func updateProgress() {
        guard let topic = topic else { return }
        let (total, completed, progress) = CoreDataManager.shared.getTopicProgress(topic: topic)
        
        progressBar?.setProgress(progress, animated: true)
        if total == 0 {
            progressLabel?.text = "No study tasks added yet"
        } else if completed == total {
            progressLabel?.text = "🎉 All \(total) tasks completed (100%)"
            progressLabel?.textColor = .systemGreen
        } else {
            progressLabel?.text = "\(completed) of \(total) tasks completed (\(Int(progress * 100))%)"
            progressLabel?.textColor = .secondaryLabel
        }
    }
    
    private func updateEmptyState() {
        if tasks.isEmpty {
            emptyStateLabel?.isHidden = false
            tableView.setEmptyState(
                iconName: "checklist",
                title: "No Study Tasks",
                message: "Tap '+' to add tasks or study notes.\nTap '✨' to generate AI notes & quizzes!"
            )
        } else {
            emptyStateLabel?.isHidden = true
            tableView.removeEmptyState()
        }
    }
    
    // MARK: - Programmatic Navigation Actions
    
    @objc func addTaskTapped() {
        HapticHelper.lightImpact()
        navigateToTaskDetail(existingTask: nil)
    }
    
    @objc func aiAssistantTapped() {
        HapticHelper.lightImpact()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let aiVC = storyboard.instantiateViewController(withIdentifier: "AISummaryViewController") as? AISummaryViewController {
            aiVC.topic = self.topic
            let nav = UINavigationController(rootViewController: aiVC)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
        }
    }
    
    private func navigateToTaskDetail(existingTask: Task?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController") as? TaskDetailViewController {
            detailVC.topic = self.topic
            detailVC.taskToEdit = existingTask
            detailVC.onSaveCompleted = { [weak self] in
                self?.loadTasks()
                self?.showToast(message: "Task saved successfully!")
            }
            let nav = UINavigationController(rootViewController: detailVC)
            present(nav, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleCompletion = { [weak self] in
                guard let self = self else { return }
                HapticHelper.success()
                CoreDataManager.shared.toggleTaskDone(task)
                self.loadTasks()
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultTaskCell")
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.notes
        cell.accessoryType = task.isDone ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTask = tasks[indexPath.row]
        HapticHelper.lightImpact()
        navigateToTaskDetail(existingTask: selectedTask)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            CoreDataManager.shared.deleteTask(task)
            self?.loadTasks()
            self?.showToast(message: "Task deleted.")
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
