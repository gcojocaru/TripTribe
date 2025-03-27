//
//  WelcomeMessageView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct WelcomeMessageView: View {
    let username: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Hi \(username), ready for your first adventure?")
                .font(.jakartaSans(28, weight: .bold))
                .foregroundColor(.black)
                .padding(.bottom, 4)
                .multilineTextAlignment(.center)
            
            Text("Collaborate with your friends and plan your ideal trip together, no matter where you are.")
                .font(.jakartaSans(16, weight: .regular))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}
