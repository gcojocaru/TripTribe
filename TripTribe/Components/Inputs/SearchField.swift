//
//  SearchField.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Inputs/SearchField.swift
import SwiftUI

struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var onSubmit: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            TextField(placeholder, text: $text)
                .font(.jakartaSans(16))
                .padding(.vertical, 10)
                .onSubmit {
                    onSubmit?()
                }
            
            if !text.isEmpty {
                IconButton(icon: "xmark.circle.fill") {
                    text = ""
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    SearchField(text: .constant(""))
        .padding()
}
