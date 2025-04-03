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
                    Image("auth-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: 370)
                        .clipped()
                        .offset(x: 0, y: -50)
                    
                    VStack(spacing: 24) {
                        Text("Group travel, simplified")
                            .font(.jakartaSans(28, weight: .bold))
                            .padding(.bottom, 10)
                        
                        if showingSignUp {
                            SignUpView(isShowingSignUp: $showingSignUp)
                                .transition(.opacity)
                        } else {
                            SignInView(isShowingSignUp: $showingSignUp)
                                .transition(.opacity)
                        }
                        
                        Text("v0.2.1 | Privacy Policy")
                            .font(.jakartaSans(14, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                            .padding(.bottom, 10)
                    }
                    .offset(x: 0, y: -50)
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

#Preview {
    AuthenticationView()
}
