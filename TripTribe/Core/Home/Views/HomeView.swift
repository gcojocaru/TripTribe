//
//  HomeView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct HomeView<ViewModel: HomeViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @State var authUsername: String = "Traveler"
    
    var body: some View {
        NavigationView {
            EmptyHomeView(username: authUsername) {
                viewModel.addTrip()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: Binding<Bool>(
                get: { viewModel.isShowingNewTripView },
                set: { newValue in
                    viewModel.isShowingNewTripView = newValue
                }
            )) {
                NewTripView(viewModel: NewTripViewModel(onDismiss: {viewModel.isShowingNewTripView = false}))
            }
        }
    }
}
