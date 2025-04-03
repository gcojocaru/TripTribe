//
//  TripCardPreview.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct TripCardPreview: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Trip image header
            ZStack(alignment: .bottomLeading) {
                // Destination image from Unsplash
                DestinationImageView(destination: trip.destination, height: 160)
                
                // Gradient overlay for better text readability
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
                
                // Trip info overlay
                VStack(alignment: .leading, spacing: 8) {
                    getTripStatusBadge()
                        .padding(.bottom, 4)
                    
                    Text(trip.name)
                        .font(.jakartaSans(24, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Trip details
            VStack(spacing: 16) {
                // Destination and dates row
                HStack {
                    // Destination
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.gray)
                        
                        Text(trip.destination)
                            .font(.jakartaSans(16, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // Dates
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        
                        Text(formatDateRange(start: trip.startDate, end: trip.endDate))
                            .font(.jakartaSans(16, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                
                // Countdown
                VStack(spacing: 8) {
                    HStack {
                        Text(getCountdownLabel())
                            .font(.jakartaSans(14, weight: .regular))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    
                    getCountdownView()
                }
                
                // View details button
                HStack {
                    Spacer()
                    
                    Text("View Trip Details")
                        .font(.jakartaSans(16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppConstants.Colors.primary.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Helper Views
    
    private func getTripStatusBadge() -> some View {
        let status = getTripStatus()
        
        let text: String
        let color: Color
        
        switch status {
        case .upcoming:
            text = "Upcoming"
            color = Color.blue
        case .ongoing:
            text = "In Progress"
            color = Color.green
        case .completed:
            text = "Completed"
            color = Color.gray
        }
        
        return Text(text)
            .font(.jakartaSans(12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(12)
    }
    
    private func getCountdownView() -> some View {
        let timeComponents = calculateTimeRemaining()
        let status = getTripStatus()
        
        if status == .completed {
            return AnyView(
                Text("Trip has ended")
                    .font(.jakartaSans(16, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            )
        } else {
            return AnyView(
                HStack(spacing: 12) {
                    countdownItem(value: timeComponents.days, label: "DAYS")
                    countdownItem(value: timeComponents.hours, label: "HOURS")
                    countdownItem(value: timeComponents.minutes, label: "MINS")
                }
            )
        }
    }
    
    private func countdownItem(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.jakartaSans(10, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func getTripStatus() -> TripStatus {
        let now = Date()
        
        if now < trip.startDate {
            return .upcoming
        } else if now <= trip.endDate {
            return .ongoing
        } else {
            return .completed
        }
    }
    
    private func getCountdownLabel() -> String {
        switch getTripStatus() {
        case .upcoming:
            return "Time until trip:"
        case .ongoing:
            return "Time remaining:"
        case .completed:
            return "Trip completed on \(formatDate(trip.endDate))"
        }
    }
    
    private func calculateTimeRemaining() -> TimeComponents {
        let now = Date()
        let targetDate: Date
        
        if now < trip.startDate {
            targetDate = trip.startDate
        } else if now <= trip.endDate {
            targetDate = trip.endDate
        } else {
            return TimeComponents()
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: targetDate)
        
        return TimeComponents(
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0,
            seconds: components.second ?? 0
        )
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
