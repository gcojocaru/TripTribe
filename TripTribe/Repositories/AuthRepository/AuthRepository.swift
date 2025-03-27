//
//  AuthRepository.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage 
import Combine

// Protocol that defines all authentication operations
protocol AuthRepositoryProtocol {
    // Basic authentication
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, displayName: String) async throws -> User
    func signOut() throws
    func resetPassword(email: String) async throws
    
    // Social authentication
    func signInWithApple(idToken: String, nonce: String) async throws -> User
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> User
    
    // User data management
    func getCurrentUser() -> FirebaseAuth.User?
    func fetchUserData(uid: String) async throws -> User
    func updateUserProfile(user: User) async throws
    func updateUserPhoto(uid: String, photoData: Data) async throws -> URL
    
    // User deletion
    func deleteAccount() async throws
    
    // Observer
    func observeAuthChanges() -> AnyPublisher<FirebaseAuth.User?, Never>
}

// MARK: - Implementation of AuthRepository
class FirebaseAuthRepository: AuthRepositoryProtocol {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - Basic Authentication
    
    /// Sign in a user with email and password
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    /// - Returns: User model if successful
    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        return try await fetchUserData(uid: authResult.user.uid)
    }
    
    /// Create a new user account
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - displayName: User's display name
    /// - Returns: User model for the created account
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        
        // Create user profile change request to set display name
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        
        // Create user document in Firestore
        let newUser = User(
            uid: authResult.user.uid,
            displayName: displayName,
            email: email,
            photoURL: nil,
            phoneNumber: nil,
            createdAt: Date()
        )
        
        try await db.collection("users").document(newUser.uid).setData(newUser.asDictionary)
        return newUser
    }
    
    /// Sign out the current user
    func signOut() throws {
        try auth.signOut()
    }
    
    /// Send a password reset email
    /// - Parameter email: Email address to send reset link to
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    // MARK: - Social Authentication
    
    /// Sign in with Apple
    /// - Parameters:
    ///   - idToken: The ID token from Apple Sign In
    ///   - nonce: A nonce for authentication
    /// - Returns: User model
    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idToken,
            rawNonce: nonce
        )
        
        return try await signInWithCredential(credential)
    }
    
    /// Sign in with Google
    /// - Parameters:
    ///   - idToken: Google ID token
    ///   - accessToken: Google access token
    /// - Returns: User model
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> User {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        return try await signInWithCredential(credential)
    }
    
    /// Helper method for credential-based sign-ins
    private func signInWithCredential(_ credential: AuthCredential) async throws -> User {
        let authResult = try await auth.signIn(with: credential)
        
        // Check if this is a new user (first time sign-in)
        if authResult.additionalUserInfo?.isNewUser == true {
            // Create user document for new social sign-in users
            let newUser = User(
                uid: authResult.user.uid,
                displayName: authResult.user.displayName ?? "User",
                email: authResult.user.email ?? "",
                photoURL: authResult.user.photoURL?.absoluteString,
                phoneNumber: authResult.user.phoneNumber,
                createdAt: Date()
            )
            
            try await db.collection("users").document(newUser.uid).setData(newUser.asDictionary)
            return newUser
        } else {
            // Existing user - fetch their Firestore data
            return try await fetchUserData(uid: authResult.user.uid)
        }
    }
    
    // MARK: - User Data Management
    
    /// Get the current Firebase user
    /// - Returns: Firebase User object or nil if not signed in
    func getCurrentUser() -> FirebaseAuth.User? {
        return auth.currentUser
    }
    
    /// Fetch user data from Firestore
    /// - Parameter uid: User ID
    /// - Returns: User model
    func fetchUserData(uid: String) async throws -> User {
        let documentSnapshot = try await db.collection("users").document(uid).getDocument()
        
        if let user = User(from: documentSnapshot) {
            return user
        } else {
            // User document not found but Firebase Auth has a user
            // This could happen if Firestore document creation failed during signup
            guard let firebaseUser = auth.currentUser else {
                throw NSError(
                    domain: "AuthRepository",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "User not found"]
                )
            }
            
            let newUser = User(
                uid: firebaseUser.uid,
                displayName: firebaseUser.displayName ?? "User",
                email: firebaseUser.email ?? "",
                photoURL: firebaseUser.photoURL?.absoluteString,
                phoneNumber: firebaseUser.phoneNumber,
                createdAt: Date()
            )
            
            try await db.collection("users").document(newUser.uid).setData(newUser.asDictionary)
            return newUser
        }
    }
    
    /// Update a user's profile
    /// - Parameter user: Updated user model
    func updateUserProfile(user: User) async throws {
        // Update Firestore document
        try await db.collection("users").document(user.uid).updateData([
            "displayName": user.displayName,
            "phoneNumber": user.phoneNumber ?? "",
            // Only update fields that users should be able to change
        ])
        
        // Update Firebase Auth profile if needed
        if let currentUser = auth.currentUser, currentUser.displayName != user.displayName {
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.displayName = user.displayName
            try await changeRequest.commitChanges()
        }
    }
    
    /// Upload and update user profile photo
    /// - Parameters:
    ///   - uid: User ID
    ///   - photoData: Image data to upload
    /// - Returns: URL of the uploaded image
    func updateUserPhoto(uid: String, photoData: Data) async throws -> URL {
        // Create a storage reference
        let storageRef = storage.reference().child("user_photos/\(uid)/profile.jpg")
        
        // Upload the photo data
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(photoData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        // Update user's photoURL in Firestore
        try await db.collection("users").document(uid).updateData([
            "photoURL": downloadURL.absoluteString
        ])
        
        // Update Firebase Auth profile
        if let currentUser = auth.currentUser {
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.photoURL = downloadURL
            try await changeRequest.commitChanges()
        }
        
        return downloadURL
    }
    
    // MARK: - Account Management
    
    /// Delete the current user's account
    func deleteAccount() async throws {
        guard let currentUser = auth.currentUser else {
            throw NSError(
                domain: "AuthRepository",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"]
            )
        }
        
        // Delete user document from Firestore
        try await db.collection("users").document(currentUser.uid).delete()
        
        // Delete user's profile photo if it exists
        let storageRef = storage.reference().child("user_photos/\(currentUser.uid)/profile.jpg")
        try? await storageRef.delete()
        
        // Delete the Firebase Auth user
        try await currentUser.delete()
    }
    
    // MARK: - Auth State Observer
    
    /// Observe authentication state changes
    /// - Returns: Publisher that emits the current Firebase user or nil when signed out
    func observeAuthChanges() -> AnyPublisher<FirebaseAuth.User?, Never> {
        // Create a subject that will publish auth state changes
        let authStateSubject = PassthroughSubject<FirebaseAuth.User?, Never>()
        
        // Add the Firebase auth state listener and forward events to our subject
        let handle = auth.addStateDidChangeListener { _, user in
            authStateSubject.send(user)
        }
        
        // Return a publisher that cleans up the listener when all subscribers are gone
        return authStateSubject
            .handleEvents(receiveCancel: {
                self.auth.removeStateDidChangeListener(handle)
            })
            .eraseToAnyPublisher()
    }
}
