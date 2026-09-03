//
//  ColorHelper.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Centralized Design System — Brand Colors, Gradients, Typography, Shadows, and Utility Helpers.
//

import UIKit

// MARK: - Course Color Model
struct CourseColor {
    let name: String
    let color: UIColor
    let lightTint: UIColor
    let gradientColors: [CGColor]
}

// MARK: - Design System (Brand Tokens)
struct DesignSystem {

    // MARK: - Brand Colors
    struct Colors {
        /// Primary Electric Indigo
        static let primary = UIColor(red: 0.424, green: 0.388, blue: 1.000, alpha: 1.0)
        /// Violet Secondary
        static let secondary = UIColor(red: 0.659, green: 0.408, blue: 0.988, alpha: 1.0)
        /// Teal Accent
        static let teal = UIColor(red: 0.306, green: 0.929, blue: 0.784, alpha: 1.0)
        /// Coral Danger
        static let coral = UIColor(red: 1.000, green: 0.420, blue: 0.420, alpha: 1.0)
        /// Success Green
        static let success = UIColor(red: 0.196, green: 0.843, blue: 0.573, alpha: 1.0)
        /// Streak Orange
        static let streak = UIColor(red: 1.000, green: 0.600, blue: 0.200, alpha: 1.0)
    }

    // MARK: - Gradients (CGColor arrays for CAGradientLayer)
    struct Gradients {
        /// Primary AI/Brand gradient: Indigo → Violet
        static let primary: [CGColor] = [
            UIColor(red: 0.424, green: 0.388, blue: 1.000, alpha: 1.0).cgColor,
            UIColor(red: 0.659, green: 0.408, blue: 0.988, alpha: 1.0).cgColor
        ]
        /// Hero banner dark gradient: Deep Navy → Indigo
        static let hero: [CGColor] = [
            UIColor(red: 0.094, green: 0.118, blue: 0.373, alpha: 1.0).cgColor,
            UIColor(red: 0.424, green: 0.388, blue: 1.000, alpha: 1.0).cgColor
        ]
        /// Streak fire gradient
        static let streak: [CGColor] = [
            UIColor(red: 1.000, green: 0.35, blue: 0.20, alpha: 1.0).cgColor,
            UIColor(red: 1.000, green: 0.65, blue: 0.15, alpha: 1.0).cgColor
        ]
        /// Success gradient
        static let success: [CGColor] = [
            UIColor(red: 0.196, green: 0.843, blue: 0.573, alpha: 1.0).cgColor,
            UIColor(red: 0.000, green: 0.698, blue: 0.459, alpha: 1.0).cgColor
        ]
    }

    // MARK: - Corner Radii
    struct Radius {
        static let card: CGFloat = 16
        static let pill: CGFloat = 12
        static let chip: CGFloat = 8
        static let icon: CGFloat = 12
    }

    // MARK: - Shadows
    struct Shadow {
        static func applyCard(to layer: CALayer, color: UIColor = .black) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = 0.04
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 8
            layer.masksToBounds = false
        }

        static func applyGlow(to layer: CALayer, color: UIColor) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = 0.20
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 12
            layer.masksToBounds = false
        }
    }

    // MARK: - Spacing
    struct Spacing {
        static let screenEdge: CGFloat = 16
        static let cardInner: CGFloat = 16
        static let itemGap: CGFloat = 12
    }
}

// MARK: - Course Color Palette
class ColorHelper {

