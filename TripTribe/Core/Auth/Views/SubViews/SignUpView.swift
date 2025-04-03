//
//  SignUpView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Form fields
            TextField("Name", text: $authViewModel.displayName)
                .autocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            TextField("Email", text: $authViewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            SecureField("Password", text: $authViewModel.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            // Error message
            if let error = authViewModel.authError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            // Sign up button
            Button {
                Task {
                    await authViewModel.signUp()
                }
            } label: {
                if authViewModel.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppConstants.Colors.primary)
                        .cornerRadius(28)
                } else {
                    Text("Create Account")
                        .font(.jakartaSans(22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppConstants.Colors.primary)
                        .cornerRadius(28)
                }
            }
            .disabled(authViewModel.isProcessing)
            .padding(.top, 10)
            
            // Back to sign in
            Button {
                withAnimation {
                    isShowingSignUp = false
                }
            } label: {
                Text("Back to Login")
                    .font(.jakartaSans(16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppConstants.Colors.secondary)
                    .cornerRadius(28)
            }
        }
    }
}
