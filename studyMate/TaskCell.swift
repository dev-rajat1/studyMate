//
//  TaskCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Task with a completion checkbox & notes preview.
//

import UIKit

class TaskCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var notesLabel: UILabel?
    @IBOutlet weak var checkboxButton: UIButton?
    @IBOutlet weak var cardContainerView: UIView?
    
    /// Closure callback invoked when the checkbox button is tapped
    var onToggleDone: (() -> Void)?
    var onToggleCompletion: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyles()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupStyles() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardContainerView?.applyCardStyle(cornerRadius: 16)
        
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        notesLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        notesLabel?.textColor = .secondaryLabel
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            cardContainerView?.bounceTouchDown()
        } else {
            cardContainerView?.bounceTouchUp()
        }
    }
    
    /// Configures the cell with Task details
    func configure(with task: Task) {
        let taskTitle = task.title ?? "Untitled Lesson / Task"
        
        // Strike-through text style if completed
        if task.isDone {
            let attributeString = NSMutableAttributedString(string: taskTitle)
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSMakeRange(0, attributeString.length))
            titleLabel?.attributedText = attributeString
            if titleLabel == nil {
                textLabel?.attributedText = attributeString
                textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            }
        } else {
            let attributeString = NSMutableAttributedString(string: taskTitle)
            attributeString.addAttribute(.foregroundColor, value: UIColor.label, range: NSMakeRange(0, attributeString.length))
            titleLabel?.attributedText = attributeString
            if titleLabel == nil {
                textLabel?.attributedText = attributeString
                textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            }
        }
        
        // Notes preview
        if let notes = task.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanedNotes = notes.replacingOccurrences(of: "\n", with: " • ")
            let pageCount = notes.components(separatedBy: "[STUDYMATE_PAGE_BREAK]").count
            let pageSuffix = pageCount > 1 ? "  (📄 \(pageCount) pages)" : ""
            
            notesLabel?.text = "📝 \(cleanedNotes)\(pageSuffix)"
            notesLabel?.textColor = .secondaryLabel
            notesLabel?.isHidden = false
            if notesLabel == nil {
                detailTextLabel?.text = "📝 \(cleanedNotes)\(pageSuffix)"
                detailTextLabel?.font = .systemFont(ofSize: 13, weight: .regular)
            }
        } else {
            notesLabel?.text = "📝 Tap to write study notes..."
            notesLabel?.textColor = .tertiaryLabel
            notesLabel?.isHidden = false
            if notesLabel == nil {
                detailTextLabel?.text = "📝 Tap to write study notes..."
                detailTextLabel?.font = .systemFont(ofSize: 13, weight: .regular)
            }
        }
        
        // Checkbox image
        updateCheckboxAppearance(isDone: task.isDone)
    }
    
    private func updateCheckboxAppearance(isDone: Bool) {
        let imageName = isDone ? "checkmark.circle.fill" : "circle"
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        
        checkboxButton?.setImage(image, for: .normal)
        checkboxButton?.tintColor = isDone ? .systemGreen : .systemGray3
        
        if checkboxButton == nil {
            accessoryType = isDone ? .checkmark : .none
        }
    }
    
    // MARK: - IBActions
    @IBAction func checkboxTapped(_ sender: UIButton) {
        HapticHelper.success()
        
        UIView.animate(withDuration: 0.12, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                sender.transform = .identity
            }, completion: nil)
        }
        
        onToggleDone?()
        onToggleCompletion?()
    }
}

