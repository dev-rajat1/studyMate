//
//  StatsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 3 — Modern Visual Study Analytics with animated progress gauge and 4-metric Bento matrix.
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
        
        overallProgressCard?.applyCardStyle(cornerRadius: 20)
        numbersGridCard?.applyCardStyle(cornerRadius: 20)
        
        progressView?.layer.cornerRadius = 4
        progressView?.clipsToBounds = true
        progressView?.tintColor = .systemPurple
        progressView?.trackTintColor = UIColor.separator.withAlphaComponent(0.15)
        
        totalCoursesLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        totalTopicsLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        totalTasksLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        completedTasksLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        completionRateLabel?.font = .systemFont(ofSize: 24, weight: .heavy)
        completionRateLabel?.textColor = .systemPurple
    }
    
    private func animateStatsEntrance() {
        overallProgressCard?.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        overallProgressCard?.alpha = 0.0
        
        numbersGridCard?.transform = CGAffineTransform(translationX: 0, y: 24)
        numbersGridCard?.alpha = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.overallProgressCard?.transform = .identity
            self.overallProgressCard?.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
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
            motivationLabel?.text = "🌱 Create courses and study lessons to unlock detailed productivity analytics!"
        } else if rate >= 100.0 {
            motivationLabel?.text = "🏆 Master Level! You've completed 100% of your curriculum!"
        } else if rate >= 60.0 {
            motivationLabel?.text = "🔥 Fantastic momentum! You're in the top study flow."
        } else if rate >= 30.0 {
            motivationLabel?.text = "💪 Great progress! Keep up the daily revision habit."
        } else {
            motivationLabel?.text = "🚀 A great journey starts with a single completed lesson!"
        }
    }
}

