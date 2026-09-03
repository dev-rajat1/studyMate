//
//  TopicCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Premium Module Card — Color accent bullet, deadline chips, lesson progress, AI badge.
//

import UIKit

class TopicCell: UITableViewCell {

    // MARK: - Programmatic UI Elements
    private var programmaticCard: UIView?
    private var accentBullet: UIView?
    private var progTitleLabel: UILabel?
    private var deadlineChip: UIView?
    private var deadlineChipLabel: UILabel?
    private var lessonBadge: UIView?
    private var lessonBadgeLabel: UILabel?
    private var progAIBadge: UIView?
    private var progressFill: UIView?
    private var progressTrack: UIView?



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

        let bullet = UIView()
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.layer.cornerRadius = 5
        bullet.widthAnchor.constraint(equalToConstant: 10).isActive = true
        bullet.heightAnchor.constraint(equalToConstant: 10).isActive = true
        accentBullet = bullet

        let titleL = UILabel()
        titleL.font = .systemFont(ofSize: 18, weight: .bold)
        titleL.textColor = .label
        titleL.numberOfLines = 2
        progTitleLabel = titleL

        let aiBadge = UIView()
        aiBadge.backgroundColor = DesignSystem.Colors.secondary.withAlphaComponent(0.15)
        aiBadge.layer.cornerRadius = 8
        aiBadge.isHidden = true
        aiBadge.translatesAutoresizingMaskIntoConstraints = false
        aiBadge.widthAnchor.constraint(equalToConstant: 28).isActive = true
        aiBadge.heightAnchor.constraint(equalToConstant: 28).isActive = true
        progAIBadge = aiBadge

