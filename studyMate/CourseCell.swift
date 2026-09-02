//
//  CourseCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Premium Course Card — Gradient accent bar, animated progress, modern typography.
//

import UIKit

class CourseCell: UITableViewCell {

    // MARK: - IBOutlets (Storyboard Compatibility)
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var topicCountLabel: UILabel?
    @IBOutlet weak var colorTagView: UIView?
    @IBOutlet weak var progressBar: UIProgressView?
    @IBOutlet weak var progressLabel: UILabel?
    @IBOutlet weak var cardContainerView: UIView?

    // MARK: - Programmatic UI Elements
    private var programmaticCard: UIView?
    private var accentBar: UIView?
    private var progNameLabel: UILabel?
    private var progSubtitleLabel: UILabel?
    private var progProgressBar: UIProgressView?
    private var progProgressLabel: UILabel?
    private var moduleBadge: UIView?
    private var moduleBadgeLabel: UILabel?
    private var chevronIcon: UIImageView?
    private var gradientLayer: CAGradientLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyles()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildProgrammaticLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Storyboard Style Setup (IBOutlet path)
    private func setupStyles() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardContainerView?.applyCardStyle(cornerRadius: DesignSystem.Radius.card)
        colorTagView?.layer.cornerRadius = 4
        colorTagView?.layer.masksToBounds = true

        progressBar?.layer.cornerRadius = 4
        progressBar?.clipsToBounds = true
        progressBar?.trackTintColor = UIColor.separator.withAlphaComponent(0.12)

