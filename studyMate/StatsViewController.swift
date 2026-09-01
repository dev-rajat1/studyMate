//
//  StatsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 3 — Modern Visual Study Analytics with animated progress gauge and 4-metric matrix.
//

import UIKit

class StatsViewController: UIViewController {

    // MARK: - IBOutlets
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
        animateStatsEntrance()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Study Analytics"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        overallProgressCard?.applyCardStyle(cornerRadius: 18)
        numbersGridCard?.applyCardStyle(cornerRadius: 18)
        
        progressView?.layer.cornerRadius = 3
        progressView?.clipsToBounds = true
    }
    
    private func animateStatsEntrance() {
        overallProgressCard?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        overallProgressCard?.alpha = 0.0
        
        numbersGridCard?.transform = CGAffineTransform(translationX: 0, y: 20)
        numbersGridCard?.alpha = 0.0
        
        UIView.animate(withDuration: 0.45, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.overallProgressCard?.transform = .identity
            self.overallProgressCard?.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.45, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.numbersGridCard?.transform = .identity
            self.numbersGridCard?.alpha = 1.0
        }, completion: nil)
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
            motivationLabel?.text = "Add courses and lessons to track your productivity!"
        } else if rate >= 100.0 {
            motivationLabel?.text = "🏆 Amazing! You have completed all study lessons!"
        } else if rate >= 60.0 {
            motivationLabel?.text = "🔥 Fantastic momentum! You're more than halfway done."
        } else if rate >= 30.0 {
            motivationLabel?.text = "💪 Solid progress! Keep up the daily study habit."
        } else {
            motivationLabel?.text = "🚀 A great journey starts with a single completed lesson!"
        }
    }
}
