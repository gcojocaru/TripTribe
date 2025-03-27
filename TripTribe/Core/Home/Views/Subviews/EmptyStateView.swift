//
//  EmptyStateView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct EmptyStateView: View {
    var onAddTripTap: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            EmptyStateContentView(onAddTripTap: onAddTripTap)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
}
