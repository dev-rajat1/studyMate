//
//  StatsViewController.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Tab 3 — Premium Analytics Dashboard with Animated Circular Gauge, 2x2 Metric Grid, and Per-Course Mastery Bars.
//

import UIKit

class StatsViewController: UIViewController {

    // MARK: - IBOutlets (Storyboard Compatibility)
    @IBOutlet weak var totalCoursesLabel: UILabel?
    @IBOutlet weak var totalTopicsLabel: UILabel?
    @IBOutlet weak var totalTasksLabel: UILabel?
    @IBOutlet weak var completedTasksLabel: UILabel?
    @IBOutlet weak var completionRateLabel: UILabel?
    @IBOutlet weak var progressView: UIProgressView?
    @IBOutlet weak var motivationLabel: UILabel?
    @IBOutlet weak var overallProgressCard: UIView?
    @IBOutlet weak var numbersGridCard: UIView?

    // MARK: - Programmatic Components
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshAnalytics()
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "Analytics"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        // Style storyboard outlets if present
        overallProgressCard?.applyCardStyle(cornerRadius: 20)
        numbersGridCard?.applyCardStyle(cornerRadius: 20)
        progressView?.layer.cornerRadius = 4
        progressView?.clipsToBounds = true
        progressView?.tintColor = DesignSystem.Colors.primary
        progressView?.trackTintColor = UIColor.separator.withAlphaComponent(0.12)

