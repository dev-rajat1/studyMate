//
//  TaskCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Task with a completion checkbox & notes.
//

import UIKit

class TaskCell: UITableViewCell {
    
    // MARK: - IBOutlets (Connect these in Storyboard)
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var notesLabel: UILabel?
    @IBOutlet weak var checkboxButton: UIButton?
    @IBOutlet weak var cardContainerView: UIView?
    
    /// Closure callback invoked when the checkbox button is tapped
    var onToggleCompletion: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cardContainerView?.applyCardStyle(cornerRadius: 12)
    }
    
    /// Configures the cell with Task details
    func configure(with task: Task) {
        let taskTitle = task.title ?? "Untitled Task"
        
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
            notesLabel?.text = notes
            notesLabel?.isHidden = false
            if notesLabel == nil {
                detailTextLabel?.text = notes
            }
        } else {
            notesLabel?.text = nil
            notesLabel?.isHidden = true
            if notesLabel == nil {
                detailTextLabel?.text = nil
            }
        }
        
        // Checkbox image (using modern SF Symbols)
        updateCheckboxAppearance(isDone: task.isDone)
    }
    
    private func updateCheckboxAppearance(isDone: Bool) {
        let imageName = isDone ? "checkmark.circle.fill" : "circle"
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        
        checkboxButton?.setImage(image, for: .normal)
        checkboxButton?.tintColor = isDone ? .systemGreen : .tertiaryLabel
        
        // Fallback for default accessory type if custom button is not connected
        if checkboxButton == nil {
            accessoryType = isDone ? .checkmark : .none
        }
    }
    
    // MARK: - IBActions (Connect this in Storyboard)
    @IBAction func checkboxTapped(_ sender: UIButton) {
        onToggleCompletion?()
    }
}
