//
//  StatsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 3 — Shows real-time progress statistics and task completion rates.
//

import UIKit

class StatsViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Storyboard)
    @IBOutlet weak var totalCoursesLabel: UILabel?
    @IBOutlet weak var totalTopicsLabel: UILabel?
    @IBOutlet weak var totalTasksLabel: UILabel?
    @IBOutlet weak var completedTasksLabel: UILabel?
    @IBOutlet weak var completionRateLabel: UILabel?
    @IBOutlet weak var progressView: UIProgressView?
    @IBOutlet weak var motivationLabel: UILabel?
    
    @IBOutlet weak var overallProgressCard: UIView?
    @IBOutlet weak var numbersGridCard: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStats()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Study Analytics"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        overallProgressCard?.applyCardStyle(cornerRadius: 16)
        numbersGridCard?.applyCardStyle(cornerRadius: 16)
    }
    
    // MARK: - Refresh Data
    private func refreshStats() {
        let (courses, topics, tasks, completed, rate) = CoreDataManager.shared.getAppStats()
        
        totalCoursesLabel?.text = "\(courses)"
        totalTopicsLabel?.text = "\(topics)"
        totalTasksLabel?.text = "\(tasks)"
        completedTasksLabel?.text = "\(completed)"
        completionRateLabel?.text = "\(Int(rate))%"
        
        let progressFloat = tasks > 0 ? Float(completed) / Float(tasks) : 0.0
        progressView?.setProgress(progressFloat, animated: true)
        
        // Dynamic Motivation Message
        if tasks == 0 {
            motivationLabel?.text = "Add courses and study tasks to track your productivity!"
        } else if rate >= 100.0 {
            motivationLabel?.text = "🏆 Amazing! You have completed all study tasks!"
        } else if rate >= 60.0 {
            motivationLabel?.text = "🔥 Fantastic momentum! You're more than halfway done."
        } else if rate >= 30.0 {
            motivationLabel?.text = "💪 Solid progress! Keep up the daily study habit."
        } else {
            motivationLabel?.text = "🚀 A great journey starts with a single completed task!"
        }
    }
}
