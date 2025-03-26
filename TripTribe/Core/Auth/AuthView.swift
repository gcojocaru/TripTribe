//
//  AuthView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

// AuthenticationView.swift
import SwiftUI

struct AuthenticationView: View {
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header image - place outside padding
                    Image("auth-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width) // Force full screen width
                        .frame(height: 370)
                        .clipped()
                        .offset(x: 0, y: -50)
                    
                    // Content area - apply padding here
                    VStack(spacing: 20) {
                        Text("Group travel, simplified")
                            .font(.system(size: 28, weight: .bold))
                            .padding(.bottom, 10)
                        
                        // Main content
                        if showingSignUp {
                            SignUpView(isShowingSignUp: $showingSignUp)
                                .transition(.opacity)
                        } else {
                            SignInView(isShowingSignUp: $showingSignUp)
                                .transition(.opacity)
                        }
                        
                        // Remove the Spacer() - it doesn't work well in ScrollView
                        
                        Text("v0.1.0 | Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)
                    }
                    .padding(.horizontal)
                }
                .animation(.easeInOut, value: showingSignUp)
            }
            .edgesIgnoringSafeArea(.top) // Move this to the ScrollView
            .padding(.horizontal)
            .animation(.easeInOut, value: showingSignUp)
        }
    }
}

// SignInView.swift
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
                        .font(.footnote)
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
                        .background(Color.black)
                        .cornerRadius(28)
                } else {
                    Text("Log In")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
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
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(.systemGray5))
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

// SignUpView.swift
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
                        .background(Color.black)
                        .cornerRadius(28)
                } else {
                    Text("Create Account")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
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
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(.systemGray5))
                    .cornerRadius(28)
            }
        }
    }
}

// Helper Views
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

// LoadingView.swift
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
        }
    }
}
