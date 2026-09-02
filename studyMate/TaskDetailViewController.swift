//
//  TaskDetailViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Premium Notes Editor — Floating title field, notebook-style text view, glassmorphic pagination island.
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

    // State
    private var isCompletedState: Bool = false
    private var pages: [String] = [""]
    private var currentPageIndex: Int = 0

    // Programmatic UI
    private var progTitleField: UITextField?
    private var progNotesTextView: UITextView?

    // Pagination Island (Glassmorphic)
    private let paginationContainer = UIView()
    private let prevPageButton = UIButton(type: .system)
    private let nextPageButton = UIButton(type: .system)
    private let pageIndicatorLabel = UILabel()
    private let addPageButton = UIButton(type: .system)

    private var completionBarButton: UIBarButtonItem!

    // Formatting Toolbar
    private let formattingToolbar = UIToolbar()

    private let pageDelimiter = "\n\n--- [STUDYMATE_PAGE_BREAK] ---\n\n"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardToolbar()
        setupPaginationIsland()
        populateExistingData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = taskToEdit == nil ? "New Lesson" : "Lesson Notes"
        view.backgroundColor = .systemGroupedBackground

        let courseColor = ColorHelper.color(named: topic?.course?.colorTag)

        if let topic = topic {
            let courseName = topic.course?.name ?? "Course"
            let moduleName = topic.title ?? "Module"
            navigationItem.prompt = "📚 \(courseName) › 📖 \(moduleName)"
        }

        // Cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped)
        )

        // Save button (course-colored)
        let saveBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped(_:)))
        saveBtn.tintColor = courseColor

        // Completion toggle
        completionBarButton = UIBarButtonItem(
            image: UIImage(systemName: isCompletedState ? "checkmark.circle.fill" : "checkmark.circle"),
            style: .plain, target: self, action: #selector(toggleCompletionTapped)
        )
        completionBarButton.tintColor = isCompletedState ? DesignSystem.Colors.success : .systemGray3

        navigationItem.rightBarButtonItems = [saveBtn, completionBarButton]

        // ---- Style storyboard outlets if present ----
        if titleTextField != nil {
            titleTextField?.placeholder = "Lesson / Note Title"
            titleTextField?.font = .systemFont(ofSize: 18, weight: .bold)
            titleTextField?.layer.cornerRadius = 12
            titleTextField?.backgroundColor = .secondarySystemGroupedBackground
            titleTextField?.layer.borderWidth = 1.0
            titleTextField?.layer.borderColor = courseColor.withAlphaComponent(0.35).cgColor
            titleTextField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
            titleTextField?.leftViewMode = .always

            notesTextView?.layer.cornerRadius = 16
            notesTextView?.layer.borderWidth = 0.5
            notesTextView?.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
            notesTextView?.backgroundColor = .secondarySystemGroupedBackground
            notesTextView?.font = .systemFont(ofSize: 16, weight: .regular)
            notesTextView?.textContainerInset = UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14)
            return
        }

        // ---- Programmatic layout (no storyboard outlets) ----
        buildProgrammaticEditorUI(courseColor: courseColor)
    }

    private func buildProgrammaticEditorUI(courseColor: UIColor) {
        // Title Field
        let titleField = UITextField()
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.placeholder = "Lesson / Note Title"
        titleField.font = .systemFont(ofSize: 18, weight: .bold)
        titleField.backgroundColor = .secondarySystemGroupedBackground
        titleField.layer.cornerRadius = 14
        titleField.layer.borderWidth = 1.5
        titleField.layer.borderColor = courseColor.withAlphaComponent(0.40).cgColor
        titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        titleField.leftViewMode = .always
        titleField.returnKeyType = .next
        DesignSystem.Shadow.applyCard(to: titleField.layer)
        view.addSubview(titleField)
        progTitleField = titleField

        // Notes TextView (notebook style)
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont(name: "Menlo-Regular", size: 15) ?? .systemFont(ofSize: 15, weight: .regular)
        textView.backgroundColor = .secondarySystemGroupedBackground
        textView.layer.cornerRadius = 16
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        textView.textContainerInset = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
        textView.keyboardDismissMode = .interactive
        DesignSystem.Shadow.applyCard(to: textView.layer)
        view.addSubview(textView)
        progNotesTextView = textView

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 52),

            textView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // Keyboard observers for textview bottom constraint
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let kbFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let inset = view.bounds.height - kbFrame.origin.y + 10
        progNotesTextView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
        notesTextView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        progNotesTextView?.contentInset = .zero
        notesTextView?.contentInset = .zero
    }

    // MARK: - Keyboard Formatting Toolbar (Icon-Only)
    private func setupKeyboardToolbar() {
        formattingToolbar.sizeToFit()
        formattingToolbar.barTintColor = .secondarySystemGroupedBackground

        let bulletBtn = makeToolbarButton(icon: "list.bullet", action: #selector(insertBullet))
        let todoBtn = makeToolbarButton(icon: "checkmark.square", action: #selector(insertTodo))
        let numBtn = makeToolbarButton(icon: "list.number", action: #selector(insertNumbered))
        let keyBtn = makeToolbarButton(icon: "star.fill", action: #selector(insertKeyPoint))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        doneBtn.tintColor = DesignSystem.Colors.primary

        formattingToolbar.items = [bulletBtn, todoBtn, numBtn, keyBtn, flex, doneBtn]

        (notesTextView ?? progNotesTextView)?.inputAccessoryView = formattingToolbar
    }

    private func makeToolbarButton(icon: String, action: Selector) -> UIBarButtonItem {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let btn = UIBarButtonItem(image: UIImage(systemName: icon, withConfiguration: config), style: .plain, target: self, action: action)
        btn.tintColor = DesignSystem.Colors.primary
        return btn
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
    @objc private func insertBullet() { insertTextAtCursor("\n• ") }
    @objc private func insertTodo() { insertTextAtCursor("\n[ ] ") }
    @objc private func insertNumbered() { insertTextAtCursor("\n1. ") }
    @objc private func insertKeyPoint() { insertTextAtCursor("\n💡 Key Concept: ") }

    private func insertTextAtCursor(_ text: String) {
        let tv = notesTextView ?? progNotesTextView
        guard let textView = tv else { return }
        HapticHelper.lightImpact()
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: text)
        } else {
            textView.text.append(text)
        }
    }

    // MARK: - Glassmorphic Pagination Island
    private func setupPaginationIsland() {
        paginationContainer.translatesAutoresizingMaskIntoConstraints = false
        paginationContainer.applyGlassmorphicStyle(cornerRadius: 20)
        paginationContainer.backgroundColor = UIColor.secondarySystemGroupedBackground.withAlphaComponent(0.92)

        // Shadow
        DesignSystem.Shadow.applyCard(to: paginationContainer.layer)

        // Prev button
        let prevConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        prevPageButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: prevConfig), for: .normal)
        prevPageButton.tintColor = DesignSystem.Colors.primary
        prevPageButton.addTarget(self, action: #selector(prevPageTapped), for: .touchUpInside)

        // Page indicator
        pageIndicatorLabel.text = "Page 1"
        pageIndicatorLabel.font = .systemFont(ofSize: 14, weight: .bold)
        pageIndicatorLabel.textColor = DesignSystem.Colors.primary
        pageIndicatorLabel.textAlignment = .center

        // Next button
        let nextConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        nextPageButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: nextConfig), for: .normal)
        nextPageButton.tintColor = DesignSystem.Colors.primary
        nextPageButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)

        // Add page button
        let addConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        addPageButton.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: addConfig), for: .normal)
        addPageButton.tintColor = DesignSystem.Colors.secondary
        addPageButton.addTarget(self, action: #selector(addPageTapped), for: .touchUpInside)

        let pagStack = UIStackView(arrangedSubviews: [prevPageButton, pageIndicatorLabel, nextPageButton, addPageButton])
        pagStack.axis = .horizontal
        pagStack.distribution = .equalSpacing
        pagStack.alignment = .center
        pagStack.translatesAutoresizingMaskIntoConstraints = false
        paginationContainer.addSubview(pagStack)
        view.addSubview(paginationContainer)

        // Determine reference view for bottom constraint
        let activeTextView = notesTextView ?? progNotesTextView

        NSLayoutConstraint.activate([
            paginationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paginationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            paginationContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            paginationContainer.heightAnchor.constraint(equalToConstant: 52),

            pagStack.leadingAnchor.constraint(equalTo: paginationContainer.leadingAnchor, constant: 18),
            pagStack.trailingAnchor.constraint(equalTo: paginationContainer.trailingAnchor, constant: -18),
            pagStack.topAnchor.constraint(equalTo: paginationContainer.topAnchor),
            pagStack.bottomAnchor.constraint(equalTo: paginationContainer.bottomAnchor)
        ])

        if let tv = activeTextView {
            tv.bottomAnchor.constraint(equalTo: paginationContainer.topAnchor, constant: -12).isActive = true
        }
    }

    // MARK: - Data & Pagination
    private func populateExistingData() {
        if let task = taskToEdit {
            (titleTextField ?? progTitleField)?.text = task.title
            isCompletedState = task.isDone
            updateCompletionButtonAppearance()

            if let rawNotes = task.notes, !rawNotes.isEmpty {
                pages = rawNotes.contains(pageDelimiter)
                    ? rawNotes.components(separatedBy: pageDelimiter)
                    : [rawNotes]
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
            pages[currentPageIndex] = (notesTextView ?? progNotesTextView)?.text ?? ""
        }
    }

    private func loadCurrentPageText() {
        if currentPageIndex < pages.count {
            (notesTextView ?? progNotesTextView)?.text = pages[currentPageIndex]
        }
    }

    private func updatePaginationButtons() {
        pageIndicatorLabel.text = "Page \(currentPageIndex + 1) of \(pages.count)"
        prevPageButton.alpha = currentPageIndex > 0 ? 1.0 : 0.30
        nextPageButton.alpha = currentPageIndex < (pages.count - 1) ? 1.0 : 0.30
        prevPageButton.isEnabled = currentPageIndex > 0
        nextPageButton.isEnabled = currentPageIndex < (pages.count - 1)
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
        showToast(message: "Page \(pages.count) Added", icon: "doc.badge.plus", tintColor: DesignSystem.Colors.secondary)
    }

    // MARK: - Completion Toggle
    @objc private func toggleCompletionTapped() {
        HapticHelper.success()
        isCompletedState.toggle()
        updateCompletionButtonAppearance()
        showToast(
            message: isCompletedState ? "Marked as Completed!" : "Marked as Pending",
            icon: isCompletedState ? "checkmark.circle.fill" : "circle",
            tintColor: isCompletedState ? DesignSystem.Colors.success : .systemGray
        )
    }

    private func updateCompletionButtonAppearance() {
        completionBarButton.image = UIImage(systemName: isCompletedState ? "checkmark.circle.fill" : "checkmark.circle")
        completionBarButton.tintColor = isCompletedState ? DesignSystem.Colors.success : .systemGray3
    }

    // MARK: - Save & Dismiss
    @IBAction @objc func saveTapped(_ sender: Any) {
        let titleText = (titleTextField ?? progTitleField)?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let title = titleText, !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for this lesson.")
            (titleTextField ?? progTitleField)?.shake()
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
