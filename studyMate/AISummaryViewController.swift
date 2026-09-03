//
//  AISummaryViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Interactive ChatGPT-style AI Study Tutor with Context-Aware Q&A, Quick Action FABs, and Practice Quizzes with Hidden Answers.
//

import UIKit

// MARK: - Message Data Models
enum MessageSender {
    case user
    case ai
}

enum MessageKind {
    case text(String)
    case summary(String)
    case quiz([QuizQuestion])
}

struct ChatMessage {
    let id = UUID().uuidString
    let sender: MessageSender
    var kind: MessageKind
    let timestamp = Date()
}

class AISummaryViewController: UIViewController {

    // MARK: - Properties
    var topic: Topic!
    private var messages: [ChatMessage] = []
    private var isLoading = false
    
    // UI Elements
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let quickActionsContainer = UIView()
    private let summarizeButton = UIButton(type: .system)
    private let quizButton = UIButton(type: .system)
    
    // Bottom Input Bar
    private let inputContainer = UIView()
    private let inputTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var inputBottomConstraint: NSLayoutConstraint!
    
    // Loading Indicator Overlay
    private let typingIndicatorContainer = UIView()
    private let typingLabel = UILabel()
    private let typingSpinner = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupQuickActions()
        setupInputBar()
        setupKeyboardObservers()
        loadInitialGreeting()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "StudyMate AI Tutor"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        
        let courseName = topic?.course?.name ?? "Course"
        let moduleName = topic?.title ?? "Module"
        navigationItem.prompt = "📚 \(courseName) › 📖 \(moduleName)"
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UserBubbleCell.self, forCellReuseIdentifier: "UserBubbleCell")
        tableView.register(AITextBubbleCell.self, forCellReuseIdentifier: "AITextBubbleCell")
        tableView.register(AISummaryBubbleCell.self, forCellReuseIdentifier: "AISummaryBubbleCell")
        tableView.register(AIQuizBubbleCell.self, forCellReuseIdentifier: "AIQuizBubbleCell")
        
        view.addSubview(tableView)
    }
    
    // MARK: - Quick Action FABs (Standard UIKit UIButton compatible with all iOS versions)
    private func setupQuickActions() {
        quickActionsContainer.translatesAutoresizingMaskIntoConstraints = false
        quickActionsContainer.backgroundColor = .clear
        
        // Summarize Button
        summarizeButton.setTitle("⚡ Summarize Module", for: .normal)
        summarizeButton.setTitleColor(.systemPurple, for: .normal)
        summarizeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        summarizeButton.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.14)
        summarizeButton.layer.cornerRadius = 18
        summarizeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        summarizeButton.addTarget(self, action: #selector(summarizeTapped), for: .touchUpInside)
        
        // Quiz Button
        quizButton.setTitle("🎯 Practice Quiz", for: .normal)
        quizButton.setTitleColor(.systemBlue, for: .normal)
        quizButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        quizButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.14)
        quizButton.layer.cornerRadius = 18
        quizButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        quizButton.addTarget(self, action: #selector(quizTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [summarizeButton, quizButton])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        quickActionsContainer.addSubview(stack)
        view.addSubview(quickActionsContainer)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: quickActionsContainer.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: quickActionsContainer.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: quickActionsContainer.topAnchor),
            stack.bottomAnchor.constraint(equalTo: quickActionsContainer.bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    // MARK: - Input Bar Setup
    private func setupInputBar() {
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = .secondarySystemGroupedBackground
        inputContainer.layer.borderWidth = 0.5
        inputContainer.layer.borderColor = UIColor.separator.withAlphaComponent(0.25).cgColor
        
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "Ask anything about this module..."
        inputTextField.font = .systemFont(ofSize: 15, weight: .regular)
        inputTextField.backgroundColor = .tertiarySystemGroupedBackground
        inputTextField.layer.cornerRadius = 18
        inputTextField.layer.borderWidth = 0.5
        inputTextField.layer.borderColor = UIColor.separator.withAlphaComponent(0.15).cgColor
        inputTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        inputTextField.leftViewMode = .always
        inputTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        inputTextField.rightViewMode = .always
        inputTextField.returnKeyType = .send
        inputTextField.delegate = self
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        let sendImg = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold))
        sendButton.setImage(sendImg, for: .normal)
        sendButton.tintColor = DesignSystem.Colors.primary
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        inputContainer.addSubview(inputTextField)
        inputContainer.addSubview(sendButton)
        view.addSubview(inputContainer)
        
        // Typing indicator
        typingIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        typingIndicatorContainer.backgroundColor = .secondarySystemGroupedBackground
        typingIndicatorContainer.layer.cornerRadius = 14
        typingIndicatorContainer.applyCardStyle(cornerRadius: 14)
        typingIndicatorContainer.isHidden = true
        
        typingSpinner.translatesAutoresizingMaskIntoConstraints = false
        typingSpinner.tintColor = DesignSystem.Colors.primary

        typingLabel.translatesAutoresizingMaskIntoConstraints = false
        typingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        typingLabel.textColor = DesignSystem.Colors.primary
        typingLabel.text = "✨ StudyMate AI is thinking..."
        
        let typeStack = UIStackView(arrangedSubviews: [typingSpinner, typingLabel])
        typeStack.axis = .horizontal
        typeStack.spacing = 8
        typeStack.alignment = .center
        typeStack.translatesAutoresizingMaskIntoConstraints = false
        typingIndicatorContainer.addSubview(typeStack)
        view.addSubview(typingIndicatorContainer)
        
        inputBottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: quickActionsContainer.topAnchor, constant: -6),
            
            // Quick Actions Container
            quickActionsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            quickActionsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            quickActionsContainer.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -8),
            quickActionsContainer.heightAnchor.constraint(equalToConstant: 36),
            
            // Input Container (Background spans full width)
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBottomConstraint,
            inputContainer.heightAnchor.constraint(equalToConstant: 58),
            
            // Input controls stay within safe area margins so they aren't hidden by horizontal landscape notch
            inputTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 14),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -14),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            
            // Typing Indicator
            typingIndicatorContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            typingIndicatorContainer.bottomAnchor.constraint(equalTo: quickActionsContainer.topAnchor, constant: -8),
            typingIndicatorContainer.heightAnchor.constraint(equalToConstant: 34),
            
            typeStack.leadingAnchor.constraint(equalTo: typingIndicatorContainer.leadingAnchor, constant: 12),
            typeStack.trailingAnchor.constraint(equalTo: typingIndicatorContainer.trailingAnchor, constant: -12),
            typeStack.centerYAnchor.constraint(equalTo: typingIndicatorContainer.centerYAnchor)
        ])

    }
    
    // MARK: - Initial Greeting (No Auto-Trigger)
    private func loadInitialGreeting() {
        let topicTitle = topic?.title ?? "this module"
        let greetingText = """
        👋 **Hello! Welcome to your StudyMate AI Study Workspace.**
        
        I'm ready to help you master **"\(topicTitle)"**!
        
        • Ask me any doubt or explanation in the text field below.
        • Tap **⚡ Summarize Module** to generate a structured study review.
        • Tap **🎯 Practice Quiz** to test yourself with interactive questions.
        """
        messages.append(ChatMessage(sender: .ai, kind: .text(greetingText)))
        tableView.reloadData()
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let bottomInset = view.safeAreaInsets.bottom
        let offset = keyboardFrame.height - bottomInset
        inputBottomConstraint.constant = -offset
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        scrollToBottom(animated: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        inputBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc private func sendTapped() {
        guard let text = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        HapticHelper.lightImpact()
        inputTextField.text = ""
        
        // Add user message
        messages.append(ChatMessage(sender: .user, kind: .text(text)))
        tableView.reloadData()
        scrollToBottom(animated: true)
        
        // Call AI Context Q&A
        setLoadingState(true, message: "StudyMate AI is analyzing your lessons...")
        AIService.shared.askStudyTutor(for: self.topic, question: text) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setLoadingState(false)
                switch result {
                case .success(let answer):
                    HapticHelper.success()
                    self.messages.append(ChatMessage(sender: .ai, kind: .text(answer)))
                case .failure(let error):
                    HapticHelper.error()
                    self.messages.append(ChatMessage(sender: .ai, kind: .text("⚠️ Could not generate answer: \(error.localizedDescription)")))
                }
                self.tableView.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    @objc private func summarizeTapped() {
        guard !isLoading else { return }
        HapticHelper.mediumImpact()
        
        messages.append(ChatMessage(sender: .user, kind: .text("⚡ Please summarize all lessons for this module.")))
        tableView.reloadData()
        scrollToBottom(animated: true)
        
        setLoadingState(true, message: "Generating comprehensive summary...")
        AIService.shared.generateSummary(for: self.topic) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setLoadingState(false)
                switch result {
                case .success(let summary):
                    HapticHelper.success()
                    self.messages.append(ChatMessage(sender: .ai, kind: .summary(summary)))
                    CoreDataManager.shared.saveAISummary(content: summary, for: self.topic)
                case .failure(let error):
                    HapticHelper.error()
                    self.messages.append(ChatMessage(sender: .ai, kind: .text("⚠️ Could not generate summary: \(error.localizedDescription)")))
                }
                self.tableView.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    @objc private func quizTapped() {
        guard !isLoading else { return }
        HapticHelper.mediumImpact()
        
        messages.append(ChatMessage(sender: .user, kind: .text("🎯 Generate an interactive practice quiz based on my notes.")))
        tableView.reloadData()
        scrollToBottom(animated: true)
        
        setLoadingState(true, message: "Creating interactive practice quiz...")
        AIService.shared.generateStructuredQuiz(for: self.topic) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setLoadingState(false)
                switch result {
                case .success(let questions):
                    HapticHelper.success()
                    self.messages.append(ChatMessage(sender: .ai, kind: .quiz(questions)))
                case .failure(let error):
                    HapticHelper.error()
                    self.messages.append(ChatMessage(sender: .ai, kind: .text("⚠️ Could not generate quiz: \(error.localizedDescription)")))
                }
                self.tableView.reloadData()
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    private func setLoadingState(_ loading: Bool, message: String = "Thinking...") {
        isLoading = loading
        typingIndicatorContainer.isHidden = !loading
        if loading {
            typingLabel.text = message
            typingSpinner.startAnimating()
        } else {
            typingSpinner.stopAnimating()
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let lastIdx = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: lastIdx, at: .bottom, animated: animated)
    }
    
    @objc private func doneTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension AISummaryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }
}

// MARK: - UITableViewDataSource & Delegate
extension AISummaryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        
        switch msg.sender {
        case .user:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserBubbleCell", for: indexPath) as! UserBubbleCell
            if case let .text(txt) = msg.kind {
                cell.configure(text: txt)
            }
            return cell
            
        case .ai:
            switch msg.kind {
            case .text(let txt):
                let cell = tableView.dequeueReusableCell(withIdentifier: "AITextBubbleCell", for: indexPath) as! AITextBubbleCell
                cell.configure(text: txt)
                cell.onCopy = { [weak self] in
                    UIPasteboard.general.string = txt
                    HapticHelper.success()
                    self?.showToast(message: "Copied to clipboard!", icon: "doc.on.doc.fill", tintColor: .systemPurple)
                }
                return cell
                
            case .summary(let summaryTxt):
                let cell = tableView.dequeueReusableCell(withIdentifier: "AISummaryBubbleCell", for: indexPath) as! AISummaryBubbleCell
                cell.configure(summaryText: summaryTxt)
                cell.onCopy = { [weak self] in
                    UIPasteboard.general.string = summaryTxt
                    HapticHelper.success()
                    self?.showToast(message: "Summary copied!", icon: "doc.on.doc.fill", tintColor: .systemPurple)
                }
                cell.onSave = { [weak self] in
                    guard let self = self else { return }
                    CoreDataManager.shared.saveAISummary(content: summaryTxt, for: self.topic)
                    HapticHelper.success()
                    self.showToast(message: "Saved to Core Data!", icon: "checkmark.circle.fill", tintColor: .systemGreen)
                }
                return cell
                
            case .quiz(let questions):
                let cell = tableView.dequeueReusableCell(withIdentifier: "AIQuizBubbleCell", for: indexPath) as! AIQuizBubbleCell
                cell.configure(questions: questions)
                cell.onStateChanged = { [weak self] updatedQuestions in
                    self?.messages[indexPath.row].kind = .quiz(updatedQuestions)
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                return cell
            }
        }
    }
}

// MARK: - 💬 Custom Cell 1: User Bubble Cell
class UserBubbleCell: UITableViewCell {
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        bubbleView.clipsToBounds = false
        // Gradient background applied in configure
        DesignSystem.Shadow.applyGlow(to: bubbleView.layer, color: DesignSystem.Colors.primary)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
        messageLabel.numberOfLines = 0

        bubbleView.addSubview(messageLabel)
        contentView.addSubview(bubbleView)

        NSLayoutConstraint.activate([
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 64),

            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 11),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -11)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Apply gradient after layout so bounds are correct
        bubbleView.applyGradientBackground(
            colors: DesignSystem.Gradients.primary,
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 1, y: 1),
            cornerRadius: 18
        )
    }

    func configure(text: String) {
        messageLabel.text = text
    }
}

