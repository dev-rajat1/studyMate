//
//  TaskDetailViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Clean, distraction-free Full-Screen Notes Reader & Editor with Formatting Quick Tools & Bottom Pagination Island.
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
    
    // Bottom Pagination Floating Island
    private let paginationContainer = UIView()
    private let prevPageButton = UIButton(type: .system)
    private let nextPageButton = UIButton(type: .system)
    private let pageIndicatorLabel = UILabel()
    private let addPageButton = UIButton(type: .system)
    private let deletePageButton = UIButton(type: .system)
    
    private var completionBarButton: UIBarButtonItem!
    
    // Quick Formatting Accessory Toolbar
    private let formattingToolbar = UIToolbar()
    
    // MARK: - Delimiter for multi-page notes
    private let pageDelimiter = "\n\n--- [STUDYMATE_PAGE_BREAK] ---\n\n"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardToolbar()
        setupPaginationBar()
        populateExistingData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = taskToEdit == nil ? "New Lesson" : "Lesson Notes"
        if let topic = topic {
            let courseName = topic.course?.name ?? "Course"
            let moduleName = topic.title ?? "Module"
            navigationItem.prompt = "📚 \(courseName) › 📖 \(moduleName)"
        }
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
        saveBtn.tintColor = .systemBlue
        
        // Top Header "Mark as Completed / Important" Toggle
        completionBarButton = UIBarButtonItem(
            image: UIImage(systemName: isCompletedState ? "checkmark.circle.fill" : "checkmark.circle"),
            style: .plain,
            target: self,
            action: #selector(toggleCompletionTapped)
        )
        completionBarButton.tintColor = isCompletedState ? .systemGreen : .systemGray3
        
        navigationItem.rightBarButtonItems = [saveBtn, completionBarButton]
        
        // Title Text Field (Compact & Modern)
        titleTextField?.placeholder = "Lesson / Note Title"
        titleTextField?.layer.cornerRadius = 12
        titleTextField?.backgroundColor = .secondarySystemGroupedBackground
        titleTextField?.font = .systemFont(ofSize: 17, weight: .bold)
        titleTextField?.layer.borderWidth = 0.5
        titleTextField?.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        
        // Notes TextView Styling (Maximized Clean Study Notebook)
        notesTextView?.layer.cornerRadius = 16
        notesTextView?.layer.borderWidth = 0.5
        notesTextView?.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        notesTextView?.backgroundColor = .secondarySystemGroupedBackground
        notesTextView?.font = .systemFont(ofSize: 16, weight: .regular)
        notesTextView?.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
    }
    
    // MARK: - Keyboard Formatting Toolbar
    private func setupKeyboardToolbar() {
        formattingToolbar.sizeToFit()
        formattingToolbar.barStyle = .default
        
        let bulletBtn = UIBarButtonItem(title: "• Bullet", style: .plain, target: self, action: #selector(insertBullet))
        let todoBtn = UIBarButtonItem(title: "☑ Todo", style: .plain, target: self, action: #selector(insertTodo))
        let numBtn = UIBarButtonItem(title: "1. Num", style: .plain, target: self, action: #selector(insertNumbered))
        let keyBtn = UIBarButtonItem(title: "⭐ Key", style: .plain, target: self, action: #selector(insertKeyPoint))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        formattingToolbar.items = [bulletBtn, todoBtn, numBtn, keyBtn, flex, doneBtn]
        notesTextView?.inputAccessoryView = formattingToolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func insertBullet() {
        insertTextAtCursor("\n• ")
    }
    
    @objc private func insertTodo() {
        insertTextAtCursor("\n[ ] ")
    }
    
    @objc private func insertNumbered() {
        insertTextAtCursor("\n1. ")
    }
    
    @objc private func insertKeyPoint() {
        insertTextAtCursor("\n💡 Key Concept: ")
    }
    
    private func insertTextAtCursor(_ text: String) {
        guard let textView = notesTextView else { return }
        HapticHelper.lightImpact()
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: text)
        } else {
            textView.text.append(text)
        }
    }
    
    // MARK: - Bottom Pagination Bar
    private func setupPaginationBar() {
        paginationContainer.translatesAutoresizingMaskIntoConstraints = false
        paginationContainer.applyCardStyle(cornerRadius: 14)
        paginationContainer.backgroundColor = .secondarySystemGroupedBackground
        
        prevPageButton.setTitle("◀ Prev", for: .normal)
        prevPageButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        prevPageButton.addTarget(self, action: #selector(prevPageTapped), for: .touchUpInside)
        
        nextPageButton.setTitle("Next ▶", for: .normal)
        nextPageButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        nextPageButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)
        
        pageIndicatorLabel.text = "📄 Page 1 of 1"
        pageIndicatorLabel.font = .systemFont(ofSize: 13, weight: .bold)
        pageIndicatorLabel.textColor = .systemPurple
        pageIndicatorLabel.textAlignment = .center
        
        addPageButton.setTitle("➕ Add Page", for: .normal)
        addPageButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        addPageButton.addTarget(self, action: #selector(addPageTapped), for: .touchUpInside)
        
        let pagStack = UIStackView(arrangedSubviews: [prevPageButton, pageIndicatorLabel, nextPageButton, addPageButton])
        pagStack.axis = .horizontal
        pagStack.distribution = .equalSpacing
        pagStack.alignment = .center
        pagStack.translatesAutoresizingMaskIntoConstraints = false
        paginationContainer.addSubview(pagStack)
        
        view.addSubview(paginationContainer)
        
        guard let notesView = notesTextView else { return }
        
        NSLayoutConstraint.activate([
            paginationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            paginationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            paginationContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            paginationContainer.heightAnchor.constraint(equalToConstant: 44),
            
            pagStack.leadingAnchor.constraint(equalTo: paginationContainer.leadingAnchor, constant: 14),
            pagStack.trailingAnchor.constraint(equalTo: paginationContainer.trailingAnchor, constant: -14),
            pagStack.topAnchor.constraint(equalTo: paginationContainer.topAnchor),
            pagStack.bottomAnchor.constraint(equalTo: paginationContainer.bottomAnchor),
            
            notesView.bottomAnchor.constraint(equalTo: paginationContainer.topAnchor, constant: -10)
        ])
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
                pages = ["• "]
            }
        } else {
            isCompletedState = false
            updateCompletionButtonAppearance()
            pages = ["• "]
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
        
        prevPageButton.alpha = prevPageButton.isEnabled ? 1.0 : 0.35
        nextPageButton.alpha = nextPageButton.isEnabled ? 1.0 : 0.35
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
        pages.append("• ")
        currentPageIndex = pages.count - 1
        loadCurrentPageText()
        updatePaginationButtons()
        showToast(message: "📄 Page \(pages.count) Added!", icon: "doc.badge.plus", tintColor: .systemPurple)
    }
    
    // MARK: - Toggle Completed / Important Action (Top Header)
    @objc private func toggleCompletionTapped() {
        HapticHelper.success()
        isCompletedState.toggle()
        updateCompletionButtonAppearance()
        showToast(
            message: isCompletedState ? "Marked as Completed!" : "Marked as Pending",
            icon: isCompletedState ? "checkmark.circle.fill" : "circle",
            tintColor: isCompletedState ? .systemGreen : .systemGray
        )
    }
    
    private func updateCompletionButtonAppearance() {
        let imageName = isCompletedState ? "checkmark.circle.fill" : "checkmark.circle"
        completionBarButton.image = UIImage(systemName: imageName)
        completionBarButton.tintColor = isCompletedState ? .systemGreen : .systemGray3
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

