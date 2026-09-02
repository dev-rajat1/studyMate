//
//  ColorHelper.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Helper for managing Course color tags, dynamic gradients, and modern UI accent palettes.
//

import UIKit

struct CourseColor {
    let name: String
    let color: UIColor
    let lightTint: UIColor
    let gradientColors: [CGColor]
}

class ColorHelper {
    
    /// Predefined vibrant, accessible and modern iOS 18 style colors for courses
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
            color: UIColor(red: 0.58, green: 0.32, blue: 0.95, alpha: 1.0),
            lightTint: UIColor(red: 0.58, green: 0.32, blue: 0.95, alpha: 0.12),
            gradientColors: [
                UIColor(red: 0.58, green: 0.32, blue: 0.95, alpha: 1.0).cgColor,
                UIColor(red: 0.74, green: 0.48, blue: 0.98, alpha: 1.0).cgColor
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
    
    /// Return UIColor for a stored color name, or a default blue
    static func color(named name: String?) -> UIColor {
        guard let name = name else { return availableColors[0].color }
        return availableColors.first { $0.name.lowercased() == name.lowercased() }?.color ?? availableColors[0].color
    }
    
    /// Return light transparent tint color for tags, badges and background pills
    static func lightTint(named name: String?) -> UIColor {
        guard let name = name else { return availableColors[0].lightTint }
        return availableColors.first { $0.name.lowercased() == name.lowercased() }?.lightTint ?? availableColors[0].lightTint
    }
    
    /// Return gradient colors for a course name
    static func gradientColors(named name: String?) -> [CGColor] {
        guard let name = name else { return availableColors[0].gradientColors }
        return availableColors.first { $0.name.lowercased() == name.lowercased() }?.gradientColors ?? availableColors[0].gradientColors
    }
    
    /// AI Gemini Sparkle Brand Gradient
    static let geminiGradient: [CGColor] = [
        UIColor(red: 0.58, green: 0.32, blue: 0.95, alpha: 1.0).cgColor, // Deep Violet
        UIColor(red: 0.18, green: 0.55, blue: 0.98, alpha: 1.0).cgColor  // Electric Blue
    ]
    
    /// Streak Fire Gradient
    static let streakGradient: [CGColor] = [
        UIColor(red: 1.00, green: 0.35, blue: 0.20, alpha: 1.0).cgColor,
        UIColor(red: 1.00, green: 0.65, blue: 0.15, alpha: 1.0).cgColor
    ]
}

