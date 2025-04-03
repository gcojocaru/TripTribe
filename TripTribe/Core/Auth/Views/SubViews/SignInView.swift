//
//  SignInView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    @State private var isShowingForgotPassword = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Form fields
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
            
            // Error message
            if let error = authViewModel.authError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            // Forgot password
            HStack {
                Spacer()
                Button {
                    isShowingForgotPassword = true
                } label: {
                    Text("Forgot password?")
                        .font(.jakartaSans(14))
                        .foregroundColor(.gray)
                }
            }
            
            // Sign in button
            Button {
                Task {
                    await authViewModel.signIn()
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
                    Text("Log In")
                        .font(.jakartaSans(16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppConstants.Colors.primary)
                        .cornerRadius(28)
                }
            }
            .disabled(authViewModel.isProcessing)
            .padding(.top, 10)
            
            // Sign up button
            Button {
                withAnimation {
                    isShowingSignUp = true
                }
            } label: {
                Text("Sign Up")
                    .font(.jakartaSans(16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppConstants.Colors.secondary)
                    .cornerRadius(28)
            }
        }
        .alert("Reset Password", isPresented: $isShowingForgotPassword) {
            TextField("Email", text: $authViewModel.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button("Cancel", role: .cancel) { }
            Button("Send Reset Link") {
                Task {
                    await authViewModel.resetPassword()
                }
            }
        } message: {
            Text("Please enter your email address to reset your password.")
        }
    }
}
