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

        // Main card
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: DesignSystem.Radius.card)
        contentView.addSubview(card)
        programmaticCard = card

        // Left accent bullet circle
        let bullet = UIView()
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.layer.cornerRadius = 5
        bullet.layer.masksToBounds = true
        card.addSubview(bullet)
        accentBullet = bullet

        // Module title
        let titleL = UILabel()
        titleL.translatesAutoresizingMaskIntoConstraints = false
        titleL.font = .systemFont(ofSize: 18, weight: .bold)
        titleL.textColor = .label
        titleL.numberOfLines = 2
        card.addSubview(titleL)
        progTitleLabel = titleL

        // AI Badge
        let aiBadge = UIView()
        aiBadge.translatesAutoresizingMaskIntoConstraints = false
        aiBadge.backgroundColor = DesignSystem.Colors.secondary.withAlphaComponent(0.15)
        aiBadge.layer.cornerRadius = 8
        aiBadge.layer.masksToBounds = true
        aiBadge.isHidden = true
        card.addSubview(aiBadge)
        progAIBadge = aiBadge

        let aiConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let aiIcon = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: aiConfig))
        aiIcon.translatesAutoresizingMaskIntoConstraints = false
        aiIcon.tintColor = DesignSystem.Colors.secondary
        aiIcon.contentMode = .scaleAspectFit
        aiBadge.addSubview(aiIcon)
        NSLayoutConstraint.activate([
            aiIcon.centerXAnchor.constraint(equalTo: aiBadge.centerXAnchor),
            aiIcon.centerYAnchor.constraint(equalTo: aiBadge.centerYAnchor),
            aiBadge.widthAnchor.constraint(equalToConstant: 28),
            aiBadge.heightAnchor.constraint(equalToConstant: 28)
        ])

        // Deadline chip
        let chip = UIView()
        chip.translatesAutoresizingMaskIntoConstraints = false
        chip.layer.cornerRadius = 7
        chip.layer.masksToBounds = true
        card.addSubview(chip)
        deadlineChip = chip

        let chipLabel = UILabel()
        chipLabel.translatesAutoresizingMaskIntoConstraints = false
        chipLabel.font = .systemFont(ofSize: 11, weight: .bold)
        chip.addSubview(chipLabel)
        deadlineChipLabel = chipLabel

        NSLayoutConstraint.activate([
            chipLabel.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 7),
            chipLabel.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -7),
            chipLabel.topAnchor.constraint(equalTo: chip.topAnchor, constant: 3),
            chipLabel.bottomAnchor.constraint(equalTo: chip.bottomAnchor, constant: -3)
        ])

        // Lesson badge
        let lessonB = UIView()
        lessonB.translatesAutoresizingMaskIntoConstraints = false
        lessonB.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.10)
        lessonB.layer.cornerRadius = 7
        lessonB.layer.masksToBounds = true
        card.addSubview(lessonB)
        lessonBadge = lessonB

        let lessonL = UILabel()
        lessonL.translatesAutoresizingMaskIntoConstraints = false
        lessonL.font = .systemFont(ofSize: 11, weight: .bold)
        lessonL.textColor = DesignSystem.Colors.primary
        lessonB.addSubview(lessonL)
        lessonBadgeLabel = lessonL

        NSLayoutConstraint.activate([
            lessonL.leadingAnchor.constraint(equalTo: lessonB.leadingAnchor, constant: 7),
            lessonL.trailingAnchor.constraint(equalTo: lessonB.trailingAnchor, constant: -7),
            lessonL.topAnchor.constraint(equalTo: lessonB.topAnchor, constant: 3),
            lessonL.bottomAnchor.constraint(equalTo: lessonB.bottomAnchor, constant: -3)
        ])

        // Progress track
        let track = UIView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.backgroundColor = UIColor.separator.withAlphaComponent(0.12)
        track.layer.cornerRadius = 3
        track.layer.masksToBounds = true
        card.addSubview(track)
        progressTrack = track

        // Progress fill
        let fill = UIView()
        fill.translatesAutoresizingMaskIntoConstraints = false
        fill.layer.cornerRadius = 3
        fill.layer.masksToBounds = true
        fill.backgroundColor = DesignSystem.Colors.primary
        track.addSubview(fill)
        progressFill = fill

        NSLayoutConstraint.activate([
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: 0) // Updated in configure
        ])

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Accent bullet
            bullet.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            bullet.centerYAnchor.constraint(equalTo: titleL.centerYAnchor),
            bullet.widthAnchor.constraint(equalToConstant: 10),
            bullet.heightAnchor.constraint(equalToConstant: 10),

            // Title
            titleL.leadingAnchor.constraint(equalTo: bullet.trailingAnchor, constant: 10),
            titleL.trailingAnchor.constraint(equalTo: aiBadge.leadingAnchor, constant: -8),
            titleL.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            // AI badge (top right)
            aiBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            aiBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),

            // Deadline chip
            chip.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
            chip.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 8),

            // Lesson badge
            lessonB.leadingAnchor.constraint(equalTo: chip.trailingAnchor, constant: 6),
            lessonB.centerYAnchor.constraint(equalTo: chip.centerYAnchor),

            // Progress track
            track.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            track.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            track.topAnchor.constraint(equalTo: chip.bottomAnchor, constant: 12),
            track.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            track.heightAnchor.constraint(equalToConstant: 6)
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
