//
//  ViewModifiers.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI

// Standard text field style
struct StandardTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

// Primary button style
struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppConstants.Colors.primary)
            .cornerRadius(28)
    }
}

// Secondary button style
struct SecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppConstants.Colors.secondary)
            .cornerRadius(28)
    }
}

// Extension to make these modifiers easier to use
extension View {
    func standardTextFieldStyle() -> some View {
        modifier(StandardTextFieldModifier())
    }
    
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonModifier())
    }
    
    func secondaryButtonStyle() -> some View {
        modifier(SecondaryButtonModifier())
    }
}
