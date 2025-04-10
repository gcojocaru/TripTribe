//
//  HomeView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = HomeViewModelImpl(
        tripRepository: AppDependencies.shared.tripRepository
    )
    @State var authUsername: String = "Traveler"
    
    var body: some View {
        SkeletonLoadingView(isLoading: viewModel.isLoading) {
            if let currentTrip = viewModel.currentTrip {
                TripDetailView(trip: currentTrip)
            } else {
                EmptyHomeView(username: authUsername) {
                    coordinator.showAddTrip()
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchCurrentTrip()
            }
        }
    }
}

