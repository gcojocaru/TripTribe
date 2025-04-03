//
//  AuthViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import Foundation
import Firebase
import FirebaseAuth
import Combine
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // User state
    @Published var user: User?
    @Published var isLoading = true
    
    // Form state
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName = ""
    @Published var phoneNumber = ""
    
    // UI state
    @Published var authError: String?
    @Published var isProcessing = false
    @Published var successMessage: String?
    
    // MARK: - Private Properties
    private let authRepository: AuthRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Initialization
    
    init(authRepository: AuthRepositoryProtocol = AppDependencies.shared.authRepository) {
        self.authRepository = authRepository
        setupAuthStateListener()
    }
    
    // Convenience initializer with default implementation
    convenience init() {
        self.init(authRepository: FirebaseAuthRepository())
    }
    
    // MARK: - Auth State Observation
    
    private func setupAuthStateListener() {
        authRepository.observeAuthChanges()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUser in
                guard let self = self else { return }
                
                if let firebaseUser = firebaseUser {
                    Task {
                        await self.fetchUserData(uid: firebaseUser.uid)
                    }
                } else {
                    self.user = nil
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in with email and password
    func signIn() async {
        guard validateSignInForm() else { return }
        
        setProcessingState(true)
        
        do {
            user = try await authRepository.signIn(email: email, password: password)
            clearFields()
        } catch {
            handleAuthError(error)
        }
        
        setProcessingState(false)
    }
    
    /// Create a new account
    func signUp() async {
        guard validateSignUpForm() else { return }
        
        setProcessingState(true)
        
        do {
            user = try await authRepository.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
            clearFields()
        } catch {
            handleAuthError(error)
        }
        
        setProcessingState(false)
    }
    
    /// Sign out the current user
    func signOut() {
        authError = nil
        successMessage = nil
        
        do {
            try authRepository.signOut()
            user = nil
        } catch {
            authError = "Error signing out: \(error.localizedDescription)"
        }
    }
    
    /// Send password reset email
    func resetPassword() async {
        guard validateEmailForReset() else { return }
        
        setProcessingState(true)
        
        do {
            try await authRepository.resetPassword(email: email)
            successMessage = "Password reset email sent to \(email)"
        } catch {
            handleAuthError(error)
        }
        
        setProcessingState(false)
    }
    
    // MARK: - Social Authentication
    
    /// Sign in with Apple
    func signInWithApple() async {
        // This would require implementing the Apple Sign In flow
        // and getting the id token and nonce
        authError = "Apple Sign In not implemented yet"
        
        // Example implementation skeleton:
        /*
        setProcessingState(true)
        
        do {
            // Get idToken and nonce from Apple Sign In
            let (idToken, nonce) = try await getAppleSignInCredentials()
            user = try await authRepository.signInWithApple(idToken: idToken, nonce: nonce)
        } catch {
            handleAuthError(error)
        }
        
        setProcessingState(false)
        */
    }
    
    /// Sign in with Google
    func signInWithGoogle() async {
        // This would require implementing the Google Sign In flow
        // and getting the id token and access token
        authError = "Google Sign In not implemented yet"
        
        // Example implementation skeleton:
        /*
        setProcessingState(true)
        
        do {
            // Get idToken and accessToken from Google Sign In
            let (idToken, accessToken) = try await getGoogleSignInCredentials()
            user = try await authRepository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
        } catch {
            handleAuthError(error)
        }
        
        setProcessingState(false)
        */
    }
    
    // MARK: - User Data Methods
    
    /// Fetch current user data
    func fetchUserData(uid: String) async {
        isLoading = true
        
        do {
            user = try await authRepository.fetchUserData(uid: uid)
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
            // We don't set authError here because this is a background operation
            // that shouldn't directly show errors to the user
        }
        
        isLoading = false
    }
    
    /// Update user profile
    func updateProfile() async {
        guard validateProfileUpdateForm() else { return }
        
        setProcessingState(true)
        
        do {
            guard var updatedUser = user else {
                authError = "No user is currently signed in"
                setProcessingState(false)
                return
            }
            
            // Update user properties
            updatedUser.displayName = displayName
            updatedUser.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
            
            try await authRepository.updateUserProfile(user: updatedUser)
            user = updatedUser
            successMessage = "Profile updated successfully"
        } catch {
            authError = "Error updating profile: \(error.localizedDescription)"
        }
        
        setProcessingState(false)
    }
    
    /// Update user profile photo
    func updateProfilePhoto(imageData: Data) async {
        guard let uid = user?.uid else {
            authError = "No user is currently signed in"
            return
        }
        
        setProcessingState(true)
        
        do {
            let photoURL = try await authRepository.updateUserPhoto(uid: uid, photoData: imageData)
            
            // Update local user object
            if var updatedUser = user {
                updatedUser.photoURL = photoURL.absoluteString
                user = updatedUser
            }
            
            successMessage = "Profile photo updated successfully"
        } catch {
            authError = "Error updating profile photo: \(error.localizedDescription)"
        }
        
        setProcessingState(false)
    }
    
    /// Delete user account
    func deleteAccount() async {
        setProcessingState(true)
        
        do {
            try await authRepository.deleteAccount()
            user = nil
            clearFields()
        } catch {
            authError = "Error deleting account: \(error.localizedDescription)"
        }
        
        setProcessingState(false)
    }
    
    // MARK: - Form Validation Methods
    
    private func validateSignInForm() -> Bool {
        authError = nil
        
        guard !email.isEmpty else {
            authError = "Please enter your email"
            return false
        }
        
        guard !password.isEmpty else {
            authError = "Please enter your password"
            return false
        }
        
        return true
    }
    
    private func validateSignUpForm() -> Bool {
        authError = nil
        
        guard !displayName.isEmpty else {
            authError = "Please enter your name"
            return false
        }
        
        guard !email.isEmpty else {
            authError = "Please enter your email"
            return false
        }
        
        guard isValidEmail(email) else {
            authError = "Please enter a valid email address"
            return false
        }
        
        guard !password.isEmpty else {
            authError = "Please enter a password"
            return false
        }
        
        guard password.count >= 8 else {
            authError = "Password must be at least 8 characters"
            return false
        }
        
        guard password == confirmPassword else {
            authError = "Passwords don't match"
            return false
        }
        
        return true
    }
    
    private func validateEmailForReset() -> Bool {
        authError = nil
        
        guard !email.isEmpty else {
            authError = "Please enter your email"
            return false
        }
        
        guard isValidEmail(email) else {
            authError = "Please enter a valid email address"
            return false
        }
        
        return true
    }
    
    private func validateProfileUpdateForm() -> Bool {
        authError = nil
        
        guard !displayName.isEmpty else {
            authError = "Please enter your name"
            return false
        }
        
        // Phone number validation is optional
        if !phoneNumber.isEmpty {
            guard isValidPhoneNumber(phoneNumber) else {
                authError = "Please enter a valid phone number"
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Helper Methods
    
    private func setProcessingState(_ processing: Bool) {
        isProcessing = processing
        if processing {
            authError = nil
            successMessage = nil
        }
    }
    
    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError
        let errorCode = AuthErrorCode(_bridgedNSError: nsError)
        
        switch errorCode {
        case .invalidEmail:
            self.authError = "Invalid email address"
        case .wrongPassword:
            self.authError = "Incorrect password"
        case .userNotFound:
            self.authError = "No account found with this email"
        case .emailAlreadyInUse:
            self.authError = "This email is already registered"
        case .weakPassword:
            self.authError = "Password is too weak"
        case .networkError:
            self.authError = "Network error. Please try again."
        case .tooManyRequests:
            self.authError = "Too many attempts. Please try again later."
        case .userDisabled:
            self.authError = "This account has been disabled"
        case .operationNotAllowed:
            self.authError = "This operation is not allowed"
        default:
            self.authError = "Authentication error: \(error.localizedDescription)"
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        phoneNumber = ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Basic phone number validation - can be enhanced for specific formats
        let phoneRegEx = "^[+]?[0-9]{10,15}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phoneNumber)
    }
    
    // MARK: - Convenience Methods for UI
    
    /// Populate fields for profile editing
    func prepareForProfileEdit() {
        if let user = user {
            displayName = user.displayName
            phoneNumber = user.phoneNumber ?? ""
        }
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        user != nil
    }
    
    /// Get user initials for avatar placeholders
    var userInitials: String {
        guard let name = user?.displayName, !name.isEmpty else { return "?" }
        
        let components = name.components(separatedBy: " ")
        if components.count > 1,
           let firstInitial = components[0].first,
           let lastInitial = components[1].first {
            return String(firstInitial) + String(lastInitial)
        } else if let firstInitial = name.first {
            return String(firstInitial)
        }
        
        return "?"
    }
}
