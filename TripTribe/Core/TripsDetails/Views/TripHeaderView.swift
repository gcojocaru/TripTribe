//
//  TripHeaderView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//


import SwiftUI

// This is a replacement for the existing TripHeaderView in TripDetailView.swift
struct TripHeaderView: View {
    let trip: Trip
    let dateRange: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Beach/destination image from Unsplash
            DestinationImageView(destination: trip.destination, height: 220)
            
            // Gradient overlay for better text readability
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            .accessibilityHidden(true)
            
            // Title overlay
            VStack(alignment: .leading, spacing: 8) {
                Text(trip.name)
                    .font(.jakartaSans(28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(dateRange) · \(trip.participants.count) Members")
                    .font(.jakartaSans(16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
