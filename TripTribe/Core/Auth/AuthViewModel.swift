//
//  AuthViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // User state
    @Published var user: User?
    @Published var isLoading = true
    
    // Login form state
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    
    // UI state
    @Published var authError: String?
    @Published var isProcessing = false
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, firebaseUser) in
            guard let self = self else { return }
            
            self.isLoading = true
            
            if let firebaseUser = firebaseUser {
                Task {
                    await self.fetchUserData(uid: firebaseUser.uid)
                }
            } else {
                self.user = nil
                self.isLoading = false
            }
        }
    }
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            authError = "Please fill in all fields"
            return
        }
        
        isProcessing = true
        authError = nil
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            await fetchUserData(uid: authResult.user.uid)
            isProcessing = false
        } catch {
            handleAuthError(error)
            isProcessing = false
        }
    }
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            authError = "Please fill in all fields"
            return
        }
        
        guard password == confirmPassword else {
            authError = "Passwords don't match"
            return
        }
        
        isProcessing = true
        authError = nil
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
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
            
            self.user = newUser
            isProcessing = false
            clearFields()
        } catch {
            handleAuthError(error)
            isProcessing = false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            authError = "Error signing out"
        }
    }
    
    func fetchUserData(uid: String) async {
        do {
            let documentSnapshot = try await db.collection("users").document(uid).getDocument()
            
            if let user = User(from: documentSnapshot) {
                self.user = user
            } else {
                // User document not found but Firebase Auth has a user
                // This could happen if Firestore document creation failed during signup
                let firebaseUser = Auth.auth().currentUser!
                
                let newUser = User(
                    uid: firebaseUser.uid,
                    displayName: firebaseUser.displayName ?? "User",
                    email: firebaseUser.email ?? "",
                    photoURL: firebaseUser.photoURL?.absoluteString,
                    phoneNumber: firebaseUser.phoneNumber,
                    createdAt: Date()
                )
                
                try await db.collection("users").document(newUser.uid).setData(newUser.asDictionary)
                self.user = newUser
            }
            
            self.isLoading = false
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    func signInWithApple() {
        // Implement Apple Sign In
        authError = "Apple Sign In not implemented yet"
    }
    
    func signInWithGoogle() {
        // Implement Google Sign In
        authError = "Google Sign In not implemented yet"
    }
    
    func resetPassword() async {
        guard !email.isEmpty else {
            authError = "Please enter your email address"
            return
        }
        
        isProcessing = true
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            authError = "Password reset email sent"
            isProcessing = false
        } catch {
            handleAuthError(error)
            isProcessing = false
        }
    }
    
    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError
        let errorCode = AuthErrorCode(_bridgedNSError: nsError)
        
        switch errorCode {
        case .invalidEmail:
            authError = "Invalid email address"
        case .wrongPassword:
            authError = "Incorrect password"
        case .userNotFound:
            authError = "No account found with this email"
        case .emailAlreadyInUse:
            authError = "This email is already registered"
        case .weakPassword:
            authError = "Password is too weak"
        case .networkError:
            authError = "Network error. Please try again."
        default:
            authError = "Authentication error: \(error.localizedDescription)"
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
    }
}
