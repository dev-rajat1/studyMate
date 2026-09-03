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
    private var progCheckbox: UIButton?
    private var progTitleLabel: UILabel?
    private var progNotesLabel: UILabel?
    private var progPageBadge: UIView?
    private var progPageBadgeLabel: UILabel?
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

        // Main card
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: DesignSystem.Radius.card)
        contentView.addSubview(card)
        programmaticCard = card

        // Checkbox button
        let checkbox = UIButton(type: .custom)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        card.addSubview(checkbox)
        progCheckbox = checkbox

        // Title label
        let titleL = UILabel()
        titleL.translatesAutoresizingMaskIntoConstraints = false
        titleL.font = .systemFont(ofSize: 17, weight: .semibold)
        titleL.textColor = .label
        titleL.numberOfLines = 2
        card.addSubview(titleL)
        progTitleLabel = titleL

        // Notes preview
        let notesL = UILabel()
        notesL.translatesAutoresizingMaskIntoConstraints = false
        notesL.font = .systemFont(ofSize: 14, weight: .regular)
        notesL.textColor = .secondaryLabel
        notesL.numberOfLines = 2
        card.addSubview(notesL)
        progNotesLabel = notesL

        // Page badge
        let pageBadge = UIView()
        pageBadge.translatesAutoresizingMaskIntoConstraints = false
        pageBadge.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.10)
        pageBadge.layer.cornerRadius = 6
        pageBadge.layer.masksToBounds = true
        pageBadge.isHidden = true
        card.addSubview(pageBadge)
        progPageBadge = pageBadge

        let pageBadgeLabel = UILabel()
        pageBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        pageBadgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        pageBadgeLabel.textColor = DesignSystem.Colors.primary
        pageBadge.addSubview(pageBadgeLabel)
        progPageBadgeLabel = pageBadgeLabel

        NSLayoutConstraint.activate([
            pageBadgeLabel.leadingAnchor.constraint(equalTo: pageBadge.leadingAnchor, constant: 6),
            pageBadgeLabel.trailingAnchor.constraint(equalTo: pageBadge.trailingAnchor, constant: -6),
            pageBadgeLabel.topAnchor.constraint(equalTo: pageBadge.topAnchor, constant: 2),
            pageBadgeLabel.bottomAnchor.constraint(equalTo: pageBadge.bottomAnchor, constant: -2)
        ])

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Checkbox
            checkbox.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            checkbox.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 30),
            checkbox.heightAnchor.constraint(equalToConstant: 30),

            // Title
            titleL.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 12),
            titleL.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            titleL.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            // Notes
            notesL.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
            notesL.trailingAnchor.constraint(equalTo: pageBadge.leadingAnchor, constant: -8),
            notesL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 4),
            notesL.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            // Page badge
            pageBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            pageBadge.centerYAnchor.constraint(equalTo: notesL.centerYAnchor)
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

        // Card opacity for done
        programmaticCard?.alpha = isDone ? 0.60 : 1.0

        updateCheckboxAppearance(isDone: isDone)
    }

    private func updateCheckboxAppearance(isDone: Bool) {
        let imageName = isDone ? "checkmark.circle.fill" : "circle"
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: config)

        progCheckbox?.setImage(image, for: .normal)
        progCheckbox?.tintColor = isDone ? DesignSystem.Colors.success : UIColor.tertiaryLabel
    }

    // MARK: - Checkbox Action
    @objc func checkboxTapped(_ sender: UIButton) {
        HapticHelper.success()
        // Spring bounce animation
        UIView.animate(withDuration: 0.10, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }) { _ in
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                sender.transform = .identity
            }, completion: nil)
        }
        onToggleDone?()
        onToggleCompletion?()
    }
}
