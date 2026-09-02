//
//  AISummaryViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Modal view for dynamic AI Notes Summary & Scalable Practice Quiz generation with Gemini 3.7 Flash.
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
    
    private let heroHeaderCard = UIView()
    private let bottomActionDock = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHeroHeader()
        setupBottomActionDock()
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
        navigationItem.leftBarButtonItem?.tintColor = .systemPurple
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemPurple
        
        contentTextView?.layer.cornerRadius = 18
        contentTextView?.layer.borderWidth = 0.5
        contentTextView?.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        contentTextView?.backgroundColor = .secondarySystemGroupedBackground
        contentTextView?.isEditable = false
        contentTextView?.font = .systemFont(ofSize: 15, weight: .regular)
        contentTextView?.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 64, right: 16)
        
        segmentedControl?.selectedSegmentTintColor = .systemPurple
        segmentedControl?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
    
    private func setupHeroHeader() {
        heroHeaderCard.translatesAutoresizingMaskIntoConstraints = false
        heroHeaderCard.applyCardStyle(cornerRadius: 16)
        heroHeaderCard.backgroundColor = .secondarySystemGroupedBackground
        view.addSubview(heroHeaderCard)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let sparkleIcon = UIImageView(image: UIImage(systemName: "sparkles"))
        sparkleIcon.tintColor = .systemPurple
        sparkleIcon.contentMode = .scaleAspectFit
        sparkleIcon.translatesAutoresizingMaskIntoConstraints = false
        sparkleIcon.widthAnchor.constraint(equalToConstant: 22).isActive = true
        sparkleIcon.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 2
        
        let titleLbl = UILabel()
        titleLbl.text = "Gemini 3.7 Flash Intelligence"
        titleLbl.font = .systemFont(ofSize: 14, weight: .bold)
        titleLbl.textColor = .systemPurple
        
        let subtitleLbl = UILabel()
        subtitleLbl.text = "Topic: \(topic.title ?? "Module Notes")"
        subtitleLbl.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLbl.textColor = .secondaryLabel
        
        vStack.addArrangedSubview(titleLbl)
        vStack.addArrangedSubview(subtitleLbl)
        
        stack.addArrangedSubview(sparkleIcon)
        stack.addArrangedSubview(vStack)
        heroHeaderCard.addSubview(stack)
        
        NSLayoutConstraint.activate([
            heroHeaderCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            heroHeaderCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            heroHeaderCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            heroHeaderCard.heightAnchor.constraint(equalToConstant: 54),
            
            stack.leadingAnchor.constraint(equalTo: heroHeaderCard.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: heroHeaderCard.trailingAnchor, constant: -14),
            stack.centerYAnchor.constraint(equalTo: heroHeaderCard.centerYAnchor)
        ])
    }
    
    private func setupBottomActionDock() {
        bottomActionDock.translatesAutoresizingMaskIntoConstraints = false
        bottomActionDock.applyCardStyle(cornerRadius: 22)
        bottomActionDock.backgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(white: 0.20, alpha: 0.95) : UIColor(white: 0.96, alpha: 0.95)
        }
        
        let copyBtn = UIButton(type: .system)
        copyBtn.setTitle("📋 Copy", for: .normal)
        copyBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        copyBtn.addTarget(self, action: #selector(copyContentTapped), for: .touchUpInside)
        
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("💾 Save Summary", for: .normal)
        saveBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        saveBtn.addTarget(self, action: #selector(saveSummaryTapped(_:)), for: .touchUpInside)
        
        let regenBtn = UIButton(type: .system)
        regenBtn.setTitle("🔄 Regenerate", for: .normal)
        regenBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        regenBtn.addTarget(self, action: #selector(regenerateTapped(_:)), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [copyBtn, saveBtn, regenBtn])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        bottomActionDock.addSubview(stack)
        
        view.addSubview(bottomActionDock)
        
        NSLayoutConstraint.activate([
            bottomActionDock.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomActionDock.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomActionDock.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            bottomActionDock.heightAnchor.constraint(equalToConstant: 44),
            
            stack.leadingAnchor.constraint(equalTo: bottomActionDock.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: bottomActionDock.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: bottomActionDock.centerYAnchor)
        ])
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
            ? "🤖 Gemini AI is analyzing \(tasks.count) lessons & \(totalLength) characters..."
            : "🎯 Gemini AI is generating a tailored quiz..."
        
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
                        HapticHelper.error()
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
                        HapticHelper.error()
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
        showToast(message: "Saved to Core Data!", icon: "checkmark.circle.fill", tintColor: .systemGreen)
    }
    
    @objc func copyContentTapped() {
        guard let text = contentTextView?.text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        HapticHelper.success()
        showToast(message: "Copied to Clipboard!", icon: "doc.on.doc.fill", tintColor: .systemPurple)
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
}