// MARK: - 🤖 Custom Cell 2: AI Text Response Bubble Cell
class AITextBubbleCell: UITableViewCell {
    private let cardView = UIView()
    private let headerLabel = UILabel()
    private let messageTextView = UITextView()
    private let copyButton = UIButton(type: .system)
    var onCopy: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.applyCardStyle(cornerRadius: 18)

        // AI badge pill (top left)
        let aiBadge = UIView()
        aiBadge.translatesAutoresizingMaskIntoConstraints = false
        aiBadge.backgroundColor = DesignSystem.Colors.secondary.withAlphaComponent(0.12)
        aiBadge.layer.cornerRadius = 8
        aiBadge.clipsToBounds = true

        let aiIcon = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)))
        aiIcon.translatesAutoresizingMaskIntoConstraints = false
        aiIcon.tintColor = DesignSystem.Colors.secondary
        aiBadge.addSubview(aiIcon)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "StudyMate AI"
        headerLabel.font = .systemFont(ofSize: 11, weight: .bold)
        headerLabel.textColor = DesignSystem.Colors.secondary
        aiBadge.addSubview(headerLabel)

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        let copyConf = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        copyButton.setImage(UIImage(systemName: "doc.on.doc", withConfiguration: copyConf), for: .normal)
        copyButton.tintColor = .tertiaryLabel
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.isScrollEnabled = false
        messageTextView.isEditable = false
        messageTextView.backgroundColor = .clear
        messageTextView.font = .systemFont(ofSize: 15, weight: .regular)
        messageTextView.textColor = .label
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0

        cardView.addSubview(aiBadge)
        cardView.addSubview(copyButton)
        cardView.addSubview(messageTextView)
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            aiIcon.leadingAnchor.constraint(equalTo: aiBadge.leadingAnchor, constant: 6),
            aiIcon.centerYAnchor.constraint(equalTo: aiBadge.centerYAnchor),
            aiIcon.widthAnchor.constraint(equalToConstant: 12),
            aiIcon.heightAnchor.constraint(equalToConstant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: aiIcon.trailingAnchor, constant: 5),
            headerLabel.trailingAnchor.constraint(equalTo: aiBadge.trailingAnchor, constant: -6),
            headerLabel.topAnchor.constraint(equalTo: aiBadge.topAnchor, constant: 4),
            headerLabel.bottomAnchor.constraint(equalTo: aiBadge.bottomAnchor, constant: -4),

            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -44),

            aiBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            aiBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),

            copyButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            copyButton.centerYAnchor.constraint(equalTo: aiBadge.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 24),
            copyButton.heightAnchor.constraint(equalToConstant: 24),

            messageTextView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            messageTextView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            messageTextView.topAnchor.constraint(equalTo: aiBadge.bottomAnchor, constant: 8),
            messageTextView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func copyTapped() {
        onCopy?()
    }

    func configure(text: String) {
        messageTextView.text = text
    }
}

