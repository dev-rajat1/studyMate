//
//  Extensions.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Helpful Swift extensions for Modern UI styling, Glassmorphism, Micro-Animations, Haptics, Toast HUD, and Date formatting.
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
    
    /// Shows a modern floating Toast badge with smooth spring entry and optional icon
    func showToast(message: String, icon: String? = nil, tintColor: UIColor = .systemPurple) {
        let container = UIView()
        container.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(white: 0.18, alpha: 0.95)
                : UIColor(white: 0.12, alpha: 0.95)
        }
        container.layer.cornerRadius = 20
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.18
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 10
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
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
            container.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            container.heightAnchor.constraint(equalToConstant: 42),
            
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        container.transform = CGAffineTransform(scaleX: 0.85, y: 0.85).concatenating(CGAffineTransform(translationX: 0, y: 20))
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            container.alpha = 1.0
            container.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 1.8, options: .curveEaseIn, animations: {
                container.alpha = 0.0
                container.transform = CGAffineTransform(translationX: 0, y: -12)
            }) { _ in
                container.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIView Styling & Micro-Animation Helpers
extension UIView {
    /// Adds rounded corners, subtle adaptive border, and soft modern card shadow
    func applyCardStyle(cornerRadius: CGFloat = 16.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.backgroundColor = .secondarySystemGroupedBackground
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.withAlphaComponent(0.2).cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 10
    }
    
    /// Adds glassmorphic style with blur effect
    func applyGlassmorphicStyle(cornerRadius: CGFloat = 16.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.secondarySystemGroupedBackground.withAlphaComponent(0.85)
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
    }
    
    /// Touch down bounce feedback
    func bounceTouchDown() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.alpha = 0.92
        }, completion: nil)
    }
    
    /// Touch up bounce recovery
    func bounceTouchUp() {
        UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.transform = .identity
            self.alpha = 1.0
        }, completion: nil)
    }
    
    /// Subtle pulse animation for celebratory triggers
    func pulse() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.15
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.06
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    /// Adds subtle shake effect for error indications
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-12.0, 12.0, -8.0, 8.0, -4.0, 4.0, 0.0]
        self.layer.add(animation, forKey: "shake")
    }
}

// MARK: - UITableViewCell Micro-Animations
extension UITableViewCell {
    /// Plays a fluid stagger entrance animation when cells are loaded
    func animateGlideIn(delayIndex: Int = 0) {
        self.alpha = 0.0
        self.transform = CGAffineTransform(translationX: 0, y: 22)
        
        let delay = Double(min(delayIndex, 8)) * 0.04
        UIView.animate(withDuration: 0.45, delay: delay, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.6, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.alpha = 1.0
            self.transform = .identity
        }, completion: nil)
    }
}

// MARK: - Empty State Component Helper for TableViews
extension UITableView {
    func setEmptyState(iconName: String, title: String, message: String, actionTitle: String? = nil, actionHandler: (() -> Void)? = nil) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle(cornerRadius: 20)
        card.backgroundColor = .secondarySystemGroupedBackground
        container.addSubview(card)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon badge with soft background circle
        let iconCircle = UIView()
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
        iconCircle.layer.cornerRadius = 36
        iconCircle.clipsToBounds = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .medium)
        let imageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: config))
        imageView.tintColor = .systemPurple
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconCircle.addSubview(imageView)
        NSLayoutConstraint.activate([
            iconCircle.widthAnchor.constraint(equalToConstant: 72),
            iconCircle.heightAnchor.constraint(equalToConstant: 72),
            imageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 13, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        stack.addArrangedSubview(iconCircle)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 28),
            card.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -28),
            
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
        
        self.backgroundView = container
    }
    
    func removeEmptyState() {
        self.backgroundView = nil
    }
}

