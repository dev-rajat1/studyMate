//
//  AISummaryViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Modal view for AI Notes Summary & Practice Quiz generation with state management.
//

import UIKit

class AISummaryViewController: UIViewController {

    // MARK: - IBOutlets (Connect in Storyboard)
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
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        // TextView Styling
        contentTextView?.layer.cornerRadius = 10
        contentTextView?.backgroundColor = .secondarySystemBackground
        contentTextView?.isEditable = false
        contentTextView?.font = .systemFont(ofSize: 15, weight: .regular)
        
        // Button styling
        regenerateButton?.layer.cornerRadius = 8
        saveSummaryButton?.layer.cornerRadius = 8
    }
    
    private func loadInitialContent() {
        // If an AI summary was previously generated and saved, show it immediately
        if let savedSummary = topic.aiSummary?.content, !savedSummary.isEmpty {
            loadedSummaryText = savedSummary
            displayContent(savedSummary)
            statusLabel?.text = "Saved AI Summary Loaded"
        } else {
            fetchAIContent()
        }
    }
    
    // MARK: - AI Content Generation (async/await)
    private func fetchAIContent() {
        guard !isLoading else { return }
        
        let isSummaryMode = (segmentedControl?.selectedSegmentIndex ?? 0) == 0
        
        // Show Loading State
        setLoadingState(true, message: isSummaryMode ? "🤖 Generating study summary..." : "🎯 Generating practice quiz questions...")
        
        Task {
            do {
                if isSummaryMode {
                    let result = try await AIService.shared.generateSummary(for: self.topic)
                    await MainActor.run {
                        self.loadedSummaryText = result
                        self.displayContent(result)
                        self.setLoadingState(false, message: "Summary generated successfully!")
                        // Auto-save generated summary to Core Data
                        CoreDataManager.shared.saveAISummary(content: result, for: self.topic)
                    }
                } else {
                    let result = try await AIService.shared.generateQuiz(for: self.topic)
                    await MainActor.run {
                        self.loadedQuizText = result
                        self.displayContent(result)
                        self.setLoadingState(false, message: "Quiz generated successfully!")
                    }
                }
            } catch {
                await MainActor.run {
                    self.setLoadingState(false, message: "Error: \(error.localizedDescription)")
                    self.contentTextView?.text = "⚠️ Could not generate AI content.\n\n\(error.localizedDescription)\n\nPlease check your internet connection or settings, then tap 'Regenerate' to try again."
                }
            }
        }
    }
    
    // MARK: - State Management
    private func setLoadingState(_ loading: Bool, message: String) {
        isLoading = loading
        statusLabel?.text = message
        regenerateButton?.isEnabled = !loading
        saveSummaryButton?.isEnabled = !loading
        segmentedControl?.isEnabled = !loading
        
        if loading {
            activityIndicator?.startAnimating()
            activityIndicator?.isHidden = false
            contentTextView?.text = "Please wait while AI processes your notes and study tasks..."
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
        }
    }
    
    private func displayContent(_ text: String) {
        contentTextView?.text = text
    }
    
    // MARK: - Actions (Connect in Storyboard)
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Summary Tab
            if let existing = loadedSummaryText {
                displayContent(existing)
                statusLabel?.text = "Showing Summary"
            } else {
                fetchAIContent()
            }
        } else {
            // Quiz Tab
            if let existing = loadedQuizText {
                displayContent(existing)
                statusLabel?.text = "Showing Practice Quiz"
            } else {
                fetchAIContent()
            }
        }
    }
    
    @IBAction func regenerateTapped(_ sender: UIButton) {
        fetchAIContent()
    }
    
    @IBAction func saveSummaryTapped(_ sender: UIButton) {
        guard let text = contentTextView?.text, !text.isEmpty else { return }
        CoreDataManager.shared.saveAISummary(content: text, for: self.topic)
        showAlert(title: "Saved", message: "AI Study Summary has been saved for this topic!")
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
}
