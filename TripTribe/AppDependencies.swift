//
//  AppDependencies.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import Foundation

class AppDependencies {
    // Shared instance
    static let shared = AppDependencies()
    
    // Services
    let authRepository: AuthRepositoryProtocol
    let tripRepository: TripRepositoryProtocol
    
    // Initialize with default implementations
    init(
        authRepository: AuthRepositoryProtocol = FirebaseAuthRepository(),
        tripRepository: TripRepositoryProtocol = FirebaseTripRepository()
    ) {
        self.authRepository = authRepository
        self.tripRepository = tripRepository
    }
}
