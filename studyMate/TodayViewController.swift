//
//  TodayViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 1 — Ultra-clean, minimal Study Planner with custom Segment Control and centered clean status text when all caught up.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    private var currentTimeframe: StudyTimeframe = .today
    private var filteredTasks: [Task] = []
    
    // Top Pinned Segmented Bar
    private let segmentContainer = UIView()
    private let timeframeSegmentedControl = UISegmentedControl(items: ["📅 Today", "🌅 Tomorrow", "📆 Week", "🗓️ Month", "📋 All"])
    
    // Minimal Centered Status Label
    private let centeredStatusLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSegmentedBar()
        setupCenteredEmptyLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasksForCurrentTimeframe()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Study Planner"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        if tableView == nil {
            let tv = UITableView(frame: .zero, style: .plain)
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            tableView = tv
        } else {
            tableView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
    }
    
    // MARK: - Segmented Control Setup (Pinned at Top)
    private func setupSegmentedBar() {
        segmentContainer.translatesAutoresizingMaskIntoConstraints = false
        segmentContainer.backgroundColor = .clear
        view.addSubview(segmentContainer)
        
        timeframeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        timeframeSegmentedControl.selectedSegmentIndex = currentTimeframe.rawValue
        timeframeSegmentedControl.backgroundColor = UIColor.secondarySystemGroupedBackground
        timeframeSegmentedControl.selectedSegmentTintColor = .systemPurple
        timeframeSegmentedControl.layer.cornerRadius = 14
        timeframeSegmentedControl.layer.masksToBounds = true
        timeframeSegmentedControl.layer.borderWidth = 1
        timeframeSegmentedControl.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        
        timeframeSegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ], for: .selected)
        
        timeframeSegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ], for: .normal)
        
        timeframeSegmentedControl.addTarget(self, action: #selector(timeframeChanged(_:)), for: .valueChanged)
        segmentContainer.addSubview(timeframeSegmentedControl)
        
        NSLayoutConstraint.activate([
            // Segment Container pinned below navigation bar
            segmentContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentContainer.heightAnchor.constraint(equalToConstant: 48),
            
            timeframeSegmentedControl.topAnchor.constraint(equalTo: segmentContainer.topAnchor, constant: 4),
            timeframeSegmentedControl.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 16),
            timeframeSegmentedControl.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor, constant: -16),
            timeframeSegmentedControl.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: -6),
            
            // TableView placed below Segment Container
            tableView.topAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Minimal Centered Empty State Label
    private func setupCenteredEmptyLabel() {
        centeredStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        centeredStatusLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        centeredStatusLabel.textColor = .secondaryLabel
        centeredStatusLabel.textAlignment = .center
        centeredStatusLabel.numberOfLines = 0
        centeredStatusLabel.isHidden = true
        view.addSubview(centeredStatusLabel)
        
        NSLayoutConstraint.activate([
            centeredStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            centeredStatusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            centeredStatusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    // MARK: - Segment Action
    @objc private func timeframeChanged(_ sender: UISegmentedControl) {
        HapticHelper.lightImpact()
        if let selected = StudyTimeframe(rawValue: sender.selectedSegmentIndex) {
            currentTimeframe = selected
            
            UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.loadTasksForCurrentTimeframe()
            }, completion: nil)
        }
    }
    
    // MARK: - Data Loading
    private func loadTasksForCurrentTimeframe() {
        filteredTasks = CoreDataManager.shared.fetchTasks(for: currentTimeframe)
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        if filteredTasks.isEmpty {
            centeredStatusLabel.isHidden = false
            emptyStateLabel?.isHidden = true
            
            switch currentTimeframe {
            case .today:
                centeredStatusLabel.text = "All caught up for today 🎉"
            case .tomorrow:
                centeredStatusLabel.text = "All caught up for tomorrow 🌅"
            case .thisWeek:
                centeredStatusLabel.text = "All caught up for this week 📆"
            case .thisMonth:
                centeredStatusLabel.text = "All caught up for this month 🗓️"
            case .all:
                centeredStatusLabel.text = "All caught up 🎉"
            }
        } else {
            centeredStatusLabel.isHidden = true
            emptyStateLabel?.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = filteredTasks[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell {
            cell.configure(with: task)
            cell.onToggleDone = { [weak self] in
                guard let self = self else { return }
                HapticHelper.success()
                CoreDataManager.shared.toggleTaskDone(task)
                self.loadTasksForCurrentTimeframe()
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
        let task = filteredTasks[indexPath.row]
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
        let task = filteredTasks[indexPath.row]
        
        let completeAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            HapticHelper.success()
            CoreDataManager.shared.toggleTaskDone(task)
            self.loadTasksForCurrentTimeframe()
            self.showToast(message: "🎉 Lesson Completed!", icon: "sparkles", tintColor: .systemGreen)
            completion(true)
        }
        completeAction.backgroundColor = .systemGreen
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}
