//
//  HeaderImageView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct HeaderImageView: View {
    var body: some View {
        Image("friends_planning")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 320)
            .clipped()
    }
}
