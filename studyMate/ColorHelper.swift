//
//  ColorHelper.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Helper for managing Course color tags and modern UI accent colors.
//

import UIKit

struct CourseColor {
    let name: String
    let color: UIColor
}

class ColorHelper {
    
    /// Predefined vibrant and accessible colors for courses
    static let availableColors: [CourseColor] = [
        CourseColor(name: "Blue", color: UIColor(red: 0.18, green: 0.50, blue: 0.98, alpha: 1.0)),
        CourseColor(name: "Purple", color: UIColor(red: 0.58, green: 0.32, blue: 0.95, alpha: 1.0)),
        CourseColor(name: "Emerald", color: UIColor(red: 0.10, green: 0.74, blue: 0.47, alpha: 1.0)),
        CourseColor(name: "Orange", color: UIColor(red: 0.98, green: 0.55, blue: 0.20, alpha: 1.0)),
        CourseColor(name: "Rose", color: UIColor(red: 0.96, green: 0.26, blue: 0.45, alpha: 1.0)),
        CourseColor(name: "Teal", color: UIColor(red: 0.08, green: 0.68, blue: 0.75, alpha: 1.0))
    ]
    
    /// Return UIColor for a stored color name, or a default blue
    static func color(named name: String?) -> UIColor {
        guard let name = name else { return availableColors[0].color }
        return availableColors.first { $0.name.lowercased() == name.lowercased() }?.color ?? availableColors[0].color
    }
}
