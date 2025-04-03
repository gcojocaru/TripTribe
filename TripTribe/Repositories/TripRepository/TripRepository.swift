//
//  TripRepository.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine

protocol TripRepositoryProtocol {
    // Trip operations
    func createTrip(name: String, destination: String, startDate: Date, endDate: Date, description: String?, userId: String) async throws -> Trip
    func getTrip(id: String) async throws -> Trip
    func getUserTrips(userId: String) async throws -> [Trip]
    func updateTrip(trip: Trip) async throws
    func deleteTrip(id: String) async throws
    
    // Invitation operations
    func inviteFriendsToTrip(tripId: String, emails: [String], message: String?) async throws
    func respondToInvitation(tripId: String, invitationId: String, accept: Bool) async throws
    func getInvitations(forEmail email: String) async throws -> [Trip]
    func cancelInvitation(tripId: String, invitationId: String) async throws
}

class FirebaseTripRepository: TripRepositoryProtocol {
    private let db: Firestore
    
    
        init() {
           // Configure Firestore settings
           let settings = FirestoreSettings()
           
           // Set cache size to unlimited for better offline support
           settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
           
           // Apply settings to default instance (must be done before first access)
           Firestore.firestore().settings = settings
           
           // Store reference to configured instance
           db = Firestore.firestore()
       }
    
    // MARK: - Trip Operations
    