    /// Predefined vibrant, accessible modern iOS 18-style colors for courses
    static let availableColors: [CourseColor] = [
        CourseColor(
            name: "Blue",
            color: UIColor(red: 0.18, green: 0.50, blue: 0.98, alpha: 1.0),
            lightTint: UIColor(red: 0.18, green: 0.50, blue: 0.98, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.18, green: 0.50, blue: 0.98, alpha: 1.0).cgColor,
                UIColor(red: 0.35, green: 0.65, blue: 1.00, alpha: 1.0).cgColor
            ]
        ),
        CourseColor(
            name: "Purple",
            color: UIColor(red: 0.424, green: 0.388, blue: 1.000, alpha: 1.0),
            lightTint: UIColor(red: 0.424, green: 0.388, blue: 1.000, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.424, green: 0.388, blue: 1.000, alpha: 1.0).cgColor,
                UIColor(red: 0.659, green: 0.408, blue: 0.988, alpha: 1.0).cgColor
            ]
        ),
        CourseColor(
            name: "Emerald",
            color: UIColor(red: 0.10, green: 0.74, blue: 0.47, alpha: 1.0),
            lightTint: UIColor(red: 0.10, green: 0.74, blue: 0.47, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.10, green: 0.74, blue: 0.47, alpha: 1.0).cgColor,
                UIColor(red: 0.22, green: 0.85, blue: 0.60, alpha: 1.0).cgColor
            ]
        ),
        CourseColor(
            name: "Orange",
            color: UIColor(red: 0.98, green: 0.55, blue: 0.20, alpha: 1.0),
            lightTint: UIColor(red: 0.98, green: 0.55, blue: 0.20, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.98, green: 0.55, blue: 0.20, alpha: 1.0).cgColor,
                UIColor(red: 1.00, green: 0.70, blue: 0.35, alpha: 1.0).cgColor
            ]
        ),
        CourseColor(
            name: "Rose",
            color: UIColor(red: 0.96, green: 0.26, blue: 0.45, alpha: 1.0),
            lightTint: UIColor(red: 0.96, green: 0.26, blue: 0.45, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.96, green: 0.26, blue: 0.45, alpha: 1.0).cgColor,
                UIColor(red: 1.00, green: 0.45, blue: 0.60, alpha: 1.0).cgColor
            ]
        ),
        CourseColor(
            name: "Teal",
            color: UIColor(red: 0.08, green: 0.68, blue: 0.75, alpha: 1.0),
            lightTint: UIColor(red: 0.08, green: 0.68, blue: 0.75, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.08, green: 0.68, blue: 0.75, alpha: 1.0).cgColor,
                UIColor(red: 0.20, green: 0.82, blue: 0.88, alpha: 1.0).cgColor
            ]
        ),
        CourseColor(
            name: "Indigo",
            color: UIColor(red: 0.38, green: 0.38, blue: 0.92, alpha: 1.0),
            lightTint: UIColor(red: 0.38, green: 0.38, blue: 0.92, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.38, green: 0.38, blue: 0.92, alpha: 1.0).cgColor,
                UIColor(red: 0.55, green: 0.55, blue: 1.00, alpha: 1.0).cgColor
            ]
        )
    ]

    /// Return UIColor for a stored color name, or default primary indigo
    static func color(named name: String?) -> UIColor {
        guard let name = name else { return availableColors[1].color }
        return availableColors.first { $0.name.lowercased() == name.lowercased() }?.color ?? availableColors[1].color
    }

    /// Return light transparent tint color for tags, badges, background pills
    static func lightTint(named name: String?) -> UIColor {
        guard let name = name else { return availableColors[1].lightTint }
        return availableColors.first { $0.name.lowercased() == name.lowercased() }?.lightTint ?? availableColors[1].lightTint
    }

    /// Return gradient colors for a course name
    static func gradientColors(named name: String?) -> [CGColor] {
        guard let name = name else { return availableColors[1].gradientColors }
        return availableColors.first { $0.name.lowercased() == name.lowercased() }?.gradientColors ?? availableColors[1].gradientColors
    }

    /// AI Gemini Brand Gradient
    static let geminiGradient: [CGColor] = DesignSystem.Gradients.primary

    /// Streak Fire Gradient
    static let streakGradient: [CGColor] = DesignSystem.Gradients.streak
}

// MARK: - CALayer Gradient Extension
extension CALayer {
    /// Adds or updates a named gradient sublayer to this layer.
    func applyGradient(colors: [CGColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1), cornerRadius: CGFloat = 0) {
        sublayers?.removeAll(where: { $0.name == "SMGradientLayer" })

        let gradient = CAGradientLayer()
        gradient.name = "SMGradientLayer"
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.cornerRadius = cornerRadius
        insertSublayer(gradient, at: 0)
    }
}

// MARK: - GradientView (CoreAnimation-backed responsive gradient view)
class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    func setGradient(colors: [CGColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1), cornerRadius: CGFloat = 0) {
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }
}

// MARK: - UIView Gradient Helpers
private var gradientObserverKey: UInt8 = 0

extension UIView {
    /// Applies a gradient background to this view using a CAGradientLayer that stays in sync across rotations and resizes
    func applyGradientBackground(colors: [CGColor], startPoint: CGPoint = CGPoint(x: 0, y: 0.5), endPoint: CGPoint = CGPoint(x: 1, y: 0.5), cornerRadius: CGFloat = 0) {
        layer.applyGradient(colors: colors, startPoint: startPoint, endPoint: endPoint, cornerRadius: cornerRadius)
        layer.cornerRadius = cornerRadius
        
        let observer = self.observe(\.bounds, options: [.initial, .new]) { (view, change) in
            if let bounds = change.newValue, let grad = view.layer.sublayers?.first(where: { $0.name == "SMGradientLayer" }) {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                grad.frame = bounds
                grad.cornerRadius = view.layer.cornerRadius
                CATransaction.commit()
            }
        }
        objc_setAssociatedObject(self, &gradientObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /// Explicitly syncs gradient sublayer to current bounds (useful in viewDidLayoutSubviews or layoutSubviews)
    func syncGradientBounds() {
        if let grad = layer.sublayers?.first(where: { $0.name == "SMGradientLayer" }) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            grad.frame = bounds
            grad.cornerRadius = layer.cornerRadius
            CATransaction.commit()
        }
    }
}