        let aiIcon = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)))
        aiIcon.tintColor = DesignSystem.Colors.secondary
        aiIcon.contentMode = .scaleAspectFit
        aiIcon.translatesAutoresizingMaskIntoConstraints = false
        aiBadge.addSubview(aiIcon)
        NSLayoutConstraint.activate([
            aiIcon.centerXAnchor.constraint(equalTo: aiBadge.centerXAnchor),
            aiIcon.centerYAnchor.constraint(equalTo: aiBadge.centerYAnchor)
        ])

        let titleStack = UIStackView.make(axis: .horizontal, spacing: 8, alignment: .top)
        titleStack.addArrangedSubview(titleL)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleStack.addArrangedSubview(spacer)
        titleStack.addArrangedSubview(aiBadge)

        let chip = UIView()
        chip.layer.cornerRadius = 7
        deadlineChip = chip

        let chipLabel = UILabel()
        chipLabel.font = .systemFont(ofSize: 11, weight: .bold)
        chipLabel.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(chipLabel)
        deadlineChipLabel = chipLabel

        NSLayoutConstraint.activate([
            chipLabel.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 7),
            chipLabel.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -7),
            chipLabel.topAnchor.constraint(equalTo: chip.topAnchor, constant: 3),
            chipLabel.bottomAnchor.constraint(equalTo: chip.bottomAnchor, constant: -3)
        ])

        let lessonB = UIView()
        lessonB.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.10)
        lessonB.layer.cornerRadius = 7
        lessonBadge = lessonB

        let lessonL = UILabel()
        lessonL.font = .systemFont(ofSize: 11, weight: .bold)
        lessonL.textColor = DesignSystem.Colors.primary
        lessonL.translatesAutoresizingMaskIntoConstraints = false
        lessonB.addSubview(lessonL)
        lessonBadgeLabel = lessonL

        NSLayoutConstraint.activate([
            lessonL.leadingAnchor.constraint(equalTo: lessonB.leadingAnchor, constant: 7),
            lessonL.trailingAnchor.constraint(equalTo: lessonB.trailingAnchor, constant: -7),
            lessonL.topAnchor.constraint(equalTo: lessonB.topAnchor, constant: 3),
            lessonL.bottomAnchor.constraint(equalTo: lessonB.bottomAnchor, constant: -3)
        ])

        let chipStack = UIStackView.make(axis: .horizontal, spacing: 6, alignment: .center)
        chipStack.addArrangedSubview(chip)
        chipStack.addArrangedSubview(lessonB)
        let chipSpacer = UIView()
        chipSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        chipStack.addArrangedSubview(chipSpacer)

        let track = UIView()
        track.backgroundColor = UIColor.separator.withAlphaComponent(0.12)
        track.layer.cornerRadius = 3
        track.translatesAutoresizingMaskIntoConstraints = false
        track.heightAnchor.constraint(equalToConstant: 6).isActive = true
        progressTrack = track

        let fill = UIView()
        fill.translatesAutoresizingMaskIntoConstraints = false
        fill.layer.cornerRadius = 3
        fill.backgroundColor = DesignSystem.Colors.primary
        track.addSubview(fill)
        progressFill = fill

        NSLayoutConstraint.activate([
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: 0)
        ])

        let rightContentStack = UIStackView.make(axis: .vertical, spacing: 10)
        rightContentStack.addArrangedSubview(titleStack)
        rightContentStack.addArrangedSubview(chipStack)
        rightContentStack.addArrangedSubview(track)

        let mainStack = UIStackView.make(axis: .horizontal, spacing: 10, alignment: .top)
        
        let bulletContainer = UIView()
        bulletContainer.translatesAutoresizingMaskIntoConstraints = false
        bulletContainer.widthAnchor.constraint(equalToConstant: 10).isActive = true
        bulletContainer.addSubview(bullet)
        NSLayoutConstraint.activate([
            bullet.centerXAnchor.constraint(equalTo: bulletContainer.centerXAnchor),
            bullet.topAnchor.constraint(equalTo: bulletContainer.topAnchor, constant: 5)
        ])

        mainStack.addArrangedSubview(bulletContainer)
        mainStack.addArrangedSubview(rightContentStack)

        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
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
    func configure(with topic: Topic) {
        let topicTitle = topic.title ?? "Untitled Module"
        let courseColor = ColorHelper.color(named: topic.course?.colorTag)
        let (total, completed, progress) = CoreDataManager.shared.getTopicProgress(topic: topic)
        let isDone = (total > 0 && completed == total)

        // ---- Programmatic path ----
        progTitleLabel?.text = topicTitle
        accentBullet?.backgroundColor = courseColor

        // Progress fill (update width constraint)
        if let track = progressTrack, let fill = progressFill {
            fill.constraints.forEach { if $0.firstAttribute == .width { fill.removeConstraint($0) } }
            track.constraints.forEach { if $0.firstAttribute == .width && $0.secondItem === fill { track.removeConstraint($0) } }

            let fillConstraint = fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: max(CGFloat(progress), 0.02))
            fillConstraint.isActive = true
            fill.backgroundColor = isDone ? DesignSystem.Colors.success : courseColor
        }

        // Deadline chip
        if let deadline = topic.deadline {
            let (chipColor, chipText) = deadlineChipStyle(for: deadline)
            deadlineChip?.backgroundColor = chipColor.withAlphaComponent(0.13)
            deadlineChipLabel?.textColor = chipColor
            deadlineChipLabel?.text = chipText
        } else {
            deadlineChip?.backgroundColor = UIColor.tertiaryLabel.withAlphaComponent(0.10)
            deadlineChipLabel?.textColor = .tertiaryLabel
            deadlineChipLabel?.text = "No deadline"
        }

        // Lesson badge
        let lessonText = isDone ? "✅ Done" : "\(completed)/\(total) Lessons"
        lessonBadgeLabel?.text = lessonText
        lessonBadge?.backgroundColor = (isDone ? DesignSystem.Colors.success : DesignSystem.Colors.primary).withAlphaComponent(0.12)
        lessonBadgeLabel?.textColor = isDone ? DesignSystem.Colors.success : DesignSystem.Colors.primary

        // AI badge
        progAIBadge?.isHidden = (topic.aiSummary == nil)
    }

    private func deadlineChipStyle(for deadline: Date) -> (UIColor, String) {
        if deadline < Date() && !Calendar.current.isDateInToday(deadline) {
            return (DesignSystem.Colors.coral, "⚠️ Overdue")
        } else if Calendar.current.isDateInToday(deadline) {
            return (DesignSystem.Colors.streak, "🔥 Due Today")
        } else if Calendar.current.isDateInTomorrow(deadline) {
            return (UIColor.systemOrange, "📅 Tomorrow")
        } else {
            return (DesignSystem.Colors.success, "🗓 \(deadline.formattedDate())")
        }
    }
}
