//
//  TasksListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Hierarchy Level 3 — Displays all Lessons under a Module, shows Module progress, search filter, and triggers AI Summary/Quiz.
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
    private var allTasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var searchController: UISearchController?
    
    private var isSearching: Bool {
        guard let sc = searchController else { return false }
        return sc.isActive && !(sc.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
        setupHeaderBanner()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Lessons"
        navigationItem.backButtonTitle = "Lessons"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        
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
        addButton.tintColor = .systemBlue
        
        navigationItem.rightBarButtonItems = [addButton, aiButton]
        
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
        tableView.estimatedRowHeight = 92
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
    }
    
    private func setupSearchController() {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringFullScreenContent = false
        sc.searchBar.placeholder = "Search lessons or notes..."
        navigationItem.searchController = sc
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        self.searchController = sc
    }
    
    private func setupHeaderBanner() {
        guard let topic = topic, !isSearching else {
            tableView.tableHeaderView = nil
            return
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 114))
        headerView.backgroundColor = .clear
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 18)
        headerView.addSubview(card)
        
        let courseName = topic.course?.name ?? "Course"
        
        let breadcrumbPill = UIView()
        breadcrumbPill.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbPill.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        breadcrumbPill.layer.cornerRadius = 8
        breadcrumbPill.clipsToBounds = true
        
        let breadcrumbLabel = UILabel()
        breadcrumbLabel.translatesAutoresizingMaskIntoConstraints = false
        breadcrumbLabel.text = "📚 \(courseName) › 📖 \(topic.title ?? "Module")"
        breadcrumbLabel.font = .systemFont(ofSize: 11, weight: .bold)
        breadcrumbLabel.textColor = .systemPurple
        breadcrumbPill.addSubview(breadcrumbLabel)
        card.addSubview(breadcrumbPill)
        
        let (total, completed, progress) = CoreDataManager.shared.getTopicProgress(topic: topic)
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = total == 0 ? "No lessons added yet" : "📝 \(completed) of \(total) Lessons Done (\(Int(progress * 100))%)"
        statusLabel.font = .systemFont(ofSize: 15, weight: .bold)
        statusLabel.textColor = total > 0 && completed == total ? .systemGreen : .label
        card.addSubview(statusLabel)
        
        let pBar = UIProgressView(progressViewStyle: .default)
        pBar.translatesAutoresizingMaskIntoConstraints = false
        pBar.progress = progress
        pBar.tintColor = ColorHelper.color(named: topic.course?.colorTag)
        pBar.trackTintColor = UIColor.separator.withAlphaComponent(0.15)
        pBar.layer.cornerRadius = 3
        pBar.clipsToBounds = true
        card.addSubview(pBar)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),
            
            breadcrumbPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            breadcrumbPill.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            
            breadcrumbLabel.leadingAnchor.constraint(equalTo: breadcrumbPill.leadingAnchor, constant: 8),
            breadcrumbLabel.trailingAnchor.constraint(equalTo: breadcrumbPill.trailingAnchor, constant: -8),
            breadcrumbLabel.topAnchor.constraint(equalTo: breadcrumbPill.topAnchor, constant: 4),
            breadcrumbLabel.bottomAnchor.constraint(equalTo: breadcrumbPill.bottomAnchor, constant: -4),
            
            statusLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            statusLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            statusLabel.topAnchor.constraint(equalTo: breadcrumbPill.bottomAnchor, constant: 8),
            
            pBar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            pBar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            pBar.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            pBar.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Data Management
    private func loadTasks() {
        guard let topic = topic else { return }
        allTasks = CoreDataManager.shared.fetchTasks(for: topic)
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let displayList = isSearching ? filteredTasks : allTasks
        if displayList.isEmpty {
            emptyStateLabel?.isHidden = false
            let isSearchEmpty = isSearching
            tableView.setEmptyState(
                iconName: isSearchEmpty ? "magnifyingglass" : "book.pages",
                title: isSearchEmpty ? "No Lessons Found" : "No Lessons Yet",
                message: isSearchEmpty ? "Try a different search query." : "Tap '+' in the top right to add a\nlesson with study notes."
            )
        } else {
            emptyStateLabel?.isHidden = true
            tableView.removeEmptyState()
        }
    }
    
    // MARK: - Actions
    @objc func addTaskTapped() {
        HapticHelper.lightImpact()
        presentTaskDetail(taskToEdit: nil)
    }
    
    private func presentTaskDetail(taskToEdit: Task?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController") as? TaskDetailViewController {
            detailVC.topic = self.topic
            detailVC.taskToEdit = taskToEdit
            detailVC.onSaveCompleted = { [weak self] in
                self?.loadTasks()
                self?.setupHeaderBanner()
            }
            let nav = UINavigationController(rootViewController: detailVC)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
        }
    }
    
    @objc func aiAssistantTapped() {
        HapticHelper.mediumImpact()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let aiVC = storyboard.instantiateViewController(withIdentifier: "AISummaryViewController") as? AISummaryViewController {
            aiVC.topic = self.topic
            let nav = UINavigationController(rootViewController: aiVC)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension TasksListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            filteredTasks = []
            tableView.reloadData()
            setupHeaderBanner()
            updateEmptyState()
            return
        }
        
        filteredTasks = allTasks.filter {
            let titleMatch = ($0.title ?? "").localizedCaseInsensitiveContains(text)
            let notesMatch = ($0.notes ?? "").localizedCaseInsensitiveContains(text)
            return titleMatch || notesMatch
        }
        tableView.reloadData()
        setupHeaderBanner()
        updateEmptyState()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : allTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let displayList = isSearching ? filteredTasks : allTasks
        let task = displayList[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleDone = { [weak self] in
                HapticHelper.success()
                CoreDataManager.shared.toggleTaskDone(task)
                self?.loadTasks()
                self?.setupHeaderBanner()
                self?.showToast(
                    message: task.isDone ? "Lesson Marked Done!" : "Lesson Marked Pending",
                    icon: task.isDone ? "checkmark.circle.fill" : "circle",
                    tintColor: task.isDone ? .systemGreen : .systemGray
                )
            }
            cell.animateGlideIn(delayIndex: indexPath.row)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultTaskCell")
        cell.textLabel?.text = task.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cell.detailTextLabel?.text = task.notes?.isEmpty == false ? "📝 \(task.notes ?? "")" : "No notes yet"
        cell.accessoryType = task.isDone ? .checkmark : .none
        cell.animateGlideIn(delayIndex: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let displayList = isSearching ? filteredTasks : allTasks
        let selectedTask = displayList[indexPath.row]
        HapticHelper.lightImpact()
        presentTaskDetail(taskToEdit: selectedTask)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let displayList = isSearching ? filteredTasks : allTasks
        let task = displayList[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Lesson?",
                message: "Are you sure you want to delete '\(task.title ?? "this lesson")' and its notes?",
                confirmTitle: "Delete",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteTask(task)
                    self?.loadTasks()
                    self?.setupHeaderBanner()
                    self?.showToast(message: "Lesson deleted.", icon: "trash.fill", tintColor: .systemRed)
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.presentTaskDetail(taskToEdit: task)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

