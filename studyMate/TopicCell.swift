//
//  TopicCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Topic with deadline and task count.
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
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardContainerView?.applyCardStyle(cornerRadius: 14)
        aiBadgeView?.layer.cornerRadius = 6
        aiBadgeView?.layer.masksToBounds = true
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardContainerView?.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.cardContainerView?.alpha = highlighted ? 0.9 : 1.0
        }
    }
    
    /// Configures the cell with Topic details
    func configure(with topic: Topic) {
        if let titleLabel = titleLabel {
            titleLabel.text = topic.title ?? "Untitled Topic"
        } else {
            textLabel?.text = topic.title ?? "Untitled Topic"
        }
        
        let (total, completed, _) = CoreDataManager.shared.getTopicProgress(topic: topic)
        let tasksText = "📝 \(completed)/\(total) Lessons Done"
        taskCountLabel?.text = tasksText
        taskCountLabel?.textColor = (total > 0 && completed == total) ? .systemGreen : .systemBlue
        
        if let deadline = topic.deadline {
            let deadlineText = "🗓 \(deadline.deadlineRelativeString())"
            if let deadlineLabel = deadlineLabel {
                deadlineLabel.text = deadlineText
                if deadline < Date() && !Calendar.current.isDateInToday(deadline) {
                    deadlineLabel.textColor = .systemRed
                } else if Calendar.current.isDateInToday(deadline) {
                    deadlineLabel.textColor = .systemOrange
                } else {
                    deadlineLabel.textColor = .secondaryLabel
                }
            } else {
                detailTextLabel?.text = "\(deadlineText) • \(tasksText)"
            }
        } else {
            deadlineLabel?.text = "🗓 No deadline"
            deadlineLabel?.textColor = .tertiaryLabel
            if deadlineLabel == nil {
                detailTextLabel?.text = tasksText
            }
        }
        
        // Show AI badge if summary has already been generated
        aiBadgeView?.isHidden = (topic.aiSummary == nil)
    }
}
