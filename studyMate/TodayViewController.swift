//
//  TodayViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 1 — Displays pending tasks across all courses and topics.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Storyboard if using custom layout)
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    private var pendingTasks: [Task] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPendingTasks()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Today's Focus"
        navigationController?.navigationBar.prefersLargeTitles = true
        
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
        tableView.estimatedRowHeight = 80
    }
    
    // MARK: - Data Loading
    private func loadPendingTasks() {
        pendingTasks = CoreDataManager.shared.fetchTodayPendingTasks()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = pendingTasks.isEmpty
        emptyStateLabel?.isHidden = !isEmpty
        
        if isEmpty && emptyStateLabel == nil {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            messageLabel.text = "🎉 All Caught Up!\nNo pending tasks for today."
            messageLabel.textColor = .secondaryLabel
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
            tableView.backgroundView = messageLabel
        } else if !isEmpty {
            tableView.backgroundView = nil
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = pendingTasks[indexPath.row]
        
        // Try dequeuing custom TaskCell
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleCompletion = { [weak self] in
                guard let self = self else { return }
                CoreDataManager.shared.toggleTaskDone(task)
                self.loadPendingTasks()
            }
            return cell
        }
        
        // Fallback default UITableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = task.title
        let topicName = task.topic?.title ?? "General"
        let courseName = task.topic?.course?.name ?? "Course"
        cell.detailTextLabel?.text = "📁 \(courseName) > \(topicName)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = pendingTasks[indexPath.row]
        
        // Programmatic Navigation: Navigate to Topic's Task List
        if let topic = task.topic {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tasksVC = storyboard.instantiateViewController(withIdentifier: "TasksListViewController") as? TasksListViewController {
                tasksVC.topic = topic
                navigationController?.pushViewController(tasksVC, animated: true)
            }
        }
    }
    
    // Swipe to complete or delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = pendingTasks[indexPath.row]
        
        // Complete Action
        let completeAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            CoreDataManager.shared.toggleTaskDone(task)
            self.loadPendingTasks()
            completion(true)
        }
        completeAction.backgroundColor = .systemGreen
        completeAction.image = UIImage(systemName: "checkmark.circle")
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}
