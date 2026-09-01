//
//  TopicsListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Displays all Topics/Modules under a selected Course with persistent Course Header banner.
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
        setupHeaderBanner()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = course?.name ?? "Course Topics"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTopicTapped)
        )
        
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
        tableView.estimatedRowHeight = 90
    }
    
    private func setupHeaderBanner() {
        guard let course = course else { return }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 95))
        headerView.backgroundColor = .clear
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 14)
        headerView.addSubview(card)
        
        let colorTag = UIView()
        colorTag.translatesAutoresizingMaskIntoConstraints = false
        colorTag.backgroundColor = ColorHelper.color(named: course.colorTag)
        colorTag.layer.cornerRadius = 3
        card.addSubview(colorTag)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "📚 \(course.name ?? "Course")"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        card.addSubview(titleLabel)
        
        let (totalTasks, completedTasks, progress) = CoreDataManager.shared.getCourseProgress(course: course)
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "\(topics.count) Modules/Topics • \(completedTasks)/\(totalTasks) Lessons Completed (\(Int(progress * 100))%)"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        card.addSubview(subtitleLabel)
        
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progress = progress
        progressBar.tintColor = ColorHelper.color(named: course.colorTag)
        progressBar.layer.cornerRadius = 2.5
        progressBar.clipsToBounds = true
        card.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            colorTag.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            colorTag.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            colorTag.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            colorTag.widthAnchor.constraint(equalToConstant: 5),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorTag.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            progressBar.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            progressBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            progressBar.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        tableView.tableHeaderView = headerView
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
                message: "Tap '+' in the top right to add\nchapters, topics, or units for \(course?.name ?? "this course")."
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
            message: "Enter topic name (e.g. Dynamic Programming, Newton's Laws).",
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
                self.setupHeaderBanner()
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
            self.setupHeaderBanner()
            self.showToast(message: "Topic added for Today!")
        }))
        
        alert.addAction(UIAlertAction(title: "📅 In 3 Days", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            HapticHelper.success()
            let targetDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
            CoreDataManager.shared.createTopic(title: title, deadline: targetDate, course: self.course)
            self.loadTopics()
            self.setupHeaderBanner()
            self.showToast(message: "Topic created!")
        }))
        
        alert.addAction(UIAlertAction(title: "🗓 Next Week", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            HapticHelper.success()
            let targetDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
            CoreDataManager.shared.createTopic(title: title, deadline: targetDate, course: self.course)
            self.loadTopics()
            self.setupHeaderBanner()
            self.showToast(message: "Topic created!")
        }))
        
        alert.addAction(UIAlertAction(title: "⚪ No Deadline", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.createTopic(title: title, deadline: nil, course: self.course)
            self.loadTopics()
            self.setupHeaderBanner()
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
                    self?.setupHeaderBanner()
                    self?.showToast(message: "Topic removed.")
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
