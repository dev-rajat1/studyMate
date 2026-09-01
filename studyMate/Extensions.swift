//
//  Extensions.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Helpful Swift extensions for UI styling, Micro-Animations, Haptics, Loading HUD, and Date formatting.
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
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
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
    
    /// Shows a modern floating Toast badge with smooth spring entry
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor(white: 0.15, alpha: 0.95)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 18
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 0.0
        
        let width = min(self.view.frame.width - 48, CGFloat(message.count * 9 + 48))
        toastLabel.frame = CGRect(x: (self.view.frame.width - width) / 2, y: self.view.frame.height - 140, width: width, height: 40)
        self.view.addSubview(toastLabel)
        
        toastLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).concatenating(CGAffineTransform(translationX: 0, y: 15))
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            toastLabel.alpha = 1.0
            toastLabel.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 1.6, options: .curveEaseIn, animations: {
                toastLabel.alpha = 0.0
                toastLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIView Styling & Animation Helpers
extension UIView {
    /// Adds rounded corner, subtle border, and soft modern card shadow
    func applyCardStyle(cornerRadius: CGFloat = 16.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.backgroundColor = .secondarySystemGroupedBackground
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.withAlphaComponent(0.25).cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.04
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 8
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
        self.transform = CGAffineTransform(translationX: 0, y: 20)
        
        let delay = Double(min(delayIndex, 8)) * 0.04
        UIView.animate(withDuration: 0.4, delay: delay, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.6, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.alpha = 1.0
            self.transform = .identity
        }, completion: nil)
    }
}

// MARK: - Empty State Component Helper for TableViews
extension UITableView {
    func setEmptyState(iconName: String, title: String, message: String) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        let imageView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: config))
        imageView.tintColor = .systemPurple
        
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
        
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -32)
        ])
        
        self.backgroundView = container
    }
    
    func removeEmptyState() {
        self.backgroundView = nil
    }
}
