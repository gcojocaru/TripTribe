// TripTribeCore/Sources/TripTribeCore/Repositories/AuthRepositoryProtocol.swift
import Foundation
import Combine

public protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, displayName: String) async throws -> User
    func signOut() throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
    func updateUserProfile(user: User) async throws
    func updateUserPhoto(uid: String, photoData: Data) async throws -> URL
    func fetchUserData(uid: String) async throws -> User
    func observeAuthChanges() -> AnyPublisher<FirebaseUser?, Never>
}

// TripTribeCore/Sources/TripTribeCore/Repositories/TripRepositoryProtocol.swift
import Foundation

public protocol TripRepositoryProtocol {
    func createTrip(_ trip: Trip) async throws -> String
    func getTrip(id: String) async throws -> Trip
    func updateTrip(_ trip: Trip) async throws
    func deleteTrip(id: String) async throws
    func getUserTrips(userId: String) async throws -> [Trip]
    func getPendingInvitations(email: String) async throws -> [Trip]
    func inviteToTrip(tripId: String, invitation: Invitation) async throws
    func updateInvitation(tripId: String, invitationId: String, status: Invitation.InvitationStatus) async throws
}

// TripTribeCore/Sources/TripTribeCore/Repositories/ActivityRepositoryProtocol.swift
import Foundation

public protocol ActivityRepositoryProtocol {
    func createActivity(_ activity: Activity) async throws -> String
    func getActivity(id: String) async throws -> Activity
    func updateActivity(_ activity: Activity) async throws
    func deleteActivity(id: String) async throws
    func getActivities(for tripId: String) async throws -> [Activity]
}
