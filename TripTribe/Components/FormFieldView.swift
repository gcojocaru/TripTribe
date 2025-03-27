//
//  FormFieldView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct FormFieldView: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.jakartaSans(14, weight: .medium))
                .foregroundColor(.black)
            
            TextField(placeholder, text: $text)
                .font(.jakartaSans(16, weight: .regular))
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}
