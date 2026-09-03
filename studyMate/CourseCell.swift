//
//  CourseCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Premium Course Card — Gradient accent bar, animated progress, modern typography.
//

import UIKit

class CourseCell: UITableViewCell {

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



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildProgrammaticLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    private func buildProgrammaticLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 16)
        contentView.addSubview(card)
        programmaticCard = card

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.cornerRadius = 4
        bar.layer.masksToBounds = true
        accentBar = bar

        let nameL = UILabel()
        nameL.font = .systemFont(ofSize: 19, weight: .bold)
        nameL.numberOfLines = 1
        progNameLabel = nameL

        let badge = UIView()
        badge.layer.cornerRadius = 8
        badge.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.12)
        moduleBadge = badge

        let badgeLabel = UILabel()
        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = DesignSystem.Colors.primary
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badge.addSubview(badgeLabel)
        moduleBadgeLabel = badgeLabel

        NSLayoutConstraint.activate([
            badgeLabel.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -8),
            badgeLabel.topAnchor.constraint(equalTo: badge.topAnchor, constant: 4),
            badgeLabel.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -4)
        ])

        let topRowStack = UIStackView.make(axis: .horizontal, spacing: 8, alignment: .center)
        topRowStack.addArrangedSubview(nameL)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        topRowStack.addArrangedSubview(spacer)
        topRowStack.addArrangedSubview(badge)

        let subL = UILabel()
        subL.font = .systemFont(ofSize: 14, weight: .medium)
        subL.textColor = .secondaryLabel
        progSubtitleLabel = subL

        let pBar = UIProgressView(progressViewStyle: .default)
        pBar.layer.cornerRadius = 4
        pBar.clipsToBounds = true
        pBar.trackTintColor = UIColor.separator.withAlphaComponent(0.12)
        progProgressBar = pBar
        
        let pLabel = UILabel()
        pLabel.font = .systemFont(ofSize: 13, weight: .black)
        progProgressLabel = pLabel

        let progressStack = UIStackView.make(axis: .horizontal, spacing: 12, alignment: .center)
        progressStack.addArrangedSubview(pBar)
        progressStack.addArrangedSubview(pLabel)
        pBar.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let contentStack = UIStackView.make(axis: .vertical, spacing: 4)
        contentStack.addArrangedSubview(topRowStack)
        contentStack.addArrangedSubview(subL)
        contentStack.setCustomSpacing(12, after: subL)
        contentStack.addArrangedSubview(progressStack)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)))
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit
        chevronIcon = chevron

        let mainStack = UIStackView.make(axis: .horizontal, spacing: 14, alignment: .center)
        mainStack.addArrangedSubview(contentStack)
        mainStack.addArrangedSubview(chevron)

        card.addSubviews(bar, mainStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            bar.topAnchor.constraint(equalTo: card.topAnchor),
            bar.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            bar.widthAnchor.constraint(equalToConstant: 6),

            mainStack.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            
            chevron.widthAnchor.constraint(equalToConstant: 12)
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
        let target = programmaticCard
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
