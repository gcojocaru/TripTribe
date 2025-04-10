//
//  TripTribeApp.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct TripTribeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authViewModel = AuthViewModel(
        authRepository: AppDependencies.shared.authRepository
    )
    
    @StateObject private var tripsViewModel = TripsViewModel(
        tripRepository: AppDependencies.shared.tripRepository
    )
    
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(authViewModel)
                .environmentObject(tripsViewModel)
                .environmentObject(coordinator)
        }
    }
}