        // Programmatic scroll layout (when no storyboard)
        if overallProgressCard == nil {
            setupScrollLayout()
        }
    }

    private func setupScrollLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -28),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Refresh All Analytics
    private func refreshAnalytics() {
        let (courses, topics, tasks, completed, rate) = CoreDataManager.shared.getAppStats()
        let insights = CoreDataManager.shared.getCourseMasteryInsights()

        // ---- Update storyboard outlets ----
        totalCoursesLabel?.text = "\(courses)"
        totalTopicsLabel?.text = "\(topics)"
        totalTasksLabel?.text = "\(tasks)"
        completedTasksLabel?.text = "\(completed)"
        completionRateLabel?.text = "\(Int(rate))%"
        let prog: Float = tasks > 0 ? Float(completed) / Float(tasks) : 0
        progressView?.setProgress(prog, animated: true)

        let lowestCourse = insights.filter { $0.totalLessons > 0 && $0.progress < 1.0 }.min(by: { $0.progress < $1.progress })
        let totalAI = insights.reduce(0) { $0 + $1.aiSummaryCount }
        if tasks == 0 {
            motivationLabel?.text = "🌱 Create courses and lessons to unlock subject mastery metrics!"
        } else if rate >= 100 {
            motivationLabel?.text = "🏆 Master Level! You've completed 100% of your curriculum!"
        } else if let focus = lowestCourse {
            motivationLabel?.text = "🎯 Focus on \"\(focus.course.name ?? "Subject")\" — \(Int(focus.progress * 100))% mastered."
        } else {
            motivationLabel?.text = "🔥 Great momentum! \(totalAI) AI summaries ready for active recall."
        }

        // ---- Rebuild programmatic layout ----
        if overallProgressCard == nil {
            rebuildProgrammaticDashboard(
                courses: courses, topics: topics, tasks: tasks,
                completed: completed, rate: Float(rate), insights: insights
            )
        }
    }

    // MARK: - Programmatic Dashboard Builder
    private func rebuildProgrammaticDashboard(
        courses: Int, topics: Int, tasks: Int,
        completed: Int, rate: Float,
        insights: [CourseMasteryInsight]
    ) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 1. Overall Gauge Card
        let gaugeCard = buildGaugeCard(rate: rate, completed: completed, total: tasks)
        contentStack.addArrangedSubview(gaugeCard)

        // 2. 2x2 Stats Grid
        let gridCard = buildStatsGrid(courses: courses, topics: topics, tasks: tasks, completed: completed)
        contentStack.addArrangedSubview(gridCard)

        // 3. Per-Course Mastery Section
        if !insights.isEmpty {
            let masteryCard = buildMasteryCard(insights: insights)
            contentStack.addArrangedSubview(masteryCard)
        }

        // 4. Motivation Banner
        let motivationCard = buildMotivationCard(rate: rate, tasks: tasks, insights: insights)
        contentStack.addArrangedSubview(motivationCard)

        // Animate in
        contentStack.arrangedSubviews.enumerated().forEach { (i, v) in
            v.fadeInFromBottom(delay: Double(i) * 0.08)
        }
    }

    // MARK: - Gauge Card
    private func buildGaugeCard(rate: Float, completed: Int, total: Int) -> UIView {
        let card = UIView()
        card.applyCardStyle(cornerRadius: 24)

        // Gradient top accent line
        let accentLine = UIView()
        accentLine.translatesAutoresizingMaskIntoConstraints = false
        accentLine.applyGradientBackground(colors: DesignSystem.Gradients.primary, cornerRadius: 0)
        card.addSubview(accentLine)

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "Overall Mastery"
        headerLabel.font = .systemFont(ofSize: 18, weight: .bold)
        headerLabel.textColor = .label
        card.addSubview(headerLabel)

        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.text = "\(completed) of \(total) lessons completed"
        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .secondaryLabel
        card.addSubview(subLabel)

        let ring = ProgressRingView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.lineWidth = 12
        card.addSubview(ring)

        NSLayoutConstraint.activate([
            accentLine.topAnchor.constraint(equalTo: card.topAnchor),
            accentLine.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            accentLine.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            accentLine.heightAnchor.constraint(equalToConstant: 4),

            headerLabel.topAnchor.constraint(equalTo: accentLine.bottomAnchor, constant: 18),
            headerLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            subLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            subLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),

            ring.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            ring.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 20),
            ring.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            ring.widthAnchor.constraint(equalToConstant: 140),
            ring.heightAnchor.constraint(equalToConstant: 140)
        ])

        DispatchQueue.main.async {
            ring.setNeedsLayout()
            ring.layoutIfNeeded()
            ring.configure(progress: CGFloat(rate / 100), ringColor: DesignSystem.Colors.primary)
        }

        return card
    }

    // MARK: - 2x2 Stats Grid
    private func buildStatsGrid(courses: Int, topics: Int, tasks: Int, completed: Int) -> UIView {
        let card = UIView()
        card.applyCardStyle(cornerRadius: 24)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Study Metrics"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        card.addSubview(titleLabel)

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.distribution = .fillEqually
        topRow.spacing = 12
        topRow.translatesAutoresizingMaskIntoConstraints = false

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fillEqually
        bottomRow.spacing = 12
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        let metrics: [(String, String, UIColor, String)] = [
            ("books.vertical.fill", "\(courses)", DesignSystem.Colors.primary, "Courses"),
            ("square.stack.3d.up.fill", "\(topics)", DesignSystem.Colors.secondary, "Modules"),
            ("doc.text.fill", "\(tasks)", DesignSystem.Colors.teal, "Lessons"),
            ("checkmark.circle.fill", "\(completed)", DesignSystem.Colors.success, "Completed")
        ]

        for (i, (icon, value, color, label)) in metrics.enumerated() {
            let metricCard = buildMetricCard(icon: icon, value: value, color: color, label: label)
            if i < 2 { topRow.addArrangedSubview(metricCard) }
            else { bottomRow.addArrangedSubview(metricCard) }
        }

        let rowStack = UIStackView(arrangedSubviews: [topRow, bottomRow])
        rowStack.axis = .vertical
        rowStack.spacing = 12
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rowStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            rowStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            rowStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            rowStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func buildMetricCard(icon: String, value: String, color: UIColor, label: String) -> UIView {
        let card = UIView()
        card.backgroundColor = color.withAlphaComponent(0.08)
        card.layer.cornerRadius = 16
        card.clipsToBounds = false

        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = color.withAlphaComponent(0.15)
        iconBg.layer.cornerRadius = 12
        card.addSubview(iconBg)

        let iconConf = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconConf))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconBg.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 36),
            iconBg.heightAnchor.constraint(equalToConstant: 36)
        ])

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 32, weight: .black)
        valueLabel.textColor = color
        card.addSubview(valueLabel)

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = label
        nameLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        nameLabel.textColor = .secondaryLabel
        card.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            iconBg.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),

            valueLabel.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: iconBg.leadingAnchor),

            nameLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    // MARK: - Per-Course Mastery Card
    private func buildMasteryCard(insights: [CourseMasteryInsight]) -> UIView {
        let card = UIView()
        card.applyCardStyle(cornerRadius: 24)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Subject Mastery"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        card.addSubview(titleLabel)

        let rowStack = UIStackView()
        rowStack.axis = .vertical
        rowStack.spacing = 14
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rowStack)

        for insight in insights.prefix(6) {
            let courseColor = ColorHelper.color(named: insight.course.colorTag)
            let row = buildMasteryRow(insight: insight, color: courseColor)
            rowStack.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            rowStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            rowStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            rowStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func buildMasteryRow(insight: CourseMasteryInsight, color: UIColor) -> UIView {
        let row = UIView()

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = insight.course.name ?? "Subject"
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        row.addSubview(nameLabel)

        let pctLabel = UILabel()
        pctLabel.translatesAutoresizingMaskIntoConstraints = false
        pctLabel.text = "\(Int(insight.progress * 100))%"
        pctLabel.font = .systemFont(ofSize: 13, weight: .bold)
        pctLabel.textColor = color
        row.addSubview(pctLabel)

        let track = UIView()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.backgroundColor = UIColor.separator.withAlphaComponent(0.12)
        track.layer.cornerRadius = 4
        track.clipsToBounds = true
        row.addSubview(track)

        let fill = UIView()
        fill.translatesAutoresizingMaskIntoConstraints = false
        fill.backgroundColor = color
        fill.layer.cornerRadius = 4
        track.addSubview(fill)

        NSLayoutConstraint.activate([
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: max(CGFloat(insight.progress), 0.02))
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: row.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: pctLabel.leadingAnchor, constant: -8),

            pctLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            pctLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),

            track.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            track.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            track.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            track.heightAnchor.constraint(equalToConstant: 7),
            track.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }

    // MARK: - Motivation Banner
    private func buildMotivationCard(rate: Float, tasks: Int, insights: [CourseMasteryInsight]) -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 20
        card.clipsToBounds = true
        card.applyGradientBackground(colors: DesignSystem.Gradients.hero, cornerRadius: 20)

        let iconConf = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let icon: String
        let message: String
        let totalAI = insights.reduce(0) { $0 + $1.aiSummaryCount }
        let lowestCourse = insights.filter { $0.totalLessons > 0 && $0.progress < 1.0 }.min(by: { $0.progress < $1.progress })

        if tasks == 0 {
            icon = "seedling"
            message = "Create courses and study lessons to unlock detailed subject mastery!"
        } else if rate >= 100 {
            icon = "trophy.fill"
            message = "Master Level! You've completed 100% of your curriculum!"
        } else if let focus = lowestCourse {
            icon = "target"
            message = "Focus Priority: \"\(focus.course.name ?? "Subject")\" is at \(Int(focus.progress * 100))% mastery!"
        } else {
            icon = "flame.fill"
            message = "Great momentum! \(totalAI) AI summaries ready for active recall!"
        }

        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconConf))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        card.addSubview(iconView)

        let msgLabel = UILabel()
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        msgLabel.text = message
        msgLabel.font = .systemFont(ofSize: 15, weight: .bold)
        msgLabel.textColor = .white
        msgLabel.numberOfLines = 0
        card.addSubview(msgLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            msgLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            msgLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            msgLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            msgLabel.topAnchor.constraint(greaterThanOrEqualTo: card.topAnchor, constant: 16),
            msgLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }
}
