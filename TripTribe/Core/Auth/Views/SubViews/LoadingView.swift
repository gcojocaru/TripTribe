//
//  LoadingView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            AppConstants.Colors.background.edgesIgnoringSafeArea(.all)
            
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
