//
//  ErrorView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Feedback/ErrorView.swift
import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.jakartaSans(22, weight: .bold))
            
            Text(message)
                .font(.jakartaSans(16))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retry = retryAction {
                Button("Try Again") {
                    retry()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppConstants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(AppConstants.Layout.cornerRadius / 2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.Layout.cornerRadius)
        .shadow(radius: 2)
    }
}

#Preview {
    ErrorView(
        message: "Unable to load trips. Please check your internet connection.",
        retryAction: { print("Retry tapped") }
    )
    .padding()
}
