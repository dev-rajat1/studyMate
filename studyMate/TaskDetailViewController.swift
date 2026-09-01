//
//  TaskDetailViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Modal screen for Creating or Editing a Task with rich Notes, Formatting Toolbar, and Symbols.
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFormattingToolbar()
        populateExistingData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let topicName = topic?.title ?? "Topic"
        title = taskToEdit == nil ? "New Lesson / Task" : "Edit Lesson Notes"
        view.backgroundColor = .systemGroupedBackground
        
        // Navigation Bar Buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        
        // Subtitle prompt in back button / title
        navigationController?.navigationBar.tintColor = .systemBlue
        
        // Notes TextView Styling (Notebook Feel)
        notesTextView?.layer.cornerRadius = 14
        notesTextView?.layer.borderWidth = 0.5
        notesTextView?.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
        notesTextView?.backgroundColor = .secondarySystemGroupedBackground
        notesTextView?.font = .systemFont(ofSize: 16, weight: .regular)
        notesTextView?.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        
        // Title text field styling
        titleTextField?.layer.cornerRadius = 10
        titleTextField?.backgroundColor = .secondarySystemGroupedBackground
    }
    
    // MARK: - Text Formatting Bar (Above Keyboard & Toolbar)
    private func setupFormattingToolbar() {
        guard let textView = notesTextView else { return }
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .systemBlue
        
        let boldBtn = UIBarButtonItem(title: "𝐁", style: .plain, target: self, action: #selector(formatBold))
        let italicBtn = UIBarButtonItem(title: "𝐼", style: .plain, target: self, action: #selector(formatItalic))
        let headingBtn = UIBarButtonItem(title: "H2", style: .plain, target: self, action: #selector(formatHeading))
        let bulletBtn = UIBarButtonItem(title: "• List", style: .plain, target: self, action: #selector(formatBullet))
        let checkBtn = UIBarButtonItem(title: "☑ Task", style: .plain, target: self, action: #selector(formatChecklist))
        let tipBtn = UIBarButtonItem(title: "💡 Tip", style: .plain, target: self, action: #selector(formatTip))
        let pinBtn = UIBarButtonItem(title: "📌 Note", style: .plain, target: self, action: #selector(formatPin))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.items = [
            boldBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            italicBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            headingBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            bulletBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            checkBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            tipBtn,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            pinBtn,
            flexSpace,
            doneBtn
        ]
        toolbar.sizeToFit()
        
        textView.inputAccessoryView = toolbar
    }
    
    // MARK: - Formatting Actions
    
    @objc private func formatBold() {
        wrapSelectedText(prefix: "**", suffix: "**", placeholder: "bold text")
    }
    
    @objc private func formatItalic() {
        wrapSelectedText(prefix: "*", suffix: "*", placeholder: "italic text")
    }
    
    @objc private func formatHeading() {
        insertTextAtCursor(text: "\n## Key Topic: ")
    }
    
    @objc private func formatBullet() {
        insertTextAtCursor(text: "\n• ")
    }
    
    @objc private func formatChecklist() {
        insertTextAtCursor(text: "\n[ ] ")
    }
    
    @objc private func formatTip() {
        insertTextAtCursor(text: "\n💡 Pro Tip: ")
    }
    
    @objc private func formatPin() {
        insertTextAtCursor(text: "\n📌 Important Note: ")
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
    
    // MARK: - Data Management
    private func populateExistingData() {
        if let task = taskToEdit {
            titleTextField?.text = task.title
            notesTextView?.text = task.notes
            isDoneSwitch?.isOn = task.isDone
        } else {
            // Default helpful study template
            notesTextView?.text = "## Summary\n• \n\n💡 Key Concept:\n\n📌 Formulas / Definitions:\n"
        }
    }
    
    // MARK: - Save Actions
    @IBAction @objc func saveTapped(_ sender: Any) {
        guard let title = titleTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for this lesson or study task.")
            return
        }
        
        let notes = notesTextView?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let isDone = isDoneSwitch?.isOn ?? false
        
        HapticHelper.success()
        if let existingTask = taskToEdit {
            CoreDataManager.shared.updateTask(existingTask, title: title, notes: notes, isDone: isDone)
        } else {
            CoreDataManager.shared.createTask(title: title, notes: notes, isDone: isDone, topic: self.topic)
        }
        
        onSaveCompleted?()
        dismiss(animated: true)
    }
    
    @IBAction @objc func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
