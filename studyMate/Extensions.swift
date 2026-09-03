//
//  Extensions.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Premium UI Extensions — Cards, Glassmorphism, Micro-Animations, Haptics, Toast HUD, Progress Ring, Gradient Text.
//

import UIKit

// MARK: - Date Formatting Helpers
extension Date {
    /// Formats date to a clean readable string (e.g., "Oct 12, 2026")
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Returns today's formatted greeting string (e.g. "Tuesday, Sep 1")
    func formattedGreetingDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: self)
    }

    /// Returns relative deadline text (e.g., "Due Today", "Due Tomorrow", "Overdue", or formatted date)
    func deadlineRelativeString() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Due Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Due Tomorrow"
        } else if self < Date() {
            return "Overdue (\(self.formattedDate()))"
        } else {
            return "Due \(self.formattedDate())"
        }
    }
}

// MARK: - Markdown Rendering
extension String {
    /// Renders basic markdown (bold, headers, inline code) into an NSAttributedString
    func renderMarkdown() -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let boldFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        let headerFont = UIFont.systemFont(ofSize: 17, weight: .black)
        
        let mutableAttr = NSMutableAttributedString(string: self, attributes: [
            .font: baseFont,
            .foregroundColor: UIColor.label
        ])
        
        // **Bold**
        if let boldRegex = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: []) {
            let matches = boldRegex.matches(in: mutableAttr.string, options: [], range: NSRange(location: 0, length: mutableAttr.length))
            for match in matches.reversed() {
                let fullRange = match.range(at: 0)
                let innerRange = match.range(at: 1)
                let text = (mutableAttr.string as NSString).substring(with: innerRange)
                let replacement = NSAttributedString(string: text, attributes: [.font: boldFont, .foregroundColor: UIColor.label])
                mutableAttr.replaceCharacters(in: fullRange, with: replacement)
            }
        }
        
        // *Italic*
        let italicFont = UIFont.italicSystemFont(ofSize: 15)
        if let italicRegex = try? NSRegularExpression(pattern: "\\*(.*?)\\*", options: []) {
            let matches = italicRegex.matches(in: mutableAttr.string, options: [], range: NSRange(location: 0, length: mutableAttr.length))
            for match in matches.reversed() {
                let fullRange = match.range(at: 0)
                let innerRange = match.range(at: 1)
                let text = (mutableAttr.string as NSString).substring(with: innerRange)
                let replacement = NSAttributedString(string: text, attributes: [.font: italicFont, .foregroundColor: UIColor.label])
                mutableAttr.replaceCharacters(in: fullRange, with: replacement)
            }
        }
        
        // # Headers (e.g. ## Header)
        if let headerRegex = try? NSRegularExpression(pattern: "^#+\\s*(.*?)$", options: [.anchorsMatchLines]) {
            let matches = headerRegex.matches(in: mutableAttr.string, options: [], range: NSRange(location: 0, length: mutableAttr.length))
            for match in matches.reversed() {
                let fullRange = match.range(at: 0)
                let innerRange = match.range(at: 1)
                let text = (mutableAttr.string as NSString).substring(with: innerRange)
                let replacement = NSAttributedString(string: text, attributes: [.font: headerFont, .foregroundColor: UIColor.label])
                mutableAttr.replaceCharacters(in: fullRange, with: replacement)
            }
        }
        
        return mutableAttr
    }
}

// MARK: - Haptic Feedback Helper
class HapticHelper {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    static func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}

// MARK: - UIViewController Helpers
extension UIViewController {

