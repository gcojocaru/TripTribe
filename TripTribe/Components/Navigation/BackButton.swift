//
//  BackButton.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Navigation/BackButton.swift
import SwiftUI

struct BackButton: View {
    let action: () -> Void
    var color: Color = .black
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
                .contentShape(Rectangle())
        }
    }
}

#Preview {
    BackButton {
        print("Back button tapped")
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
