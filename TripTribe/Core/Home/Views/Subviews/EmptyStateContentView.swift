//
//  EmptyStateContentView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct EmptyStateContentView: View {
    var onAddTripTap: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Text("No trips yet")
                .font(.jakartaSans(18, weight: .bold))
                .foregroundColor(.black)
            
            Text("Start planning your journey with your friends.")
                .font(.jakartaSans(14, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            AddTripButton(onTap: onAddTripTap)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .overlay(
            DashedBorder()
        )
    }
}
