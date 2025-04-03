//
//  AppRouter.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Core/Navigation/AppRouter.swift
import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            switch coordinator.authState {
            case .checking:
                LoadingView()
                    .onAppear {
                        checkAuthState()
                    }
                
            case .authenticated:
                MainTabView()
                
            case .unauthenticated:
                AuthenticationView()
            }
        }
    }
    
    private func checkAuthState() {
        // Check if user is logged in
        if authViewModel.isAuthenticated {
            coordinator.authState = .authenticated
        } else {
            coordinator.authState = .unauthenticated
        }
    }
}

// MainTabView using the coordinator
struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.currentTab) {
            NavigationTabView(rootView: HomeView())
                .tabItem {
                    Label("Home", systemImage: coordinator.currentTab == .home ? "house.fill" : "house")
                }
                .tag(AppCoordinator.Tab.home)
            
            NavigationTabView(rootView: TripsView())
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
                .tag(AppCoordinator.Tab.trips)
            
            NavigationTabView(rootView: ProfileView())
                .tabItem {
                    Label("Profile", systemImage: coordinator.currentTab == .profile ? "person.fill" : "person")
                }
                .tag(AppCoordinator.Tab.profile)
        }
    }
}

// Reusable navigation container for all tabs
struct NavigationTabView<RootView: View>: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let rootView: RootView
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            rootView
                .navigationDestination(for: AppCoordinator.Destination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppCoordinator.Destination) -> some View {
        switch destination {
        case .tripDetail(let trip):
            TripDetailView(trip: trip)
        case .addTrip:
            NewTripView(
                viewModel: NewTripViewModel(
                    onDismiss: { coordinator.navigateBack() }
                )
            )
        case .tripActivities(let tripId):
            TripActivitiesView(tripId: tripId)
        case .activityDetail(let activity):
            ActivityDetailView(activity: activity)
        case .addActivity(let tripId):
            AddActivityView(tripId: tripId)
        }
    }
}
