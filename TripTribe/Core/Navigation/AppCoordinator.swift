//
//  AppCoordinator.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

// Core/Navigation/AppCoordinator.swift
import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var currentTab: Tab = .home
    @Published var authState: AuthState = .checking
    @Published var navigationPath = NavigationPath()
    
    enum Tab {
        case home, trips, profile
    }
    
    enum AuthState {
        case checking, authenticated, unauthenticated
    }
    
    enum Destination: Hashable {
        case tripDetail(Trip)
        case addTrip
        case tripActivities(String) // tripId
        case activityDetail(Activity)
        case addActivity(String) // tripId
        
        // Implement Hashable conformance manually
        func hash(into hasher: inout Hasher) {
            switch self {
            case .tripDetail(let trip):
                hasher.combine(0) // Case identifier
                hasher.combine(trip)
            case .addTrip:
                hasher.combine(1) // Case identifier
            case .tripActivities(let tripId):
                hasher.combine(2) // Case identifier
                hasher.combine(tripId)
            case .activityDetail(let activity):
                hasher.combine(3) // Case identifier
                hasher.combine(activity)
            case .addActivity(let tripId):
                hasher.combine(4) // Case identifier
                hasher.combine(tripId)
            }
        }
        
        // Implement Equatable conformance manually
        static func == (lhs: Destination, rhs: Destination) -> Bool {
            switch (lhs, rhs) {
            case (.tripDetail(let trip1), .tripDetail(let trip2)):
                return trip1 == trip2
            case (.addTrip, .addTrip):
                return true
            case (.tripActivities(let id1), .tripActivities(let id2)):
                return id1 == id2
            case (.activityDetail(let activity1), .activityDetail(let activity2)):
                return activity1 == activity2
            case (.addActivity(let id1), .addActivity(let id2)):
                return id1 == id2
            default:
                return false
            }
        }
    }
    
    func showTripDetail(_ trip: Trip) {
        navigationPath.append(Destination.tripDetail(trip))
    }
    
    func showAddTrip() {
        navigationPath.append(Destination.addTrip)
    }
    
    func showTripActivities(tripId: String) {
        navigationPath.append(Destination.tripActivities(tripId))
    }
    
    func showActivityDetail(_ activity: Activity) {
        navigationPath.append(Destination.activityDetail(activity))
    }
    
    func showAddActivity(tripId: String) {
        navigationPath.append(Destination.addActivity(tripId))
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath = NavigationPath()
    }
}
