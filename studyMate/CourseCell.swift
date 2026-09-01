//
//  CourseCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Course with color badge & task progress.
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
        colorTagView?.layer.cornerRadius = 3
        colorTagView?.layer.masksToBounds = true
        progressBar?.layer.cornerRadius = 2
        progressBar?.clipsToBounds = true
    }
    
    /// Configures cell with Course data and calculated progress
    func configure(with course: Course) {
        if let nameLabel = nameLabel {
            nameLabel.text = course.name ?? "Untitled Course"
        } else {
            textLabel?.text = course.name ?? "Untitled Course"
        }
        
        let topicsCount = (course.topics as? Set<Topic>)?.count ?? 0
        let (totalTasks, completedTasks, progress) = CoreDataManager.shared.getCourseProgress(course: course)
        
        let subtitle = "\(topicsCount) \(topicsCount == 1 ? "Topic" : "Topics")  •  \(completedTasks)/\(totalTasks) Tasks Done"
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
        progressLabel?.text = totalTasks > 0 ? "\(Int(progress * 100))%" : "0%"
        progressLabel?.textColor = totalTasks > 0 && progress >= 1.0 ? .systemGreen : .secondaryLabel
    }
}
