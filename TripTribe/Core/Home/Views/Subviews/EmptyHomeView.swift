//
//  EmptyHomeView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct EmptyHomeView: View {
    var username: String
    var onAddTripTap: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HeaderImageView()
                WelcomeMessageView(username: username)
                EmptyStateView(
                    icon: "plus",
                    title: "Add trip",
                    message: "Tap to add your first trip",
                    buttonTitle: "Add",
                    action: onAddTripTap
                )
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(AppConstants.Colors.background)
    }
}
