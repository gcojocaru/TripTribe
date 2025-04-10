//
//  StandardTextField.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Inputs/StandardTextField.swift
import SwiftUI

struct StandardTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var autocapitalization: TextInputAutocapitalization = .sentences
    var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !label.isEmpty {
                Text(label)
                    .font(.jakartaSans(14, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.jakartaSans(16, weight: .regular))
            .keyboardType(keyboardType)
            .autocapitalization(UITextAutocapitalizationType.words)
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.jakartaSans(12, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StandardTextField(
            label: "Email",
            placeholder: "Enter your email",
            text: .constant("user@example.com"),
            keyboardType: .emailAddress,
            autocapitalization: .never
        )
        
        StandardTextField(
            label: "Password",
            placeholder: "Enter your password",
            text: .constant(""),
            isSecure: true,
            errorMessage: "Password is required"
        )
    }
    .padding()
}