// MARK: - 📄 Custom Cell 3: AI Summary Card Bubble Cell
class AISummaryBubbleCell: UITableViewCell {
    private let cardView = UIView()
    private let headerLabel = UILabel()
    private let summaryTextView = UITextView()
    private let copyBtn = UIButton(type: .system)
    private let saveBtn = UIButton(type: .system)
    var onCopy: (() -> Void)?
    var onSave: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.applyCardStyle(cornerRadius: 18)

        // Gradient header accent strip
        let headerStrip = UIView()
        headerStrip.translatesAutoresizingMaskIntoConstraints = false
        headerStrip.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 0)
        headerStrip.clipsToBounds = false
        cardView.addSubview(headerStrip)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "⚡ Module Study Summary"
        headerLabel.font = .systemFont(ofSize: 14, weight: .black)
        headerLabel.textColor = .white

        summaryTextView.translatesAutoresizingMaskIntoConstraints = false
        summaryTextView.isScrollEnabled = false
        summaryTextView.isEditable = false
        summaryTextView.backgroundColor = .clear
        summaryTextView.font = .systemFont(ofSize: 14, weight: .regular)
        summaryTextView.textColor = .label
        summaryTextView.textContainerInset = .zero
        summaryTextView.textContainer.lineFragmentPadding = 0

        // Copy pill
        copyBtn.setTitle("Copy", for: .normal)
        copyBtn.setTitleColor(DesignSystem.Colors.primary, for: .normal)
        copyBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        copyBtn.setImage(UIImage(systemName: "doc.on.doc", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)), for: .normal)
        copyBtn.tintColor = DesignSystem.Colors.primary
        copyBtn.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.10)
        copyBtn.layer.cornerRadius = 12
        copyBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        copyBtn.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        // Save pill
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.setTitleColor(DesignSystem.Colors.success, for: .normal)
        saveBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        saveBtn.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)), for: .normal)
        saveBtn.tintColor = DesignSystem.Colors.success
        saveBtn.backgroundColor = DesignSystem.Colors.success.withAlphaComponent(0.10)
        saveBtn.layer.cornerRadius = 12
        saveBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        saveBtn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let actionStack = UIStackView(arrangedSubviews: [copyBtn, saveBtn])
        actionStack.axis = .horizontal
        actionStack.spacing = 10
        actionStack.alignment = .center
        actionStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(headerLabel)
        cardView.addSubview(summaryTextView)
        cardView.addSubview(actionStack)
        contentView.addSubview(cardView)

        // Header strip constraint (added after all subviews)
        NSLayoutConstraint.activate([
            headerStrip.topAnchor.constraint(equalTo: cardView.topAnchor),
            headerStrip.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            headerStrip.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            headerStrip.heightAnchor.constraint(equalToConstant: 40),
            headerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            headerLabel.centerYAnchor.constraint(equalTo: headerStrip.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            summaryTextView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            summaryTextView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            summaryTextView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 52),

            actionStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            actionStack.topAnchor.constraint(equalTo: summaryTextView.bottomAnchor, constant: 12),
            actionStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func copyTapped() {
        onCopy?()
    }
    
    @objc private func saveTapped() {
        onSave?()
    }
    
    func configure(summaryText: String) {
        summaryTextView.text = summaryText
    }
}

// MARK: - 🎯 Custom Cell 4: AI Practice Quiz Bubble Cell (Hidden Answers)
class AIQuizBubbleCell: UITableViewCell {
    private let containerStack = UIStackView()
    private var questions: [QuizQuestion] = []
    var onStateChanged: (([QuizQuestion]) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 14
        containerStack.alignment = .fill
        containerStack.distribution = .fill
        
        contentView.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(questions: [QuizQuestion]) {
        self.questions = questions
        containerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, q) in questions.enumerated() {
            let card = buildSingleQuestionCard(question: q, index: index)
            containerStack.addArrangedSubview(card)
        }
    }
    
    private func buildSingleQuestionCard(question: QuizQuestion, index: Int) -> UIView {
        let card = UIView()
        card.applyCardStyle(cornerRadius: 16)
        card.backgroundColor = .secondarySystemGroupedBackground
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Q# Header pill
        let qHeader = UIView()
        qHeader.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.10)
        qHeader.layer.cornerRadius = 8
        qHeader.clipsToBounds = true

        let qHeaderLabel = UILabel()
        qHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        qHeaderLabel.text = "Q\(question.questionNumber)"
        qHeaderLabel.font = .systemFont(ofSize: 12, weight: .black)
        qHeaderLabel.textColor = DesignSystem.Colors.primary
        qHeader.addSubview(qHeaderLabel)
        NSLayoutConstraint.activate([
            qHeaderLabel.leadingAnchor.constraint(equalTo: qHeader.leadingAnchor, constant: 8),
            qHeaderLabel.trailingAnchor.constraint(equalTo: qHeader.trailingAnchor, constant: -8),
            qHeaderLabel.topAnchor.constraint(equalTo: qHeader.topAnchor, constant: 3),
            qHeaderLabel.bottomAnchor.constraint(equalTo: qHeader.bottomAnchor, constant: -3)
        ])

        let headerRow = UIStackView.make(axis: .horizontal, spacing: 0, alignment: .leading)
        headerRow.addArrangedSubview(qHeader)
        let headerSpacer = UIView()
        headerSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        headerRow.addArrangedSubview(headerSpacer)
        stack.addArrangedSubview(headerRow)


        // Question Text
        let qText = UILabel()
        qText.text = question.questionText
        qText.font = .systemFont(ofSize: 15, weight: .bold)
        qText.numberOfLines = 0
        qText.textColor = .label
        stack.addArrangedSubview(qText)

        // Options
        for opt in question.options {
            let optPill = UIView()
            optPill.backgroundColor = .tertiarySystemGroupedBackground
            optPill.layer.cornerRadius = 12
            optPill.layer.borderWidth = 1
            optPill.layer.borderColor = UIColor.separator.withAlphaComponent(0.15).cgColor

            let optLabel = UILabel()
            optLabel.text = opt
            optLabel.font = .systemFont(ofSize: 14, weight: .regular)
            optLabel.numberOfLines = 0
            optLabel.textColor = .label
            optLabel.translatesAutoresizingMaskIntoConstraints = false

            optPill.addSubview(optLabel)
            NSLayoutConstraint.activate([
                optLabel.leadingAnchor.constraint(equalTo: optPill.leadingAnchor, constant: 14),
                optLabel.trailingAnchor.constraint(equalTo: optPill.trailingAnchor, constant: -14),
                optLabel.topAnchor.constraint(equalTo: optPill.topAnchor, constant: 10),
                optLabel.bottomAnchor.constraint(equalTo: optPill.bottomAnchor, constant: -10)
            ])
            stack.addArrangedSubview(optPill)
        }

        // Reveal / Hide Answer Button
        let toggleButton = UIButton(type: .system)
        let revealColor = question.isAnswerRevealed ? DesignSystem.Colors.success : DesignSystem.Colors.primary
        let titleText = question.isAnswerRevealed ? "Hide Answer" : "Reveal Answer"
        toggleButton.setTitle(titleText, for: .normal)
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        toggleButton.layer.cornerRadius = 16
        toggleButton.clipsToBounds = true
        toggleButton.applyGradientBackground(
            colors: question.isAnswerRevealed ? DesignSystem.Gradients.success : DesignSystem.Gradients.primary,
            cornerRadius: 16
        )
        toggleButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        toggleButton.tag = index
        toggleButton.addTarget(self, action: #selector(toggleAnswerTapped(_:)), for: .touchUpInside)
        stack.addArrangedSubview(toggleButton)
        
        // Revealable Answer Section (premium reveal)
        if question.isAnswerRevealed {
            let answerContainer = UIView()
            answerContainer.backgroundColor = DesignSystem.Colors.success.withAlphaComponent(0.10)
            answerContainer.layer.cornerRadius = 14
            answerContainer.layer.borderWidth = 1
            answerContainer.layer.borderColor = DesignSystem.Colors.success.withAlphaComponent(0.28).cgColor

            let ansVStack = UIStackView()
            ansVStack.axis = .vertical
            ansVStack.spacing = 8
            ansVStack.translatesAutoresizingMaskIntoConstraints = false

            let ansTitle = UILabel()
            ansTitle.text = "✅  Correct Answer: Option \(question.correctAnswer)"
            ansTitle.font = .systemFont(ofSize: 14, weight: .black)
            ansTitle.textColor = DesignSystem.Colors.success

            let divider = UIView()
            divider.backgroundColor = DesignSystem.Colors.success.withAlphaComponent(0.18)
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

            let ansExp = UILabel()
            ansExp.text = "💡 \(question.explanation)"
            ansExp.font = .systemFont(ofSize: 13, weight: .regular)
            ansExp.numberOfLines = 0
            ansExp.textColor = .label

            ansVStack.addArrangedSubview(ansTitle)
            ansVStack.addArrangedSubview(divider)
            ansVStack.addArrangedSubview(ansExp)
            answerContainer.addSubview(ansVStack)

            NSLayoutConstraint.activate([
                ansVStack.leadingAnchor.constraint(equalTo: answerContainer.leadingAnchor, constant: 14),
                ansVStack.trailingAnchor.constraint(equalTo: answerContainer.trailingAnchor, constant: -14),
                ansVStack.topAnchor.constraint(equalTo: answerContainer.topAnchor, constant: 12),
                ansVStack.bottomAnchor.constraint(equalTo: answerContainer.bottomAnchor, constant: -12)
            ])

            // Spring animate reveal
            answerContainer.alpha = 0
            answerContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            UIView.animate(withDuration: 0.32, delay: 0.06, usingSpringWithDamping: 0.80, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                answerContainer.alpha = 1
                answerContainer.transform = .identity
            }

            stack.addArrangedSubview(answerContainer)
        }
        
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        
        return card
    }
    
    @objc private func toggleAnswerTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < questions.count else { return }
        HapticHelper.lightImpact()
        questions[index].isAnswerRevealed.toggle()
        configure(questions: questions)
        onStateChanged?(questions)
    }
}