    /// Shows a standard native Alert with an OK button
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }

    /// Shows a confirmation dialog with Cancel and Confirm actions
    func showConfirmationAlert(title: String, message: String, confirmTitle: String = "Delete", isDestructive: Bool = true, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: isDestructive ? .destructive : .default, handler: { _ in
            onConfirm()
        }))
        present(alert, animated: true)
    }

    /// Shows a premium floating Toast badge with smooth spring animation and SF Symbol icon
    func showToast(message: String, icon: String? = nil, tintColor: UIColor = DesignSystem.Colors.primary) {
        let container = UIView()
        container.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.14, alpha: 0.96)
                : UIColor(white: 0.10, alpha: 0.96)
        }
        container.layer.cornerRadius = 24
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.22
        container.layer.shadowOffset = CGSize(width: 0, height: 6)
        container.layer.shadowRadius = 14
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        container.alpha = 0.0
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        if let icon = icon {
            let iconView = UIImageView(image: UIImage(systemName: icon))
            iconView.tintColor = tintColor
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 18).isActive = true
            stack.addArrangedSubview(iconView)
        }

        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        stack.addArrangedSubview(toastLabel)

        container.addSubview(stack)
        self.view.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            container.heightAnchor.constraint(equalToConstant: 46),

            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        container.transform = CGAffineTransform(scaleX: 0.82, y: 0.82).concatenating(CGAffineTransform(translationX: 0, y: 24))

        UIView.animate(withDuration: 0.38, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            container.alpha = 1.0
            container.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.28, delay: 1.9, options: .curveEaseIn, animations: {
                container.alpha = 0.0
                container.transform = CGAffineTransform(translationX: 0, y: -14)
            }) { _ in
                container.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIView Styling & Micro-Animation Helpers
extension UIView {

    /// Premium card style — elevated, modern surface with adaptive border and depth shadow
    func applyCardStyle(cornerRadius: CGFloat = 16) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.backgroundColor = .secondarySystemGroupedBackground
        
        // Very subtle border
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.withAlphaComponent(0.1).cgColor
        
        // Soft, minimalist flat shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.04
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
    }

    /// Glassmorphic card — translucent blur-glass surface with tinted border glow
    func applyGlassmorphicStyle(cornerRadius: CGFloat = 16) {
        // Simplified to standard card for a cleaner, flatter aesthetic
        applyCardStyle(cornerRadius: cornerRadius)
    }

    /// Touch-down micro-press feedback (subtle scale down)
    func bounceTouchDown() {
        UIView.animate(withDuration: 0.10, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.90
        }, completion: nil)
    }

    /// Touch-up spring recovery
    func bounceTouchUp() {
        UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.transform = .identity
            self.alpha = 1.0
        }, completion: nil)
    }

    /// Subtle celebratory pulse (1 cycle)
    func pulse() {
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.duration = 0.15
        anim.fromValue = 1.0
        anim.toValue = 1.07
        anim.autoreverses = true
        anim.repeatCount = 1
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(anim, forKey: "pulse")
    }

    /// Error shake animation
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-12.0, 12.0, -8.0, 8.0, -4.0, 4.0, 0.0]
        self.layer.add(animation, forKey: "shake")
    }

    /// Fade-in entrance from slightly below
    func fadeInFromBottom(delay: Double = 0, distance: CGFloat = 20) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: distance)
        UIView.animate(withDuration: 0.42, delay: delay, usingSpringWithDamping: 0.80, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction]) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}

// MARK: - UITableViewCell Micro-Animations
extension UITableViewCell {
    /// Fluid stagger glide-in entrance animation
    func animateGlideIn(delayIndex: Int = 0) {
        self.alpha = 0.0
        self.transform = CGAffineTransform(translationX: 0, y: 24)

        let delay = Double(min(delayIndex, 10)) * 0.038
        UIView.animate(withDuration: 0.46, delay: delay, usingSpringWithDamping: 0.80, initialSpringVelocity: 0.6, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.alpha = 1.0
            self.transform = .identity
        }, completion: nil)
    }
}

// MARK: - Animated Progress Ring (Circular Gauge)
typealias CircularProgressView = ProgressRingView

class ProgressRingView: UIView {

    var progress: CGFloat = 0.0 {
        didSet { animateProgress() }
    }
    var ringColor: UIColor = DesignSystem.Colors.primary
    var trackColor: UIColor = UIColor.separator.withAlphaComponent(0.15)
    var lineWidth: CGFloat = 10

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let percentLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        backgroundColor = .clear

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = ringColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.textAlignment = .center
        percentLabel.font = .systemFont(ofSize: 28, weight: .black)
        percentLabel.textColor = .label
        addSubview(percentLabel)

