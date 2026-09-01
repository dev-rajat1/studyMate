//
//  CourseCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Course with color badge & module/lesson progress.
//

import UIKit

class CourseCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var topicCountLabel: UILabel?
    @IBOutlet weak var colorTagView: UIView?
    @IBOutlet weak var progressBar: UIProgressView?
    @IBOutlet weak var progressLabel: UILabel?
    @IBOutlet weak var cardContainerView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardContainerView?.applyCardStyle(cornerRadius: 14)
        colorTagView?.layer.cornerRadius = 2.5
        colorTagView?.layer.masksToBounds = true
        progressBar?.layer.cornerRadius = 3
        progressBar?.clipsToBounds = true
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardContainerView?.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.cardContainerView?.alpha = highlighted ? 0.9 : 1.0
        }
    }
    
    /// Configures cell with Course data and calculated progress
    func configure(with course: Course) {
        if let nameLabel = nameLabel {
            nameLabel.text = course.name ?? "Untitled Course"
        } else {
            textLabel?.text = course.name ?? "Untitled Course"
        }
        
        let modulesCount = (course.topics as? Set<Topic>)?.count ?? 0
        let (totalTasks, completedTasks, progress) = CoreDataManager.shared.getCourseProgress(course: course)
        
        let subtitle = "📚 \(modulesCount) \(modulesCount == 1 ? "Module" : "Modules")  •  \(completedTasks)/\(totalTasks) Lessons Done"
        if let topicCountLabel = topicCountLabel {
            topicCountLabel.text = subtitle
        } else {
            detailTextLabel?.text = subtitle
        }
        
        // Color Tag
        let courseColor = ColorHelper.color(named: course.colorTag)
        colorTagView?.backgroundColor = courseColor
        
        // Progress Bar
        progressBar?.progress = progress
        progressBar?.tintColor = courseColor
        
        if totalTasks > 0 {
            progressLabel?.text = "\(Int(progress * 100))%"
            progressLabel?.textColor = progress >= 1.0 ? .systemGreen : .secondaryLabel
        } else {
            progressLabel?.text = "0%"
            progressLabel?.textColor = .tertiaryLabel
        }
    }
}
