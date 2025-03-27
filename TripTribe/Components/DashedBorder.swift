//
//  DashedBorder.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct DashedBorder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
            .foregroundColor(Color.gray.opacity(0.3))
    }
}
