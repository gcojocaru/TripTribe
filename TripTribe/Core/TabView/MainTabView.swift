//
//  MainTabView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        Text("Home")
                    }
                }
                .tag(0)
            
            TripsView()
                .tabItem {
                    VStack {
                        Image(systemName: "airplane")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                        Text("Trips")
                    }
                }
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
    }
}

// HomeView.swift (placeholder)
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Home Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .navigationTitle("Home")
        }
    }
}

// TripsView.swift (placeholder)
struct TripsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Trips Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .navigationTitle("Trips")
        }
    }
}

// ProfileView.swift (placeholder)
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
            .navigationTitle("Profile")
        }
    }
}
