//
//  HomeViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import Combine

protocol HomeViewModel: ObservableObject {
    var isShowingNewTripView: Bool { get set }
    func addTrip()
}

class HomeViewModelImpl: HomeViewModel {
    @Published var isShowingNewTripView: Bool = false
    
    func addTrip() {
        print("Add trip")
        isShowingNewTripView = true
    }
}

