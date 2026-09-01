//
//  TopicsListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Displays all Topics under a selected Course, handles Topic creation and navigation to Tasks.
//

import UIKit

class TopicsListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    var course: Course!
    private var topics: [Topic] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTopics()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = course?.name ?? "Topics"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemGroupedBackgroundColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTopicTapped)
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
        tableView.estimatedRowHeight = 85
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
                iconName: "bookmark",
                title: "No Topics Added",
                message: "Tap '+' to add chapters, units, or topics\nunder this course."
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
            title: isEditing ? "Edit Topic" : "New Study Topic",
            message: "Enter topic name (e.g. Dynamic Programming).",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Topic Title"
            textField.text = existingTopic?.title
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Save" : "Next: Target Deadline", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty,
                  let self = self else { return }
            
            if isEditing, let topic = existingTopic {
                CoreDataManager.shared.updateTopic(topic, title: title, deadline: topic.deadline)
                self.loadTopics()
                self.showToast(message: "Topic updated!")
            } else {
                self.promptForTopicDeadline(title: title)
            }
        }))
        
        present(alert, animated: true)
    }
    
    private func promptForTopicDeadline(title: String) {
        let alert = UIAlertController(title: "Target Completion", message: "Choose target deadline for this topic", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "⏰ Due Today", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.createTopic(title: title, deadline: Date(), course: self.course)
            self.loadTopics()
            self.showToast(message: "Topic added for Today!")
        }))
        
        alert.addAction(UIAlertAction(title: "📅 In 3 Days", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            HapticHelper.success()
            let targetDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
            CoreDataManager.shared.createTopic(title: title, deadline: targetDate, course: self.course)
            self.loadTopics()
            self.showToast(message: "Topic created!")
        }))
        
        alert.addAction(UIAlertAction(title: "🗓 Next Week", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            HapticHelper.success()
            let targetDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
            CoreDataManager.shared.createTopic(title: title, deadline: targetDate, course: self.course)
            self.loadTopics()
            self.showToast(message: "Topic created!")
        }))
        
        alert.addAction(UIAlertAction(title: "⚪ No Deadline", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.createTopic(title: title, deadline: nil, course: self.course)
            self.loadTopics()
            self.showToast(message: "Topic created!")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TopicsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topic = topics[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? TopicCell {
            cell.configure(with: topic)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTopicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultTopicCell")
        cell.textLabel?.text = topic.title
        cell.detailTextLabel?.text = topic.deadline != nil ? "Due: \(topic.deadline!.formattedDate())" : "No deadline"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTopic = topics[indexPath.row]
        HapticHelper.lightImpact()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tasksVC = storyboard.instantiateViewController(withIdentifier: "TasksListViewController") as? TasksListViewController {
            tasksVC.topic = selectedTopic
            navigationController?.pushViewController(tasksVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let topic = topics[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Topic?",
                message: "Deleting '\(topic.title ?? "this topic")' will remove all its study tasks and notes.",
                confirmTitle: "Delete",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteTopic(topic)
                    self?.loadTopics()
                    self?.showToast(message: "Topic removed.")
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
