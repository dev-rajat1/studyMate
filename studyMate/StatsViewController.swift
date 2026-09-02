//
//  StatsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 3 — Deep Subject Mastery Matrix, Learning Analytics & AI Revision Insights.
//

import UIKit

class StatsViewController: UIViewController {

    // MARK: - IBOutlets (Storyboard Compatibility)
    @IBOutlet weak var totalCoursesLabel: UILabel?
    @IBOutlet weak var totalTopicsLabel: UILabel?
    @IBOutlet weak var totalTasksLabel: UILabel?
    @IBOutlet weak var completedTasksLabel: UILabel?
    @IBOutlet weak var completionRateLabel: UILabel?
    @IBOutlet weak var progressView: UIProgressView?
    @IBOutlet weak var motivationLabel: UILabel?
    
    @IBOutlet weak var overallProgressCard: UIView?
    @IBOutlet weak var numbersGridCard: UIView?
    
    // Dynamic Subject Mastery Container
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let masterySectionStack = UIStackView()
    private let recommendationCard = UIView()
    private let recommendationTextLabel = UILabel()
    private let aiCoverageCard = UIView()
    private let aiCoverageLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMasteryViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshDeepAnalytics()
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
    }
    
    // MARK: - Dynamic Deep Analytics Views
    private func setupMasteryViews() {
        // Embed scroll view for deep matrix if not using storyboard scroll
        if overallProgressCard == nil {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.alwaysBounceVertical = true
            view.addSubview(scrollView)
            
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            contentStack.axis = .vertical
            contentStack.spacing = 16
            contentStack.alignment = .fill
            scrollView.addSubview(contentStack)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
                contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
                contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
            ])
        }
    }
    
    // MARK: - Refresh & Render Deep Analytics
    private func refreshDeepAnalytics() {
        let (courses, topics, tasks, completed, rate) = CoreDataManager.shared.getAppStats()
        let insights = CoreDataManager.shared.getCourseMasteryInsights()
        
        totalCoursesLabel?.text = "\(courses)"
        totalTopicsLabel?.text = "\(topics)"
        totalTasksLabel?.text = "\(tasks)"
        completedTasksLabel?.text = "\(completed)"
        completionRateLabel?.text = "\(Int(rate))%"
        
        let progressFloat = tasks > 0 ? Float(completed) / Float(tasks) : 0.0
        progressView?.setProgress(progressFloat, animated: true)
        
        // Find subject needing highest priority (lowest completion rate or active tasks)
        let lowestCourse = insights.filter { $0.totalLessons > 0 && $0.progress < 1.0 }.min(by: { $0.progress < $1.progress })
        let totalAISummaries = insights.reduce(0) { $0 + $1.aiSummaryCount }
        
        // Motivation & Guidance Message
        if tasks == 0 {
            motivationLabel?.text = "🌱 Create courses and study lessons to unlock detailed subject mastery metrics!"
        } else if rate >= 100.0 {
            motivationLabel?.text = "🏆 Master Level! You've completed 100% of your curriculum!"
        } else if let focus = lowestCourse {
            let pct = Int(focus.progress * 100)
            motivationLabel?.text = "🎯 Focus Priority: \"\(focus.course.name ?? "Subject")\" is at \(pct)% mastery. Finish remaining lessons to balance your study pace!"
        } else {
            motivationLabel?.text = "🔥 Great momentum! \(totalAISummaries) AI summaries ready for active recall."
        }
    }
}
