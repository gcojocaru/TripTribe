//
//  NewTripViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//


import SwiftUI
import Combine
import Firebase
import FirebaseAuth


@MainActor
class NewTripViewModel: ObservableObject {
    // Trip details
    @Published var tripName: String = ""
    @Published var destination: String = ""
    @Published var description: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(86400 * 7) // 1 week
    
    // Step management
    @Published var currentStep: Int = 1
    @Published var totalSteps: Int = 2
    
    // Invite friends
    @Published var invitedEmails: [String] = []
    @Published var isProcessingInvites: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var errorMessage: String?
    
    // Trip creation state
    @Published var isCreatingTrip: Bool = false
    @Published var createdTrip: Trip?
    
    private var onDismiss: () -> Void
    private let tripRepository: TripRepositoryProtocol
    
    init(onDismiss: @escaping () -> Void, tripRepository: TripRepositoryProtocol = AppDependencies.shared.tripRepository) {
        self.onDismiss = onDismiss
        self.tripRepository = tripRepository
    }
    
    func dismissView() {
        onDismiss()
    }
    
    func continueToNextStep() {
        // Validate the first step
        if validateFirstStep() {
            Task {
                await createTripInFirebase()
            }
        }
    }
    
    private func validateFirstStep() -> Bool {
        // Basic validation for required fields
        guard !tripName.isEmpty else {
            errorMessage = "Please enter a trip name"
            return false
        }
        
        guard !destination.isEmpty else {
            errorMessage = "Please enter a destination"
            return false
        }
        
        guard endDate > startDate else {
            errorMessage = "End date must be after start date"
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    // MARK: - Firebase Trip Creation
    
    private func createTripInFirebase() async {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to create a trip"
            return
        }
        
        isCreatingTrip = true
        
        do {
            // Create trip in Firebase
            let trip = try await tripRepository.createTrip(
                name: tripName,
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                description: description,
                userId: userId
            )
            
            // Store the created trip
            createdTrip = trip
            
            // Move to next step
            withAnimation {
                currentStep = 2
            }
        } catch {
            errorMessage = "Failed to create trip: \(error.localizedDescription)"
        }
        
        isCreatingTrip = false
    }
    
    // MARK: - Invite Friends Methods
    
    func addInvitedEmail(_ email: String) {
        if !invitedEmails.contains(email) {
            invitedEmails.append(email)
        }
    }
    
    func removeInvitedEmail(_ email: String) {
        invitedEmails.removeAll { $0 == email }
    }
    
    func sendInvites(withMessage message: String) {
        guard let trip = createdTrip else {
            errorMessage = "Trip not created yet"
            return
        }
        
        // Ensure there are emails to invite
        guard !invitedEmails.isEmpty else {
            finalizeTripCreation()
            return
        }
        
        isProcessingInvites = true
        
        Task {
            do {
                // Send invites through Firebase
                try await tripRepository.inviteFriendsToTrip(
                    tripId: trip.id,
                    emails: invitedEmails,
                    message: message.isEmpty ? nil : message
                )
                
                // Show success alert
                isProcessingInvites = false
                showSuccessAlert = true
                
                // After showing success, dismiss the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.finalizeTripCreation()
                }
            } catch {
                isProcessingInvites = false
                errorMessage = "Failed to send invites: \(error.localizedDescription)"
            }
        }
    }
    
    func finalizeTripCreation() {
        // Trip has been created and invites sent (if any)
        // Now dismiss the view
        onDismiss()
    }
}
