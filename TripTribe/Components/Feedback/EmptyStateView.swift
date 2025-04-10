//
//  EmptyStateView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Feedback/EmptyStateView.swift
import SwiftUI

struct EmptyStateView<Content: View>: View {
    let icon: String
    let title: String
    let message: String
    @ViewBuilder let actionContent: Content
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.6))
            
            Text(title)
                .font(.jakartaSans(22, weight: .bold))
                .foregroundColor(.primary)
            
            Text(message)
                .font(.jakartaSans(16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            actionContent
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Convenience initializer with a simple button
extension EmptyStateView where Content == PrimaryButton {
    init(
        icon: String,
        title: String,
        message: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionContent = PrimaryButton(title: buttonTitle, action: action)
    }
}

#Preview {
    EmptyStateView(
        icon: "airplane.circle",
        title: "No Trips Yet",
        message: "Start planning your journey with friends.",
        buttonTitle: "Create Trip"
    ) {
        print("Button tapped")
    }
}
