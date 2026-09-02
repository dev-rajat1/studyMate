//
//  TopicsListViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Hierarchy Level 2 — Displays all Modules under a selected Course with persistent Course Header banner.
//

import UIKit

class TopicsListViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    var course: Course!
    private var allTopics: [Topic] = []
    private var filteredTopics: [Topic] = []
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
        loadTopics()
        setupHeaderBanner()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Modules"
        navigationItem.backButtonTitle = "Modules"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        
        let addBtn = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTopicTapped)
        )
        addBtn.tintColor = ColorHelper.color(named: course?.colorTag)
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
        tableView.estimatedRowHeight = 92
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
    }
    
    private func setupSearchController() {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringFullScreenContent = false
        sc.searchBar.placeholder = "Search modules..."
        navigationItem.searchController = sc
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        self.searchController = sc
    }
    
    private func setupHeaderBanner() {
        guard let course = course, !isSearching else {
            tableView.tableHeaderView = nil
            return
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 104))
        headerView.backgroundColor = .clear
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 18)
        headerView.addSubview(card)
        
        let courseColor = ColorHelper.color(named: course.colorTag)
        
        let colorTag = UIView()
        colorTag.translatesAutoresizingMaskIntoConstraints = false
        colorTag.backgroundColor = courseColor
        colorTag.layer.cornerRadius = 3
        card.addSubview(colorTag)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "📚 \(course.name ?? "Course")"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        card.addSubview(titleLabel)
        
        let (totalTasks, completedTasks, progress) = CoreDataManager.shared.getCourseProgress(course: course)
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "📖 \(allTopics.count) \(allTopics.count == 1 ? "Module" : "Modules") • \(completedTasks)/\(totalTasks) Lessons (\(Int(progress * 100))%)"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        card.addSubview(subtitleLabel)
        
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progress = progress
        progressBar.tintColor = courseColor
        progressBar.trackTintColor = UIColor.separator.withAlphaComponent(0.15)
        progressBar.layer.cornerRadius = 3
        progressBar.clipsToBounds = true
        card.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),
            
            colorTag.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            colorTag.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            colorTag.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            colorTag.widthAnchor.constraint(equalToConstant: 5),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorTag.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            progressBar.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            progressBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            progressBar.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Data Management
    private func loadTopics() {
        guard let course = course else { return }
        allTopics = CoreDataManager.shared.fetchTopics(for: course)
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let displayList = isSearching ? filteredTopics : allTopics
        if displayList.isEmpty {
            emptyStateLabel?.isHidden = false
            let isSearchEmpty = isSearching
            tableView.setEmptyState(
                iconName: isSearchEmpty ? "magnifyingglass" : "square.stack.3d.up",
                title: isSearchEmpty ? "No Modules Found" : "No Modules Added",
                message: isSearchEmpty ? "Try a different search query." : "Tap '+' in the top right to add\nmodules for \(course?.name ?? "this course")."
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
            title: isEditing ? "Edit Module" : "Create New Module",
            message: "Enter module title for \(course?.name ?? "Course").",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "e.g. Module 1: Binary Trees"
            textField.text = existingTopic?.title
            textField.autocapitalizationType = .sentences
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Save" : "Add Module", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
                return
            }
            
            HapticHelper.success()
            if isEditing, let topic = existingTopic {
                CoreDataManager.shared.updateTopic(topic, title: title, deadline: topic.deadline)
                self?.showToast(message: "Module updated!", icon: "checkmark.circle.fill", tintColor: .systemBlue)
            } else if let course = self?.course {
                CoreDataManager.shared.createTopic(title: title, deadline: nil, course: course)
                self?.showToast(message: "📖 Module Created!", icon: "plus.circle.fill", tintColor: ColorHelper.color(named: course.colorTag))
            }
            
            self?.loadTopics()
            self?.setupHeaderBanner()
        }))
        
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension TopicsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            filteredTopics = []
            tableView.reloadData()
            setupHeaderBanner()
            updateEmptyState()
            return
        }
        
        filteredTopics = allTopics.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(text)
        }
        tableView.reloadData()
        setupHeaderBanner()
        updateEmptyState()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TopicsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTopics.count : allTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let displayList = isSearching ? filteredTopics : allTopics
        let topic = displayList[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? TopicCell {
            cell.configure(with: topic)
            cell.animateGlideIn(delayIndex: indexPath.row)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTopicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultTopicCell")
        cell.textLabel?.text = topic.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        let (total, completed, _) = CoreDataManager.shared.getTopicProgress(topic: topic)
        cell.detailTextLabel?.text = "\(completed)/\(total) lessons completed"
        cell.accessoryType = .disclosureIndicator
        cell.animateGlideIn(delayIndex: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let displayList = isSearching ? filteredTopics : allTopics
        let selectedTopic = displayList[indexPath.row]
        HapticHelper.lightImpact()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tasksVC = storyboard.instantiateViewController(withIdentifier: "TasksListViewController") as? TasksListViewController {
            tasksVC.topic = selectedTopic
            navigationController?.pushViewController(tasksVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let displayList = isSearching ? filteredTopics : allTopics
        let topic = displayList[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showConfirmationAlert(
                title: "Delete Module?",
                message: "Deleting '\(topic.title ?? "this module")' will remove all its lessons and notes.",
                confirmTitle: "Delete All",
                isDestructive: true,
                onConfirm: {
                    CoreDataManager.shared.deleteTopic(topic)
                    self?.loadTopics()
                    self?.setupHeaderBanner()
                    self?.showToast(message: "Module deleted.", icon: "trash.fill", tintColor: .systemRed)
                    completion(true)
                }
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showTopicPrompt(existingTopic: topic)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