        nameLabel?.font = .systemFont(ofSize: 19, weight: .bold)
        topicCountLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        topicCountLabel?.textColor = .secondaryLabel
        progressLabel?.font = .systemFont(ofSize: 13, weight: .bold)
    }

    // MARK: - Programmatic Full Layout (No IBOutlets)
    private func buildProgrammaticLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Main card
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: DesignSystem.Radius.card)
        contentView.addSubview(card)
        programmaticCard = card

        // Left gradient accent bar
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 4
        bar.layer.masksToBounds = true
        card.addSubview(bar)
        accentBar = bar

        // Module count badge (top right)
        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.layer.cornerRadius = DesignSystem.Radius.chip
        badge.layer.masksToBounds = true
        badge.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.12)
        card.addSubview(badge)
        moduleBadge = badge

        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = DesignSystem.Colors.primary
        badge.addSubview(badgeLabel)
        moduleBadgeLabel = badgeLabel

        // Course Name
        let nameL = UILabel()
        nameL.translatesAutoresizingMaskIntoConstraints = false
        nameL.font = .systemFont(ofSize: 19, weight: .bold)
        nameL.textColor = .label
        nameL.numberOfLines = 1
        card.addSubview(nameL)
        progNameLabel = nameL

        // Subtitle
        let subL = UILabel()
        subL.translatesAutoresizingMaskIntoConstraints = false
        subL.font = .systemFont(ofSize: 13, weight: .medium)
        subL.textColor = .secondaryLabel
        subL.numberOfLines = 1
        card.addSubview(subL)
        progSubtitleLabel = subL

        // Progress bar (taller, rounded)
        let pBar = UIProgressView(progressViewStyle: .default)
        pBar.translatesAutoresizingMaskIntoConstraints = false
        pBar.layer.cornerRadius = 4
        pBar.clipsToBounds = true
        pBar.trackTintColor = UIColor.separator.withAlphaComponent(0.12)
        card.addSubview(pBar)
        progProgressBar = pBar

        // Progress % label
        let pLabel = UILabel()
        pLabel.translatesAutoresizingMaskIntoConstraints = false
        pLabel.font = .systemFont(ofSize: 13, weight: .black)
        card.addSubview(pLabel)
        progProgressLabel = pLabel

        // Chevron
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit
        card.addSubview(chevron)
        chevronIcon = chevron

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            // Accent bar
            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            bar.topAnchor.constraint(equalTo: card.topAnchor),
            bar.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            bar.widthAnchor.constraint(equalToConstant: 6),

            // Module badge (top right)
            badge.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            badge.centerYAnchor.constraint(equalTo: nameL.centerYAnchor),

            badgeLabel.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -8),
            badgeLabel.topAnchor.constraint(equalTo: badge.topAnchor, constant: 4),
            badgeLabel.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -4),

            // Name label
            nameL.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 14),
            nameL.trailingAnchor.constraint(equalTo: badge.leadingAnchor, constant: -8),
            nameL.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            // Subtitle
            subL.leadingAnchor.constraint(equalTo: nameL.leadingAnchor),
            subL.trailingAnchor.constraint(equalTo: nameL.trailingAnchor),
            subL.topAnchor.constraint(equalTo: nameL.bottomAnchor, constant: 4),

            // Progress bar
            pBar.leadingAnchor.constraint(equalTo: nameL.leadingAnchor),
            pBar.trailingAnchor.constraint(equalTo: pLabel.leadingAnchor, constant: -10),
            pBar.topAnchor.constraint(equalTo: subL.bottomAnchor, constant: 12),
            pBar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            pBar.heightAnchor.constraint(equalToConstant: 7),

            // Progress label
            pLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            pLabel.centerYAnchor.constraint(equalTo: pBar.centerYAnchor),

            // Chevron (centered vertically in card)
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            chevron.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            chevron.widthAnchor.constraint(equalToConstant: 14)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient accent bar frame
        if let bar = accentBar {
            gradientLayer?.frame = bar.bounds
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let target = programmaticCard ?? cardContainerView
        if highlighted {
            target?.bounceTouchDown()
        } else {
            target?.bounceTouchUp()
        }
    }

    // MARK: - Configure
    func configure(with course: Course) {
        let courseName = course.name ?? "Untitled Course"
        let courseColor = ColorHelper.color(named: course.colorTag)
        let gradientCols = ColorHelper.gradientColors(named: course.colorTag)

        let modulesCount = (course.topics as? Set<Topic>)?.count ?? 0
        let (totalTasks, completedTasks, progress) = CoreDataManager.shared.getCourseProgress(course: course)
        let isFullyDone = (totalTasks > 0 && completedTasks == totalTasks)

        // ---- IBOutlet path ----
        if nameLabel != nil {
            nameLabel?.text = courseName
            let subtitle = isFullyDone
                ? "✨ All \(totalTasks) lessons mastered!"
                : "📖 \(modulesCount) \(modulesCount == 1 ? "Module" : "Modules")  •  \(completedTasks)/\(totalTasks) Done"
            topicCountLabel?.text = subtitle

            colorTagView?.backgroundColor = courseColor
            // Apply gradient to colorTagView
            colorTagView?.layer.sublayers?.removeAll(where: { $0.name == "SMGradientLayer" })
            let gl = CAGradientLayer()
            gl.name = "SMGradientLayer"
            gl.colors = gradientCols
            gl.startPoint = CGPoint(x: 0, y: 0)
            gl.endPoint = CGPoint(x: 0, y: 1)
            gl.frame = colorTagView?.bounds ?? .zero
            colorTagView?.layer.insertSublayer(gl, at: 0)

            progressBar?.progress = progress
            progressBar?.tintColor = courseColor

            progressLabel?.text = "\(Int(progress * 100))%"
            progressLabel?.textColor = isFullyDone ? DesignSystem.Colors.success : courseColor
            return
        }

        // ---- Programmatic path ----
        progNameLabel?.text = courseName

        let subtitle = isFullyDone
            ? "✨ All \(totalTasks) lessons mastered!"
            : "📖 \(modulesCount) \(modulesCount == 1 ? "Module" : "Modules")  •  \(completedTasks)/\(totalTasks) Done"
        progSubtitleLabel?.text = subtitle

        // Gradient accent bar
        if let bar = accentBar {
            gradientLayer?.removeFromSuperlayer()
            let gl = CAGradientLayer()
            gl.colors = gradientCols
            gl.startPoint = CGPoint(x: 0, y: 0)
            gl.endPoint = CGPoint(x: 0, y: 1)
            gl.frame = bar.bounds.isEmpty ? CGRect(x: 0, y: 0, width: 6, height: 90) : bar.bounds
            gl.cornerRadius = 4
            bar.layer.sublayers?.removeAll(where: { $0.name == "SMGradientLayer" })
            gl.name = "SMGradientLayer"
            bar.layer.insertSublayer(gl, at: 0)
            gradientLayer = gl
        }

        // Module badge
        moduleBadgeLabel?.text = "\(modulesCount) Modules"
        moduleBadge?.backgroundColor = courseColor.withAlphaComponent(0.13)
        moduleBadgeLabel?.textColor = courseColor

        // Progress
        progProgressBar?.progress = progress
        progProgressBar?.tintColor = courseColor

        progProgressLabel?.text = "\(Int(progress * 100))%"
        progProgressLabel?.textColor = isFullyDone ? DesignSystem.Colors.success : courseColor
    }
}
