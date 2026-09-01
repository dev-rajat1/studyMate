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
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardContainerView?.applyCardStyle(cornerRadius: 14)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardContainerView?.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.cardContainerView?.alpha = highlighted ? 0.9 : 1.0
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
            }
        } else {
            let attributeString = NSMutableAttributedString(string: taskTitle)
            attributeString.addAttribute(.foregroundColor, value: UIColor.label, range: NSMakeRange(0, attributeString.length))
            titleLabel?.attributedText = attributeString
            if titleLabel == nil {
                textLabel?.attributedText = attributeString
            }
        }
        
        // Notes preview
        if let notes = task.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let cleanedNotes = notes.replacingOccurrences(of: "\n", with: " • ")
            notesLabel?.text = "📝 \(cleanedNotes)"
            notesLabel?.isHidden = false
            if notesLabel == nil {
                detailTextLabel?.text = "📝 \(cleanedNotes)"
            }
        } else {
            notesLabel?.text = "📝 Tap to add study notes & summary..."
            notesLabel?.textColor = .tertiaryLabel
            notesLabel?.isHidden = false
            if notesLabel == nil {
                detailTextLabel?.text = nil
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
        HapticHelper.lightImpact()
        
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        
        onToggleDone?()
        onToggleCompletion?()
    }
}