    /// Create a new trip in Firestore
    func createTrip(name: String, destination: String, startDate: Date, endDate: Date, description: String?, userId: String) async throws -> Trip {
        // Generate a new ID for the trip
        let tripRef = db.collection("trips").document()
        let tripId = tripRef.documentID
        
        // Create the creator participant
        let creator = Participant(
            userId: userId,
            role: .creator,
            joinedAt: Date()
        )
        
        // Create the trip object
        let newTrip = Trip(
            id: tripId,
            creatorId: userId,
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            description: description,
            participants: [creator],
            invitations: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Save to Firestore
        try await tripRef.setData(newTrip.asDictionary)
        
        // Also add this trip to the user's trips collection for easier querying
        try await db.collection("users").document(userId).collection("trips").document(tripId).setData([
            "tripId": tripId,
            "role": Participant.ParticipantRole.creator.rawValue,
            "createdAt": Timestamp(date: Date())
        ])
        
        return newTrip
    }
    
    /// Retrieve a trip by its ID
    func getTrip(id: String) async throws -> Trip {
        let document = try await db.collection("trips").document(id).getDocument()
        
        guard let trip = Trip.fromFirestore(document: document) else {
            throw NSError(
                domain: "TripRepository",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Trip not found"]
            )
        }
        
        return trip
    }
    
    /// Get all trips that a user is part of
    func getUserTrips(userId: String) async throws -> [Trip] {
        // Query the user's trips subcollection which has references to all trips they're in
        let userTripsSnapshot = try await db.collection("users").document(userId).collection("trips").getDocuments()
        
        var trips: [Trip] = []
        
        // For each trip reference, get the actual trip data
        for document in userTripsSnapshot.documents {
            guard let tripId = document.data()["tripId"] as? String else { continue }
            
            do {
                let trip = try await getTrip(id: tripId)
                trips.append(trip)
            } catch {
                print("Failed to load trip \(tripId): \(error.localizedDescription)")
                // Continue to the next trip rather than failing the entire function
            }
        }
        
        // Sort by start date, most recent first
        return trips.sorted { $0.startDate > $1.startDate }
    }
    
    /// Update an existing trip
    func updateTrip(trip: Trip) async throws {
        // Update the timestamp
        var updatedTrip = trip
        updatedTrip.updatedAt = Date()
        
        // Update in Firestore
        try await db.collection("trips").document(trip.id).updateData(updatedTrip.asDictionary)
    }
    
    /// Delete a trip
    func deleteTrip(id: String) async throws {
        // First, get the trip to find all participants
        let trip = try await getTrip(id: id)
        
        // Delete the trip from each participant's trips subcollection
        for participant in trip.participants {
            try await db.collection("users").document(participant.userId).collection("trips").document(id).delete()
        }
        
        // Finally, delete the main trip document
        try await db.collection("trips").document(id).delete()
    }
    
    // MARK: - Invitation Operations
    
    /// Invite friends to a trip
    func inviteFriendsToTrip(tripId: String, emails: [String], message: String?) async throws {
        // Get the current trip
        var trip = try await getTrip(id: tripId)
        
        // Create new invitations
        let now = Date()
        let newInvitations = emails.map { email -> Invitation in
            // Check if this email is already invited
            if trip.invitations.contains(where: { $0.email.lowercased() == email.lowercased() }) {
                // If so, update the existing invitation with new date and pending status
                if let index = trip.invitations.firstIndex(where: { $0.email.lowercased() == email.lowercased() }) {
                    var existingInvitation = trip.invitations[index]
                    existingInvitation.status = .pending
                    existingInvitation.updatedAt = now
                    return existingInvitation
                }
            }
            
            // Otherwise create a new invitation
            return Invitation(
                id: UUID().uuidString,
                email: email.lowercased(),
                status: .pending,
                message: message,
                createdAt: now,
                updatedAt: now
            )
        }
        
        // Remove any existing invitations for these emails
        trip.invitations.removeAll { invitation in
            emails.contains { $0.lowercased() == invitation.email.lowercased() }
        }
        
        // Add the new invitations
        trip.invitations.append(contentsOf: newInvitations)
        trip.updatedAt = now
        
        // Update the trip in Firestore
        try await updateTrip(trip: trip)
        
        // In a real app, you would also send email invitations here
        // For now, we'll just save the invitations to Firestore
    }
    
    /// Respond to a trip invitation (accept or decline)
    func respondToInvitation(tripId: String, invitationId: String, accept: Bool) async throws {
        // Get the current trip
        var trip = try await getTrip(id: tripId)
        
        // Find the invitation
        guard let invitationIndex = trip.invitations.firstIndex(where: { $0.id == invitationId }) else {
            throw NSError(
                domain: "TripRepository",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Invitation not found"]
            )
        }
        
        let invitation = trip.invitations[invitationIndex]
        
        // Update invitation status
        var updatedInvitation = invitation
        updatedInvitation.status = accept ? .accepted : .declined
        updatedInvitation.updatedAt = Date()
        trip.invitations[invitationIndex] = updatedInvitation
        
        // If accepting, add the user as a participant
        if accept {
            // Check if a user with this email already exists
            let userQuery = try await db.collection("users")
                .whereField("email", isEqualTo: invitation.email.lowercased())
                .getDocuments()
            
            if let userDoc = userQuery.documents.first, let userData = userDoc.data() as [String: Any]? {
                if let userId = userData["uid"] as? String {
                    // Only add if the user isn't already a participant
                    if !trip.participants.contains(where: { $0.userId == userId }) {
                        let newParticipant = Participant(
                            userId: userId,
                            role: .member,
                            joinedAt: Date()
                        )
                        trip.participants.append(newParticipant)
                        
                        // Also add to the user's trips collection
                        try await db.collection("users").document(userId).collection("trips").document(tripId).setData([
                            "tripId": tripId,
                            "role": Participant.ParticipantRole.member.rawValue,
                            "createdAt": Timestamp(date: Date())
                        ])
                    }
                }
            }
        }
        
        // Update the trip
        trip.updatedAt = Date()
        try await updateTrip(trip: trip)
    }
    
    /// Get trips for which a user has pending invitations
    func getInvitations(forEmail email: String) async throws -> [Trip] {
        let lowercasedEmail = email.lowercased()
        
        // First, get all trips
        let tripsSnapshot = try await db.collection("trips").getDocuments()
        
        // Then filter them in memory to find pending invitations for this email
        let trips = tripsSnapshot.documents.compactMap { Trip.fromFirestore(document: $0) }
        
        // Filter to only include trips with pending invitations for this email
        return trips.filter { trip in
            trip.invitations.contains { invitation in
                invitation.email.lowercased() == lowercasedEmail &&
                invitation.status == .pending
            }
        }
    }
    
    /// Cancel an invitation
    func cancelInvitation(tripId: String, invitationId: String) async throws {
        // Get the current trip
        var trip = try await getTrip(id: tripId)
        
        // Remove the invitation
        trip.invitations.removeAll { $0.id == invitationId }
        trip.updatedAt = Date()
        
        // Update in Firestore
        try await updateTrip(trip: trip)
    }
}
