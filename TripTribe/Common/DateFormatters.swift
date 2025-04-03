//
//  DateFormatters.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import Foundation

enum DateFormat {
    static let formatter = DateFormatter()
    
    static func format(_ date: Date, style: Style = .medium) -> String {
        switch style {
        case .short:
            formatter.dateFormat = "MMM d"
        case .medium:
            formatter.dateFormat = "MMM d, yyyy"
        case .dateRange:
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: date)
    }
    
    static func formatDateRange(from: Date, to: Date) -> String {
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: from)) - \(formatter.string(from: to))"
    }
    
    enum Style {
        case short, medium, dateRange
    }
}
