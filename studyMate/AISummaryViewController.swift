//
//  AISummaryViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Modal view for dynamic AI Notes Summary & Scalable Practice Quiz generation.
//

import UIKit

class AISummaryViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    @IBOutlet weak var contentTextView: UITextView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var regenerateButton: UIButton?
    @IBOutlet weak var saveSummaryButton: UIButton?
    
    // MARK: - Properties
    var topic: Topic!
    private var loadedSummaryText: String?
    private var loadedQuizText: String?
    private var isLoading = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialContent()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "AI Study Assistant"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "doc.on.doc"),
            style: .plain,
            target: self,
            action: #selector(copyContentTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        contentTextView?.layer.cornerRadius = 14
        contentTextView?.layer.borderWidth = 0.5
        contentTextView?.layer.borderColor = UIColor.separator.withAlphaComponent(0.25).cgColor
        contentTextView?.backgroundColor = .secondarySystemGroupedBackground
        contentTextView?.isEditable = false
        contentTextView?.font = .systemFont(ofSize: 15, weight: .regular)
        contentTextView?.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        
        regenerateButton?.layer.cornerRadius = 12
        saveSummaryButton?.layer.cornerRadius = 12
    }
    
    private func loadInitialContent() {
        if let savedSummary = topic.aiSummary?.content, !savedSummary.isEmpty {
            loadedSummaryText = savedSummary
            displayContent(savedSummary)
            statusLabel?.text = "✨ Saved AI Summary Loaded"
            statusLabel?.textColor = .systemGreen
        } else {
            fetchAIContent()
        }
    }
    
    // MARK: - AI Content Generation
    private func fetchAIContent() {
        guard !isLoading else { return }
        
        let isSummaryMode = (segmentedControl?.selectedSegmentIndex ?? 0) == 0
        
        let tasks = (topic.tasks as? Set<Task>) ?? []
        let totalLength = tasks.reduce(0) { $0 + ($1.notes?.count ?? 0) }
        
        let loadingMsg = isSummaryMode
            ? "🤖 Gemini AI is analyzing \(tasks.count) lessons & \(totalLength) characters of notes..."
            : "🎯 Gemini AI is generating a tailored quiz based on your full notes..."
        
        setLoadingState(true, message: loadingMsg)
        
        if isSummaryMode {
            AIService.shared.generateSummary(for: self.topic) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let summary):
                        HapticHelper.success()
                        self.loadedSummaryText = summary
                        self.displayContent(summary)
                        self.setLoadingState(false, message: "⚡ Generated with Gemini 3.7 Flash")
                        CoreDataManager.shared.saveAISummary(content: summary, for: self.topic)
                    case .failure(let error):
                        self.setLoadingState(false, message: "Error: \(error.localizedDescription)")
                        self.contentTextView?.text = "⚠️ Could not generate AI content.\n\n\(error.localizedDescription)\n\nPlease check your settings or tap 'Regenerate' to try again."
                    }
                }
            }
        } else {
            AIService.shared.generateQuiz(for: self.topic) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let quiz):
                        HapticHelper.success()
                        self.loadedQuizText = quiz
                        self.displayContent(quiz)
                        self.setLoadingState(false, message: "⚡ Generated with Gemini 3.7 Flash")
                    case .failure(let error):
                        self.setLoadingState(false, message: "Error: \(error.localizedDescription)")
                        self.contentTextView?.text = "⚠️ Could not generate AI content.\n\n\(error.localizedDescription)\n\nPlease check your settings or tap 'Regenerate' to try again."
                    }
                }
            }
        }
    }
    
    // MARK: - State Management
    private func setLoadingState(_ loading: Bool, message: String) {
        isLoading = loading
        statusLabel?.text = message
        statusLabel?.textColor = loading ? .systemPurple : .secondaryLabel
        regenerateButton?.isEnabled = !loading
        saveSummaryButton?.isEnabled = !loading
        segmentedControl?.isEnabled = !loading
        
        if loading {
            activityIndicator?.startAnimating()
            activityIndicator?.isHidden = false
            contentTextView?.text = "⏳ Analyzing your study notes and generating customized learning material with Gemini AI...\n\nPlease hold on a moment."
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
        }
    }
    
    private func displayContent(_ text: String) {
        contentTextView?.text = text
    }
    
    // MARK: - Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        HapticHelper.lightImpact()
        if sender.selectedSegmentIndex == 0 {
            if let existing = loadedSummaryText {
                displayContent(existing)
                statusLabel?.text = "Showing Summary"
            } else {
                fetchAIContent()
            }
        } else {
            if let existing = loadedQuizText {
                displayContent(existing)
                statusLabel?.text = "Showing Practice Quiz"
            } else {
                fetchAIContent()
            }
        }
    }
    
    @IBAction func regenerateTapped(_ sender: UIButton) {
        HapticHelper.lightImpact()
        fetchAIContent()
    }
    
    @IBAction func saveSummaryTapped(_ sender: UIButton) {
        guard let text = contentTextView?.text, !text.isEmpty else { return }
        HapticHelper.success()
        CoreDataManager.shared.saveAISummary(content: text, for: self.topic)
        showToast(message: "💾 Saved to Core Data!")
    }
    
    @objc func copyContentTapped() {
        guard let text = contentTextView?.text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        HapticHelper.success()
        showToast(message: "📋 Copied to Clipboard!")
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
}
