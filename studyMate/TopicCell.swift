//
//  TopicCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Topic with deadline, task count, and AI status.
//

import UIKit

class TopicCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var deadlineLabel: UILabel?
    @IBOutlet weak var taskCountLabel: UILabel?
    @IBOutlet weak var aiBadgeView: UIView?
    @IBOutlet weak var cardContainerView: UIView?
    
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
        aiBadgeView?.layer.cornerRadius = 8
        aiBadgeView?.layer.masksToBounds = true
        
        titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        deadlineLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        taskCountLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            cardContainerView?.bounceTouchDown()
        } else {
            cardContainerView?.bounceTouchUp()
        }
    }
    
    /// Configures the cell with Topic details
    func configure(with topic: Topic) {
        let topicTitle = topic.title ?? "Untitled Module"
        titleLabel?.text = topicTitle
        if titleLabel == nil {
            textLabel?.text = topicTitle
            textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        }
        
        let (total, completed, progress) = CoreDataManager.shared.getTopicProgress(topic: topic)
        let isDone = (total > 0 && completed == total)
        let tasksText = isDone ? "✅ \(completed)/\(total) Completed" : "📝 \(completed)/\(total) Lessons"
        
        taskCountLabel?.text = tasksText
        taskCountLabel?.textColor = isDone ? .systemGreen : .systemPurple
        
        if let deadline = topic.deadline {
            let deadlineText = "🗓 \(deadline.deadlineRelativeString())"
            deadlineLabel?.text = deadlineText
            
            if deadline < Date() && !Calendar.current.isDateInToday(deadline) {
                deadlineLabel?.textColor = .systemRed
            } else if Calendar.current.isDateInToday(deadline) {
                deadlineLabel?.textColor = .systemOrange
            } else {
                deadlineLabel?.textColor = .secondaryLabel
            }
            
            if deadlineLabel == nil {
                detailTextLabel?.text = "\(deadlineText)  •  \(tasksText)"
                detailTextLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            }
        } else {
            deadlineLabel?.text = "🗓 No target date"
            deadlineLabel?.textColor = .tertiaryLabel
            if deadlineLabel == nil {
                detailTextLabel?.text = tasksText
                detailTextLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            }
        }
        
        // Show AI badge if summary has already been generated
        aiBadgeView?.isHidden = (topic.aiSummary == nil)
    }
}

