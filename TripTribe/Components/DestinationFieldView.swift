//
//  DestinationFieldView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct DestinationFieldView: View {
    @Binding var destination: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Destination")
                .font(.jakartaSans(14, weight: .medium))
                .foregroundColor(.black)
            
            HStack {
                TextField("Search for destination", text: $destination)
                    .font(.jakartaSans(16, weight: .regular))
                    .padding(16)
                
                Button(action: {
                    // Location action
                }) {
                    Image(systemName: "mappin.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .padding(.trailing, 16)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
