//
//  TaskCell.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Premium Lesson Card — Animated spring checkbox, done-state opacity, notes preview, page count.
//

import UIKit

class TaskCell: UITableViewCell {

    // MARK: - Callbacks
    var onToggleDone: (() -> Void)?
    var onToggleCompletion: (() -> Void)?

    // MARK: - Programmatic UI Elements
    private var programmaticCard: UIView?
    private var progTitleLabel: UILabel?
    private var progNotesLabel: UILabel?
    private var progPageBadge: UIView?
    private var progPageBadgeLabel: UILabel?
    private var progDateBadge: UIView?
    private var progDateBadgeLabel: UILabel?
    private var doneOverlayView: UIView?



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

        let titleL = UILabel()
        titleL.font = .systemFont(ofSize: 17, weight: .semibold)
        titleL.textColor = .label
        titleL.numberOfLines = 2
        progTitleLabel = titleL

        let notesL = UILabel()
        notesL.font = .systemFont(ofSize: 14, weight: .regular)
        notesL.textColor = .secondaryLabel
        notesL.numberOfLines = 2
        progNotesLabel = notesL

        let pageBadge = UIView()
        pageBadge.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.10)
        pageBadge.layer.cornerRadius = 6
        pageBadge.isHidden = true
        progPageBadge = pageBadge

        let pageBadgeLabel = UILabel()
        pageBadgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        pageBadgeLabel.textColor = DesignSystem.Colors.primary
        pageBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        pageBadge.addSubview(pageBadgeLabel)
        progPageBadgeLabel = pageBadgeLabel

        NSLayoutConstraint.activate([
            pageBadgeLabel.leadingAnchor.constraint(equalTo: pageBadge.leadingAnchor, constant: 6),
            pageBadgeLabel.trailingAnchor.constraint(equalTo: pageBadge.trailingAnchor, constant: -6),
            pageBadgeLabel.topAnchor.constraint(equalTo: pageBadge.topAnchor, constant: 2),
            pageBadgeLabel.bottomAnchor.constraint(equalTo: pageBadge.bottomAnchor, constant: -2)
        ])
        
        let dateBadge = UIView()
        dateBadge.backgroundColor = DesignSystem.Colors.secondary.withAlphaComponent(0.10)
        dateBadge.layer.cornerRadius = 6
        dateBadge.isHidden = true
        progDateBadge = dateBadge

        let dateBadgeLabel = UILabel()
        dateBadgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        dateBadgeLabel.textColor = DesignSystem.Colors.secondary
        dateBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateBadge.addSubview(dateBadgeLabel)
        progDateBadgeLabel = dateBadgeLabel

        NSLayoutConstraint.activate([
            dateBadgeLabel.leadingAnchor.constraint(equalTo: dateBadge.leadingAnchor, constant: 6),
            dateBadgeLabel.trailingAnchor.constraint(equalTo: dateBadge.trailingAnchor, constant: -6),
            dateBadgeLabel.topAnchor.constraint(equalTo: dateBadge.topAnchor, constant: 2),
            dateBadgeLabel.bottomAnchor.constraint(equalTo: dateBadge.bottomAnchor, constant: -2)
        ])
        
        let notesStack = UIStackView.make(axis: .horizontal, spacing: 8, alignment: .center)
        notesStack.addArrangedSubview(notesL)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        notesStack.addArrangedSubview(spacer)
        notesStack.addArrangedSubview(dateBadge)
        notesStack.addArrangedSubview(pageBadge)

        let rightContentStack = UIStackView.make(axis: .vertical, spacing: 4)
        rightContentStack.addArrangedSubview(titleL)
        rightContentStack.addArrangedSubview(notesStack)

        let mainStack = UIStackView.make(axis: .horizontal, spacing: 14, alignment: .center)
        mainStack.addArrangedSubview(rightContentStack)

        card.addSubview(mainStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
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
    func configure(with task: Task) {
        let taskTitle = task.title ?? "Untitled Lesson"
        let isDone = task.isDone

        // Notes / page info
        let notesText: String
        var pageCount = 1
        if let notes = task.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let pages = notes.components(separatedBy: "\n\n--- [STUDYMATE_PAGE_BREAK] ---\n\n")
            pageCount = pages.count
            let preview = pages.first?.replacingOccurrences(of: "\n", with: " ") ?? ""
            let truncated = preview.count > 60 ? String(preview.prefix(60)) + "…" : preview
            notesText = truncated.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Tap to write notes…" : truncated
        } else {
            notesText = "Tap to write study notes…"
        }

        // ---- Programmatic path ----
        if isDone {
            let attr = NSMutableAttributedString(string: taskTitle)
            attr.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attr.length))
            attr.addAttribute(.foregroundColor, value: UIColor.tertiaryLabel, range: NSMakeRange(0, attr.length))
            progTitleLabel?.attributedText = attr
        } else {
            progTitleLabel?.attributedText = nil
            progTitleLabel?.text = taskTitle
            progTitleLabel?.textColor = .label
        }

        progNotesLabel?.text = notesText
        progNotesLabel?.textColor = isDone ? .quaternaryLabel : .secondaryLabel

        // Page badge
        if pageCount > 1 {
            progPageBadge?.isHidden = false
            progPageBadgeLabel?.text = "📄 \(pageCount)p"
        } else {
            progPageBadge?.isHidden = true
        }

        // Date badge
        if let deadline = task.deadline {
            progDateBadge?.isHidden = false
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            
            let calendar = Calendar.current
            if calendar.isDateInToday(deadline) {
                progDateBadgeLabel?.text = "🗓️ Today"
            } else if calendar.isDateInTomorrow(deadline) {
                progDateBadgeLabel?.text = "🗓️ Tomorrow"
            } else {
                progDateBadgeLabel?.text = "🗓️ \(formatter.string(from: deadline))"
            }
        } else {
            progDateBadge?.isHidden = true
        }

        // Card opacity for done
        programmaticCard?.alpha = isDone ? 0.60 : 1.0
    }
}
