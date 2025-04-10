
//
//  Untitled.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Components/Layout/SectionHeader.swift
import SwiftUI

struct SectionHeader: View {
    let title: String
    var showSeeAll: Bool = false
    var seeAllAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .font(.jakartaSans(20, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
            
            if showSeeAll {
                PrimaryButton(title: "See All", action: {
                    seeAllAction?()
                }) 
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(alignment: .leading) {
        SectionHeader(title: "Upcoming Trips")
        SectionHeader(title: "Popular Destinations", showSeeAll: true) {
            print("See all tapped")
        }
    }
    .padding()
}
