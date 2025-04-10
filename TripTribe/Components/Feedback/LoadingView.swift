//
//  LoadingView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Feedback/LoadingView.swift
import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text(message)
                .font(.jakartaSans(16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoadingView()
}
