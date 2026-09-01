//
//  AISummaryViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Modal view for AI Notes Summary & Practice Quiz generation with state management.
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
        view.backgroundColor = .systemBackground
        
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
        contentTextView?.backgroundColor = .secondarySystemBackground
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
        
        setLoadingState(true, message: isSummaryMode ? "🤖 Gemini AI is summarizing your study notes..." : "🎯 Gemini AI is crafting practice quiz questions...")
        
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
            contentTextView?.text = "⏳ Generating high-yield study material with Gemini AI...\nPlease hold on a moment."
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