        NSLayoutConstraint.activate([
            percentLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) / 2) - lineWidth
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi

        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = ringColor.cgColor
        trackLayer.strokeColor = trackColor.cgColor
    }

    private func animateProgress() {
        let targetProgress = min(max(progress, 0), 1)
        percentLabel.text = "\(Int(targetProgress * 100))%"

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = targetProgress
        animation.duration = 1.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = targetProgress
    }

    func configure(progress: CGFloat, ringColor: UIColor, trackColor: UIColor = UIColor.separator.withAlphaComponent(0.15)) {
        self.ringColor = ringColor
        self.trackColor = trackColor
        setNeedsLayout()
        layoutIfNeeded()
        self.progress = progress
    }
}

// MARK: - UILabel Gradient Text Helper
extension UILabel {
    /// Renders label text as a gradient-filled image mask
    func applyGradientText(colors: [CGColor]) {
        guard let text = self.text, !text.isEmpty else { return }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)

        if let gradientImage = UIGraphicsGetImageFromCurrentImageContext() {
            self.textColor = UIColor(patternImage: gradientImage)
        }
    }
}

// MARK: - Empty State Component Helper for TableViews
extension UITableView {
    func setEmptyState(iconName: String, title: String, message: String, actionTitle: String? = nil, actionHandler: (() -> Void)? = nil) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 24)
        container.addSubview(card)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        // Glowing icon circle
        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = DesignSystem.Colors.primary.withAlphaComponent(0.12)
        iconCircle.layer.cornerRadius = 40
        iconCircle.clipsToBounds = false
        iconCircle.layer.shadowColor = DesignSystem.Colors.primary.cgColor
        iconCircle.layer.shadowOpacity = 0.22
        iconCircle.layer.shadowRadius = 14
        iconCircle.layer.shadowOffset = CGSize(width: 0, height: 4)

        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .medium)
        let imageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: config))
        imageView.tintColor = DesignSystem.Colors.primary
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        iconCircle.addSubview(imageView)
        NSLayoutConstraint.activate([
            iconCircle.widthAnchor.constraint(equalToConstant: 80),
            iconCircle.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 38),
            imageView.heightAnchor.constraint(equalToConstant: 38)
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        stack.addArrangedSubview(iconCircle)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)

        if let actionTitle = actionTitle, let handler = actionHandler {
            let actionButton = UIButton(type: .system)
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            actionButton.backgroundColor = DesignSystem.Colors.primary
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.layer.cornerRadius = 20
            actionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 22, bottom: 10, right: 22)
            DesignSystem.Shadow.applyGlow(to: actionButton.layer, color: DesignSystem.Colors.primary)
            stack.addArrangedSubview(actionButton)
        }

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -24),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 28),
            card.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -28),

            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28)
        ])

        // Entrance animation
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        UIView.animate(withDuration: 0.45, delay: 0.05, usingSpringWithDamping: 0.78, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            card.alpha = 1
            card.transform = .identity
        }

        self.backgroundView = container
    }

    func removeEmptyState() {
        self.backgroundView = nil
    }
}

// MARK: - Gradient FAB Builder
extension UIButton {
    /// Applies a gradient background to a button with glow shadow
    func applyGradientFAB(colors: [CGColor], cornerRadius: CGFloat = 24) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = false
        applyGradientBackground(colors: colors, cornerRadius: cornerRadius)
        if let firstColor = colors.first {
            let glowColor = UIColor(cgColor: firstColor)
            DesignSystem.Shadow.applyGlow(to: self.layer, color: glowColor)
        }
    }
}

// MARK: - Layout Helpers
extension UIView {
    /// Adds multiple subviews at once
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}

extension UIStackView {
    /// Creates a UIStackView quickly
    static func make(axis: NSLayoutConstraint.Axis, spacing: CGFloat = 8, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}
