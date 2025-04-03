//
//  ProfileView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

// (placeholder)
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .foregroundColor(.white)
                .padding()
                .background(AppConstants.Colors.error)
                .cornerRadius(10)
            }
            .navigationTitle("Profile")
        }
    }
}
