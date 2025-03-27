//
//  DescriptionFieldView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct DescriptionFieldView: View {
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextField(
                    "free_form",
                    text: $description,
                    prompt: Text("Add description(optional)"),
                    axis: .vertical
                )
                .lineSpacing(10.0)
                .lineLimit(10...)
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
