//
//  AddTripButton.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct AddTripButton: View {
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            Text("Add Your First Trip")
                .font(.jakartaSans(14, weight: .bold))
                .foregroundColor(.black)
                .padding(.vertical, 14)
                .padding(.horizontal, 32)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(30)
        }
        .padding(.top, 8)
    }
}
