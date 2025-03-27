//
//  ProgressDotsView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct ProgressDotsView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.black : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
