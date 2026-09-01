//
//  Extensions.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Helpful Swift extensions for UI styling, Haptics, Loading HUD, and Date formatting.
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
    
    /// Shows a subtle Toast / HUD message for 1.5 seconds
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
        
        UIView.animate(withDuration: 0.25, animations: {
            toastLabel.alpha = 1.0
            toastLabel.transform = CGAffineTransform(translationX: 0, y: -8)
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 1.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
                toastLabel.transform = .identity
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIView Styling Helpers
extension UIView {
    /// Adds rounded corner, subtle border, and soft modern card shadow
    func applyCardStyle(cornerRadius: CGFloat = 14.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.backgroundColor = .secondarySystemGroupedBackground
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 6
    }
    
    /// Adds a pill badge shape
    func applyPillStyle() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
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
        imageView.tintColor = .systemGray3
        
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
