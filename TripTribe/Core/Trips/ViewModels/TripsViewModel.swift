//
//  TripsViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class TripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var invitations: [Trip] = []
    
    private let tripRepository: TripRepositoryProtocol
    
    init(tripRepository: TripRepositoryProtocol = FirebaseTripRepository()) {
        self.tripRepository = tripRepository
    }
    
    func fetchUserTrips() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            trips = try await tripRepository.getUserTrips(userId: userId)
        } catch {
            errorMessage = "Error fetching trips: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchInvitations() async {
        guard let email = Auth.auth().currentUser?.email else {
            return
        }
        
        do {
            invitations = try await tripRepository.getInvitations(forEmail: email)
        } catch {
            print("Error fetching invitations: \(error.localizedDescription)")
        }
    }
    
    func respondToInvitation(tripId: String, invitationId: String, accept: Bool) async {
        do {
            try await tripRepository.respondToInvitation(tripId: tripId, invitationId: invitationId, accept: accept)
            
            // Update the local state
            if accept {
                // Remove from invitations and fetch updated trips
                invitations.removeAll { $0.id == tripId }
                await fetchUserTrips()
            } else {
                // Just remove from invitations
                invitations.removeAll { $0.id == tripId }
            }
        } catch {
            errorMessage = "Error responding to invitation: \(error.localizedDescription)"
        }
    }
    
    func refreshData() async {
        await fetchUserTrips()
        await fetchInvitations()
    }
    
    func deleteTrip(id: String) async {
        isLoading = true
        
        do {
            try await tripRepository.deleteTrip(id: id)
            trips.removeAll { $0.id == id }
        } catch {
            errorMessage = "Error deleting trip: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // Convenience methods for UI
    
    var hasTrips: Bool {
        !trips.isEmpty
    }
    
    var hasInvitations: Bool {
        !invitations.isEmpty
    }
    
    var upcomingTrips: [Trip] {
        let now = Date()
        return trips.filter { $0.endDate >= now }
            .sorted { $0.startDate < $1.startDate }
    }
    
    var pastTrips: [Trip] {
        let now = Date()
        return trips.filter { $0.endDate < now }
            .sorted { $0.startDate > $1.startDate }
    }
}
