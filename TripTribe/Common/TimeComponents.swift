//
//  TimeComponents.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import Foundation

struct TimeComponents {
    var days: Int = 0
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    // Optional initializer with default values
    init(days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
        self.days = days
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    // Helper to check if all time components are zero
    var isZero: Bool {
        return days == 0 && hours == 0 && minutes == 0 && seconds == 0
    }
    
    // Get the total time in seconds
    var totalSeconds: Int {
        return seconds + (minutes * 60) + (hours * 3600) + (days * 86400)
    }
    
    // Format as a string like "2d 5h 30m 15s"
    func formatted(includeSeconds: Bool = true) -> String {
        var components: [String] = []
        
        if days > 0 {
            components.append("\(days)d")
        }
        
        if hours > 0 || days > 0 {
            components.append("\(hours)h")
        }
        
        if minutes > 0 || hours > 0 || days > 0 {
            components.append("\(minutes)m")
        }
        
        if includeSeconds {
            components.append("\(seconds)s")
        }
        
        return components.joined(separator: " ")
    }
}
