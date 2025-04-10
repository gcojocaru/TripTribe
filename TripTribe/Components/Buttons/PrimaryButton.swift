//
//  PrimaryButton.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.jakartaSans(16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Layout.buttonHeight)
            .background(isDisabled ? AppConstants.Colors.primary.opacity(0.5) : AppConstants.Colors.primary)
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
        .disabled(isLoading || isDisabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
