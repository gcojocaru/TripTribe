//
//  AppError.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

enum AppError: Error {
    case authentication(reason: AuthError)
    case network(description: String)
    case database(description: String)
    case validation(field: String, message: String)
    case unknown(description: String)
    
    var userMessage: String {
        switch self {
        case .authentication(let reason):
            return reason.userMessage
        case .network(let description):
            return "Network error: \(description)"
        case .database(let description):
            return "Database error: \(description)"
        case .validation(let field, let message):
            return "\(field): \(message)"
        case .unknown(let description):
            return "An error occurred: \(description)"
        }
    }
}

enum AuthError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    // more specific cases...
    
    var userMessage: String {
        switch self {
        case .invalidCredentials:
            return "Your email or password is incorrect"
        case .userNotFound:
            return "No account found with this email"
        case .emailAlreadyInUse:
            return "This email is already registered"
        }
    }
}
