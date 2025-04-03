//  Untitled.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import SwiftUI

struct ActivityListView: View {
    let activities: [Activity]
    let onTap: ((Activity) -> Void)?
    
    init(activities: [Activity], onTap: ((Activity) -> Void)? = nil) {
        // Group activities by day
        self.activities = activities
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if activities.isEmpty {
                emptyStateView
            } else {
                // Group activities by day
                ForEach(groupedActivities.keys.sorted(), id: \.self) { day in
                    if let dayActivities = groupedActivities[day] {
                        daySection(day: day, activities: dayActivities)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No activities yet")
                .font(.jakartaSans(18, weight: .bold))
            
            Text("Add activities to plan your trip!")
                .font(.jakartaSans(14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    private func daySection(day: String, activities: [Activity]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day header
            Text(day)
                .font(.jakartaSans(18, weight: .bold))
                .padding(.horizontal)
            
            // Activities for this day
            ForEach(activities) { activity in
                ActivityRow(activity: activity)
                    .onTapGesture {
                        onTap?(activity)
                    }
            }
        }
    }
    
    // Group activities by day
    private var groupedActivities: [String: [Activity]] {
        Dictionary(grouping: activities) { activity in
            // Format date to get day string (e.g., "Monday, April 3")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM d"
            return dateFormatter.string(from: activity.startDateTime)
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 16) {
            // Activity Time
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedTime)
                    .font(.jakartaSans(14, weight: .bold))
                
                Text(formattedDuration)
                    .font(.jakartaSans(12))
                    .foregroundColor(.gray)
            }
            .frame(width: 70, alignment: .leading)
            
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 46, height: 46)
                
                Image(systemName: activity.category.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(categoryColor)
            }
            
            // Activity details
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.jakartaSans(16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(activity.location)
                    .font(.jakartaSans(14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .padding(.horizontal)
    }
    
    // Format the time (e.g., "09:00 AM")
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: activity.startDateTime)
    }
    
    // Format the duration (e.g., "2 hours")
    private var formattedDuration: String {
        let hours = Int(activity.duration) / 60
        let minutes = Int(activity.duration) % 60
        
        if hours > 0 {
            let hourText = hours == 1 ? "hour" : "hours"
            if minutes > 0 {
                return "\(hours) \(hourText) \(minutes)m"
            } else {
                return "\(hours) \(hourText)"
            }
        } else {
            return "\(minutes) min"
        }
    }
    
    // Color based on category
    private var categoryColor: Color {
        switch activity.category {
        case .sightseeing: return .blue
        case .dining: return .orange
        case .adventure: return .green
        case .relaxation: return .purple
        case .cultural: return .red
        case .shopping: return .pink
        case .entertainment: return .yellow
        case .transportation: return .gray
        case .accommodation: return .brown
        case .other: return .black
        }
    }
}

#Preview {
    let now = Date()
    
    // Sample activities for preview
    let activities = [
        Activity(
            id: "1",
            tripId: "trip1",
            creatorId: "user1",
            name: "City Tour",
            location: "Downtown",
            startDateTime: now.addingTimeInterval(3600),
            duration: 120, // 2 hours
            category: .sightseeing,
            photoURL: nil,
            linkURL: nil,
            createdAt: now,
            updatedAt: now
        ),
        Activity(
            id: "2",
            tripId: "trip1",
            creatorId: "user1",
            name: "Beach Visit",
            location: "Coastal Beach",
            startDateTime: now.addingTimeInterval(7200),
            duration: 180, // 3 hours
            category: .relaxation,
            photoURL: nil,
            linkURL: nil,
            createdAt: now,
            updatedAt: now
        ),
        Activity(
            id: "3",
            tripId: "trip1",
            creatorId: "user1",
            name: "Dinner Reservation",
            location: "Fine Restaurant",
            startDateTime: Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now,
            duration: 90, // 1.5 hours
            category: .dining,
            photoURL: nil,
            linkURL: nil,
            createdAt: now,
            updatedAt: now
        )
    ]
    
    return ActivityListView(activities: activities)
}
