//
//  Extensions.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Helpful Swift extensions for Date formatting, UI styling, and Alerts.
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
    
    /// Returns relative deadline text (e.g., "Today", "Tomorrow", "Overdue", or formatted date)
    func deadlineRelativeString() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if self < Date() {
            return "Overdue (\(self.formattedDate()))"
        } else {
            return self.formattedDate()
        }
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
}

// MARK: - UIView Styling Helpers
extension UIView {
    /// Adds rounded corner and subtle border
    func applyCardStyle(cornerRadius: CGFloat = 12.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
