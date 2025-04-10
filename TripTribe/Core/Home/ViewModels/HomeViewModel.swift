//
//  HomeViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth

protocol HomeViewModel: ObservableObject {
    var currentTrip: Trip? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func fetchCurrentTrip() async
    func refreshData() async
}

class HomeViewModelImpl: HomeViewModel {
    @Published var currentTrip: Trip? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let tripRepository: TripRepositoryProtocol
    
    init(tripRepository: TripRepositoryProtocol) {
        self.tripRepository = tripRepository
    }
    
    @MainActor
    func fetchCurrentTrip() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let userTrips = try await tripRepository.getUserTrips(userId: userId)
            
            // Find the nearest trip (upcoming or in progress)
            let now = Date()
            
            // First, try to find a trip that's currently in progress
            if let activeTrip = userTrips.first(where: { $0.startDate <= now && $0.endDate >= now }) {
                currentTrip = activeTrip
            }
            // If no active trip, look for the soonest upcoming trip
            else {
                let upcomingTrips = userTrips.filter { $0.startDate > now }
                currentTrip = upcomingTrips.min { $0.startDate < $1.startDate }
            }
            
        } catch {
            errorMessage = "Error loading trips: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func refreshData() async {
        await fetchCurrentTrip()
    }
}

