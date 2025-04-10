//
//  SecondaryButton.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.jakartaSans(16, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: AppConstants.Layout.buttonHeight)
                .background(isDisabled ? AppConstants.Colors.secondary.opacity(0.5) : AppConstants.Colors.secondary)
                .cornerRadius(AppConstants.Layout.cornerRadius)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        SecondaryButton(title: "Back", action: {})
        SecondaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
