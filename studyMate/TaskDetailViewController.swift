//
//  TaskDetailViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Full-Screen Rich Notes Reader & Editor with Top Important Toggle, Bottom Format Bar, and Bottom Pagination.
//

import UIKit

class TaskDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField?
    @IBOutlet weak var notesTextView: UITextView?
    @IBOutlet weak var isDoneSwitch: UISwitch?
    
    // MARK: - Properties
    var topic: Topic!
    var taskToEdit: Task?
    var onSaveCompleted: (() -> Void)?
    
    // MARK: - State Properties
    private var isCompletedState: Bool = false
    private var pages: [String] = [""]
    private var currentPageIndex: Int = 0
    
    // Bottom Toolbars
    private let bottomContainerView = UIView()
    private let formatToolbar = UIToolbar()
    private let paginationContainer = UIView()
    
    private let prevPageButton = UIButton(type: .system)
    private let nextPageButton = UIButton(type: .system)
    private let pageIndicatorLabel = UILabel()
    private let addPageButton = UIButton(type: .system)
    
    private var completionBarButton: UIBarButtonItem!
    
    // MARK: - Delimiter for persistent multi-page notes
    private let pageDelimiter = "\n\n--- [STUDYMATE_PAGE_BREAK] ---\n\n"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBottomControls()
        setupFormattingAccessoryView()
        populateExistingData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Simple & Clean Title as requested: "Notes"
        title = "Notes"
        view.backgroundColor = .systemGroupedBackground
        
        // Navigation Bar Buttons
        let cancelBtn = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem = cancelBtn
        
        let saveBtn = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        
        // Top Header "Mark as Important / Completed" Toggle
        completionBarButton = UIBarButtonItem(
            image: UIImage(systemName: isCompletedState ? "checkmark.circle.fill" : "checkmark.circle"),
            style: .plain,
            target: self,
            action: #selector(toggleCompletionTapped)
        )
        completionBarButton.tintColor = isCompletedState ? .systemGreen : .systemGray3
        
        navigationItem.rightBarButtonItems = [saveBtn, completionBarButton]
        
        // Title Text Field (Compact)
        titleTextField?.placeholder = "Lesson / Note Title"
        titleTextField?.layer.cornerRadius = 10
        titleTextField?.backgroundColor = .secondarySystemGroupedBackground
        titleTextField?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        // Notes TextView Styling (Maximized Study Notebook)
        notesTextView?.layer.cornerRadius = 14
        notesTextView?.layer.borderWidth = 0.5
        notesTextView?.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
        notesTextView?.backgroundColor = .secondarySystemGroupedBackground
        notesTextView?.font = .systemFont(ofSize: 16, weight: .regular)
        notesTextView?.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
    }
    
    // MARK: - Bottom Controls: Format Bar above Pagination Bar
    private func setupBottomControls() {
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.backgroundColor = .clear
        view.addSubview(bottomContainerView)
        
        // 1. Format Bar (Bold, Italic, Highlight, Size, Dismiss)
        formatToolbar.translatesAutoresizingMaskIntoConstraints = false
        formatToolbar.barStyle = .default
        formatToolbar.isTranslucent = true
        formatToolbar.tintColor = .systemBlue
        formatToolbar.layer.cornerRadius = 10
        formatToolbar.clipsToBounds = true
        
        let boldBtn = UIBarButtonItem(title: "𝐁", style: .plain, target: self, action: #selector(formatBold))
        let italicBtn = UIBarButtonItem(title: "𝐼", style: .plain, target: self, action: #selector(formatItalic))
        let highlightBtn = UIBarButtonItem(title: "🖍️", style: .plain, target: self, action: #selector(formatHighlight))
        let sizeBtn = UIBarButtonItem(title: "Tᴛ", style: .plain, target: self, action: #selector(formatSizeHeading))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .plain, target: self, action: #selector(dismissKeyboard))
        
        formatToolbar.items = [
            boldBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            italicBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            highlightBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            sizeBtn,
            flexSpace,
            doneBtn
        ]
        
        // 2. Pagination Bar (at the very bottom)
        paginationContainer.translatesAutoresizingMaskIntoConstraints = false
        paginationContainer.applyCardStyle(cornerRadius: 10)
        paginationContainer.backgroundColor = .secondarySystemGroupedBackground
        
        prevPageButton.setTitle("◀ Prev", for: .normal)
        prevPageButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        prevPageButton.addTarget(self, action: #selector(prevPageTapped), for: .touchUpInside)
        
        nextPageButton.setTitle("Next ▶", for: .normal)
        nextPageButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        nextPageButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)
        
        pageIndicatorLabel.text = "📄 Page 1 of 1"
        pageIndicatorLabel.font = .systemFont(ofSize: 13, weight: .bold)
        pageIndicatorLabel.textColor = .systemPurple
        pageIndicatorLabel.textAlignment = .center
        
        addPageButton.setTitle("➕ Page", for: .normal)
        addPageButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        addPageButton.addTarget(self, action: #selector(addPageTapped), for: .touchUpInside)
        
        let pagStack = UIStackView(arrangedSubviews: [prevPageButton, pageIndicatorLabel, nextPageButton, addPageButton])
        pagStack.axis = .horizontal
        pagStack.distribution = .equalSpacing
        pagStack.alignment = .center
        pagStack.translatesAutoresizingMaskIntoConstraints = false
        paginationContainer.addSubview(pagStack)
        
        bottomContainerView.addSubview(formatToolbar)
        bottomContainerView.addSubview(paginationContainer)
        
        guard let notesView = notesTextView else { return }
        
        NSLayoutConstraint.activate([
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6),
            
            // Format Bar (Top of bottom container)
            formatToolbar.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            formatToolbar.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            formatToolbar.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            formatToolbar.heightAnchor.constraint(equalToConstant: 40),
            
            // Pagination Bar (Directly below Format Bar)
            paginationContainer.topAnchor.constraint(equalTo: formatToolbar.bottomAnchor, constant: 6),
            paginationContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            paginationContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            paginationContainer.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor),
            paginationContainer.heightAnchor.constraint(equalToConstant: 38),
            
            pagStack.leadingAnchor.constraint(equalTo: paginationContainer.leadingAnchor, constant: 12),
            pagStack.trailingAnchor.constraint(equalTo: paginationContainer.trailingAnchor, constant: -12),
            pagStack.topAnchor.constraint(equalTo: paginationContainer.topAnchor),
            pagStack.bottomAnchor.constraint(equalTo: paginationContainer.bottomAnchor),
            
            // Ensure notes view does not overlap bottom container
            notesView.bottomAnchor.constraint(lessThanOrEqualTo: bottomContainerView.topAnchor, constant: -8)
        ])
    }
    
    // MARK: - Keyboard Accessory Formatting View
    private func setupFormattingAccessoryView() {
        guard let textView = notesTextView else { return }
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .systemBlue
        
        let boldBtn = UIBarButtonItem(title: "𝐁", style: .plain, target: self, action: #selector(formatBold))
        let italicBtn = UIBarButtonItem(title: "𝐼", style: .plain, target: self, action: #selector(formatItalic))
        let highlightBtn = UIBarButtonItem(title: "🖍️ Highlight", style: .plain, target: self, action: #selector(formatHighlight))
        let sizeBtn = UIBarButtonItem(title: "Tᴛ Size", style: .plain, target: self, action: #selector(formatSizeHeading))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.items = [
            boldBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            italicBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            highlightBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            sizeBtn,
            flexSpace,
            doneBtn
        ]
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
    }
    
    // MARK: - Data Management & Pagination Logic
    private func populateExistingData() {
        if let task = taskToEdit {
            titleTextField?.text = task.title
            isCompletedState = task.isDone
            updateCompletionButtonAppearance()
            
            if let rawNotes = task.notes, !rawNotes.isEmpty {
                if rawNotes.contains(pageDelimiter) {
                    pages = rawNotes.components(separatedBy: pageDelimiter)
                } else {
                    pages = [rawNotes]
                }
            } else {
                pages = ["## Key Summary\n• \n\n💡 Highlight:\n\n📌 Notes:\n"]
            }
        } else {
            isCompletedState = false
            updateCompletionButtonAppearance()
            pages = ["## Key Summary\n• \n\n💡 Highlight:\n\n📌 Notes:\n"]
        }
        
        currentPageIndex = 0
        loadCurrentPageText()
        updatePaginationButtons()
    }
    
    private func saveCurrentPageText() {
        if currentPageIndex < pages.count {
            pages[currentPageIndex] = notesTextView?.text ?? ""
        }
    }
    
    private func loadCurrentPageText() {
        if currentPageIndex < pages.count {
            notesTextView?.text = pages[currentPageIndex]
        }
    }
    
    private func updatePaginationButtons() {
        pageIndicatorLabel.text = "📄 Page \(currentPageIndex + 1) of \(pages.count)"
        prevPageButton.isEnabled = currentPageIndex > 0
        nextPageButton.isEnabled = currentPageIndex < (pages.count - 1)
        
        prevPageButton.alpha = prevPageButton.isEnabled ? 1.0 : 0.4
        nextPageButton.alpha = nextPageButton.isEnabled ? 1.0 : 0.4
    }
    
    // MARK: - Pagination Actions
    @objc private func prevPageTapped() {
        guard currentPageIndex > 0 else { return }
        HapticHelper.lightImpact()
        saveCurrentPageText()
        currentPageIndex -= 1
        loadCurrentPageText()
        updatePaginationButtons()
    }
    
    @objc private func nextPageTapped() {
        guard currentPageIndex < pages.count - 1 else { return }
        HapticHelper.lightImpact()
        saveCurrentPageText()
        currentPageIndex += 1
        loadCurrentPageText()
        updatePaginationButtons()
    }
    
    @objc private func addPageTapped() {
        HapticHelper.success()
        saveCurrentPageText()
        pages.append("## Page \(pages.count + 1)\n• ")
        currentPageIndex = pages.count - 1
        loadCurrentPageText()
        updatePaginationButtons()
        showToast(message: "📄 Page \(pages.count) Added!")
    }
    
    // MARK: - Toggle Completed / Important Action (Top Header)
    @objc private func toggleCompletionTapped() {
        HapticHelper.success()
        isCompletedState.toggle()
        updateCompletionButtonAppearance()
        showToast(message: isCompletedState ? "✅ Marked as Completed!" : "⚪ Marked as Pending")
    }
    
    private func updateCompletionButtonAppearance() {
        let imageName = isCompletedState ? "checkmark.circle.fill" : "checkmark.circle"
        completionBarButton.image = UIImage(systemName: imageName)
        completionBarButton.tintColor = isCompletedState ? .systemGreen : .systemGray3
    }
    
    // MARK: - Essential Formatting Actions (Bold, Italic, Highlight, Size)
    
    @objc private func formatBold() {
        wrapSelectedText(prefix: "**", suffix: "**", placeholder: "bold text")
    }
    
    @objc private func formatItalic() {
        wrapSelectedText(prefix: "*", suffix: "*", placeholder: "italic text")
    }
    
    @objc private func formatHighlight() {
        wrapSelectedText(prefix: "== ", suffix: " ==", placeholder: "highlighted point")
    }
    
    @objc private func formatSizeHeading() {
        insertTextAtCursor(text: "\n## Large Heading: ")
    }
    
    @objc private func dismissKeyboard() {
        HapticHelper.lightImpact()
        notesTextView?.resignFirstResponder()
        titleTextField?.resignFirstResponder()
    }
    
    private func wrapSelectedText(prefix: String, suffix: String, placeholder: String) {
        guard let textView = notesTextView else { return }
        HapticHelper.lightImpact()
        
        let selectedRange = textView.selectedRange
        let text = textView.text as NSString? ?? ""
        
        if selectedRange.length > 0 {
            let selectedText = text.substring(with: selectedRange)
            let replacement = "\(prefix)\(selectedText)\(suffix)"
            textView.textStorage.replaceCharacters(in: selectedRange, with: replacement)
            textView.selectedRange = NSRange(location: selectedRange.location + prefix.count, length: selectedRange.length)
        } else {
            let replacement = "\(prefix)\(placeholder)\(suffix)"
            textView.insertText(replacement)
            textView.selectedRange = NSRange(location: selectedRange.location + prefix.count, length: placeholder.count)
        }
    }
    
    private func insertTextAtCursor(text: String) {
        guard let textView = notesTextView else { return }
        HapticHelper.lightImpact()
        textView.insertText(text)
    }
    
    // MARK: - Save & Dismiss
    @IBAction @objc func saveTapped(_ sender: Any) {
        guard let title = titleTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for this note.")
            return
        }
        
        saveCurrentPageText()
        let combinedNotes = pages.joined(separator: pageDelimiter).trimmingCharacters(in: .whitespacesAndNewlines)
        
        HapticHelper.success()
        if let existingTask = taskToEdit {
            CoreDataManager.shared.updateTask(existingTask, title: title, notes: combinedNotes, isDone: isCompletedState)
        } else {
            CoreDataManager.shared.createTask(title: title, notes: combinedNotes, isDone: isCompletedState, topic: self.topic)
        }
        
        onSaveCompleted?()
        dismiss(animated: true)
    }
    
    @IBAction @objc func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
