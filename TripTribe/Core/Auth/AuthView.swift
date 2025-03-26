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
                        
                        Text("v0.1.1 | Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)
                    }
                    .padding(.horizontal)
                }
                .animation(.easeInOut, value: showingSignUp)
            }
            .edgesIgnoringSafeArea(.top) 
            .padding(.horizontal)
            .animation(.easeInOut, value: showingSignUp)
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

