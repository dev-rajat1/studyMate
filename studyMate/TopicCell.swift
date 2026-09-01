//
//  TopicCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Topic with deadline and task count.
//

import UIKit

class TopicCell: UITableViewCell {
    
    // MARK: - IBOutlets (Connect these in Storyboard)
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var deadlineLabel: UILabel?
    @IBOutlet weak var taskCountLabel: UILabel?
    @IBOutlet weak var aiBadgeView: UIView?
    @IBOutlet weak var cardContainerView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        cardContainerView?.applyCardStyle(cornerRadius: 12)
        aiBadgeView?.layer.cornerRadius = 6
        aiBadgeView?.layer.masksToBounds = true
    }
    
    /// Configures the cell with Topic details
    func configure(with topic: Topic) {
        if let titleLabel = titleLabel {
            titleLabel.text = topic.title ?? "Untitled Topic"
        } else {
            textLabel?.text = topic.title ?? "Untitled Topic"
        }
        
        let (total, completed, _) = CoreDataManager.shared.getTopicProgress(topic: topic)
        let tasksText = "\(completed)/\(total) Completed"
        taskCountLabel?.text = tasksText
        
        if let deadline = topic.deadline {
            let deadlineText = "🗓 Due: \(deadline.deadlineRelativeString())"
            if let deadlineLabel = deadlineLabel {
                deadlineLabel.text = deadlineText
                deadlineLabel.textColor = deadline < Date() ? .systemRed : .secondaryLabel
            } else {
                detailTextLabel?.text = "\(deadlineText) • \(tasksText)"
            }
        } else {
            deadlineLabel?.text = "No deadline set"
            deadlineLabel?.textColor = .secondaryLabel
            if deadlineLabel == nil {
                detailTextLabel?.text = tasksText
            }
        }
        
        // Show AI badge if summary has already been generated
        aiBadgeView?.isHidden = (topic.aiSummary == nil)
    }
}
