//
//  TodayViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 1 — Modern Study Dashboard displaying today's pending lessons, daily greeting, and progress.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: - IBOutlets
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
        setupDashboardHeader()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Today's Focus"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
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
    
    // MARK: - Dashboard Header Banner
    private func setupDashboardHeader() {
        let count = pendingTasks.count
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 136))
        headerView.backgroundColor = .clear
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 18)
        headerView.addSubview(card)
        
        let topStack = UIStackView()
        topStack.axis = .horizontal
        topStack.distribution = .equalSpacing
        topStack.alignment = .center
        topStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Pill Badge
        let datePill = UIView()
        datePill.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        datePill.layer.cornerRadius = 8
        datePill.clipsToBounds = true
        
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "🗓 \(Date().formattedGreetingDate().uppercased())"
        dateLabel.font = .systemFont(ofSize: 11, weight: .bold)
        dateLabel.textColor = .systemPurple
        datePill.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: datePill.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: datePill.trailingAnchor, constant: -8),
            dateLabel.topAnchor.constraint(equalTo: datePill.topAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(equalTo: datePill.bottomAnchor, constant: -4)
        ])
        
        // Streak Badge
        let streakPill = UIView()
        streakPill.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
        streakPill.layer.cornerRadius = 8
        streakPill.clipsToBounds = true
        
        let streakBadge = UILabel()
        streakBadge.translatesAutoresizingMaskIntoConstraints = false
        streakBadge.text = "🔥 Daily Focus"
        streakBadge.font = .systemFont(ofSize: 11, weight: .bold)
        streakBadge.textColor = .systemOrange
        streakPill.addSubview(streakBadge)
        
        NSLayoutConstraint.activate([
            streakBadge.leadingAnchor.constraint(equalTo: streakPill.leadingAnchor, constant: 8),
            streakBadge.trailingAnchor.constraint(equalTo: streakPill.trailingAnchor, constant: -8),
            streakBadge.topAnchor.constraint(equalTo: streakPill.topAnchor, constant: 4),
            streakBadge.bottomAnchor.constraint(equalTo: streakPill.bottomAnchor, constant: -4)
        ])
        
        topStack.addArrangedSubview(datePill)
        topStack.addArrangedSubview(streakPill)
        card.addSubview(topStack)
        
        let greetingLabel = UILabel()
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.text = count == 0 ? "🎉 You're all caught up today!" : "⚡ \(count) \(count == 1 ? "Lesson" : "Lessons") Remaining"
        greetingLabel.font = .systemFont(ofSize: 18, weight: .bold)
        greetingLabel.textColor = .label
        card.addSubview(greetingLabel)
        
        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.text = count == 0 ? "Great job! Keep up the momentum and review AI notes." : "Review notes, take practice quizzes, and check off items."
        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .secondaryLabel
        subLabel.numberOfLines = 2
        card.addSubview(subLabel)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -6),
            
            topStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            topStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            topStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            greetingLabel.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            greetingLabel.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8),
            greetingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            
            subLabel.leadingAnchor.constraint(equalTo: topStack.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            subLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Data Loading
    private func loadPendingTasks() {
        pendingTasks = CoreDataManager.shared.fetchTodayPendingTasks()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        if pendingTasks.isEmpty {
            emptyStateLabel?.isHidden = false
            tableView.setEmptyState(
                iconName: "sparkles",
                title: "🎉 All Caught Up!",
                message: "No pending lessons for today.\nExplore your courses or create a new lesson!"
            )
        } else {
            emptyStateLabel?.isHidden = true
            tableView.removeEmptyState()
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleDone = { [weak self] in
                guard let self = self else { return }
                HapticHelper.success()
                CoreDataManager.shared.toggleTaskDone(task)
                self.loadPendingTasks()
                self.setupDashboardHeader()
                self.showToast(message: "✅ Lesson Completed!", icon: "checkmark.circle.fill", tintColor: .systemGreen)
            }
            cell.animateGlideIn(delayIndex: indexPath.row)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = task.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        let topicName = task.topic?.title ?? "General"
        let courseName = task.topic?.course?.name ?? "Course"
        cell.detailTextLabel?.text = "📁 \(courseName) › \(topicName)"
        cell.accessoryType = .disclosureIndicator
        cell.animateGlideIn(delayIndex: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = pendingTasks[indexPath.row]
        HapticHelper.lightImpact()
        
        if let topic = task.topic {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tasksVC = storyboard.instantiateViewController(withIdentifier: "TasksListViewController") as? TasksListViewController {
                tasksVC.topic = topic
                navigationController?.pushViewController(tasksVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = pendingTasks[indexPath.row]
        
        let completeAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.toggleTaskDone(task)
            self.loadPendingTasks()
            self.setupDashboardHeader()
            self.showToast(message: "🎉 Lesson Completed!", icon: "sparkles", tintColor: .systemGreen)
            completion(true)
        }
        completeAction.backgroundColor = .systemGreen
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}

