//
//  ContentContainer.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Layout/ContentContainer.swift
import SwiftUI

struct ContentContainer<Content: View>: View {
    var verticalPadding: CGFloat = 16
    var horizontalPadding: CGFloat = 20
    var backgroundColor: Color = Color(.systemBackground)
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundColor)
    }
}

#Preview {
    ContentContainer {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sample Content")
                .font(.jakartaSans(24, weight: .bold))
            
            Text("This is some text inside the container")
            
            Divider()
            
            Text("More content below")
        }
    }
}
