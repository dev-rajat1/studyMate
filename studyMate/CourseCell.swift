//
//  CourseCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Custom UITableViewCell for displaying a Course with refined typography, height, and spacing.
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
        
        cardContainerView?.applyCardStyle(cornerRadius: 18)
        colorTagView?.layer.cornerRadius = 3
        colorTagView?.layer.masksToBounds = true
        
        progressBar?.layer.cornerRadius = 3
        progressBar?.clipsToBounds = true
        
        nameLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        topicCountLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        topicCountLabel?.textColor = .secondaryLabel
        progressLabel?.font = .systemFont(ofSize: 12, weight: .bold)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            cardContainerView?.bounceTouchDown()
        } else {
            cardContainerView?.bounceTouchUp()
        }
    }
    
    /// Configures cell with Course data and calculated progress
    func configure(with course: Course) {
        let courseName = course.name ?? "Untitled Course"
        nameLabel?.text = courseName
        if nameLabel == nil {
            textLabel?.text = courseName
            textLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        }
        
        let modulesCount = (course.topics as? Set<Topic>)?.count ?? 0
        let (totalTasks, completedTasks, progress) = CoreDataManager.shared.getCourseProgress(course: course)
        
        let isFullyDone = (totalTasks > 0 && completedTasks == totalTasks)
        let subtitle = isFullyDone
            ? "✨ All \(totalTasks) lessons completed!"
            : "📚 \(modulesCount) \(modulesCount == 1 ? "Module" : "Modules")  •  \(completedTasks)/\(totalTasks) Lessons Done"
            
        topicCountLabel?.text = subtitle
        if topicCountLabel == nil {
            detailTextLabel?.text = subtitle
            detailTextLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            detailTextLabel?.textColor = .secondaryLabel
        }
        
        // Color Tag
        let courseColor = ColorHelper.color(named: course.colorTag)
        colorTagView?.backgroundColor = courseColor
        
        // Progress Bar
        progressBar?.progress = progress
        progressBar?.tintColor = courseColor
        progressBar?.trackTintColor = UIColor.separator.withAlphaComponent(0.15)
        
        if totalTasks > 0 {
            progressLabel?.text = "\(Int(progress * 100))%"
            progressLabel?.textColor = isFullyDone ? .systemGreen : courseColor
        } else {
            progressLabel?.text = "0%"
            progressLabel?.textColor = .tertiaryLabel
        }
    }
}

