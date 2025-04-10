//
//  IconButton.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import SwiftUI

struct IconButton: View {
    let icon: String
    let action: () -> Void
    var color: Color = AppConstants.Colors.primary
    var size: CGFloat = 24
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
                .frame(width: size * 2, height: size * 2)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        IconButton(icon: "plus", action: {})
        IconButton(icon: "arrow.left", action: {}, color: .blue)
        IconButton(icon: "trash", action: {}, color: .red, size: 18)
    }
    .padding()
}
