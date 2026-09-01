//
//  TopicsListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Displays all Topics under a selected Course, handles Topic creation and navigation to Tasks.
//

import UIKit

class TopicsListViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Storyboard)
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
        
        // Add Topic "+" Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTopicTapped)
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
        let isEmpty = topics.isEmpty
        emptyStateLabel?.isHidden = !isEmpty
        
        if isEmpty && emptyStateLabel == nil {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            messageLabel.text = "📖 No Topics Added\nTap '+' to create a new study topic!"
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
    @objc func addTopicTapped() {
        showTopicPrompt(existingTopic: nil)
    }
    
    private func showTopicPrompt(existingTopic: Topic?) {
        let isEditing = existingTopic != nil
        let alert = UIAlertController(
            title: isEditing ? "Edit Topic" : "New Study Topic",
            message: "Enter topic title (e.g. Trees & Graphs).",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Topic Title"
            textField.text = existingTopic?.title
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Save" : "Next: Set Deadline", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty,
                  let self = self else { return }
            
            if isEditing, let topic = existingTopic {
                CoreDataManager.shared.updateTopic(topic, title: title, deadline: topic.deadline)
                self.loadTopics()
            } else {
                self.promptForTopicDeadline(title: title)
            }
        }))
        
        present(alert, animated: true)
    }
    
    private func promptForTopicDeadline(title: String) {
        let alert = UIAlertController(title: "Set Deadline", message: "Choose target completion date (optional)", preferredStyle: .actionSheet)
        
        // Quick options
        alert.addAction(UIAlertAction(title: "Today", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            CoreDataManager.shared.createTopic(title: title, deadline: Date(), course: self.course)
            self.loadTopics()
        }))
        
        alert.addAction(UIAlertAction(title: "In 3 Days", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let targetDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
            CoreDataManager.shared.createTopic(title: title, deadline: targetDate, course: self.course)
            self.loadTopics()
        }))
        
        alert.addAction(UIAlertAction(title: "Next Week", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let targetDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
            CoreDataManager.shared.createTopic(title: title, deadline: targetDate, course: self.course)
            self.loadTopics()
        }))
        
        alert.addAction(UIAlertAction(title: "No Deadline", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            CoreDataManager.shared.createTopic(title: title, deadline: nil, course: self.course)
            self.loadTopics()
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
        if let deadline = topic.deadline {
            cell.detailTextLabel?.text = "Due: \(deadline.formattedDate())"
        } else {
            cell.detailTextLabel?.text = "No deadline"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedTopic = topics[indexPath.row]
        
        // Programmatic Navigation: Push TasksListViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tasksVC = storyboard.instantiateViewController(withIdentifier: "TasksListViewController") as? TasksListViewController {
            tasksVC.topic = selectedTopic
            navigationController?.pushViewController(tasksVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let topic = topics[indexPath.row]
        
        // Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Topic?",
                message: "Deleting '\(topic.title ?? "this topic")' will also remove all its tasks and notes.",
                confirmTitle: "Delete",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteTopic(topic)
                    self?.loadTopics()
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
