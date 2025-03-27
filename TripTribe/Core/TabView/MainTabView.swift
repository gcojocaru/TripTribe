//
//  MainTabView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var tripsViewModel: TripsViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: HomeViewModelImpl(), authUsername: authViewModel.user?.displayName ?? "")
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        Text("Home")
                    }
                }
                .tag(0)
            
            TripsView()
                .onAppear{
                    Task {
                       await tripsViewModel.fetchInvitations()
                    }
                }
                .tabItem {
                    VStack {
                        Image(systemName: "airplane")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                        Text("Trips")
                    }
                }
                .badge(tripsViewModel.invitations.count > 0 ? tripsViewModel.invitations.count : 0)
                .tag(1)
            
            ProfileView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                            .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                        Text("Profile")
                    }
                }
                .tag(2)
        }
        .tint(.black)
        .onAppear {
            // Check for invitations when the app appears
            Task {
                await tripsViewModel.fetchInvitations()
            }
        }
    }
}





