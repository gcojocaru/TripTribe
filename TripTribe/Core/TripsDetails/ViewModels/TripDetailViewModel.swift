//
//  TripDetailViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI
import Combine

class TripDetailViewModel: ObservableObject {
    // Trip data
    private(set) var trip: Trip
    
    // Published states
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var tripProgress: Float = 0.0
    
    // Countdown timer states
    @Published var remainingTime: TimeComponents = TimeComponents()
    @Published var showParticipantDetails: Bool = false
    
    // Private properties
    private var timer: Timer? = nil
    private var cancellables = Set<AnyCancellable>()
    
    // Initialization
    init(trip: Trip) {
        self.trip = trip
        setupTimers()
    }
    
    // MARK: - Setup
    
    private func setupTimers() {
        updateCountdown()
        calculateProgress()
        startTimer()
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCountdown()
            self?.calculateProgress()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Calculations
    
    func updateCountdown() {
        let now = Date()
        
        // If trip is in the future, calculate countdown to start date
        if trip.startDate > now {
            calculateTimeRemaining(from: now, to: trip.startDate)
        }
        // If trip is ongoing, calculate countdown to end date
        else if trip.startDate <= now && trip.endDate >= now {
            calculateTimeRemaining(from: now, to: trip.endDate)
        }
        // If trip is in the past, set countdown to zero
        else {
            remainingTime = TimeComponents()
        }
    }
    
    private func calculateTimeRemaining(from startDate: Date, to endDate: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: startDate, to: endDate)
        
        remainingTime = TimeComponents(
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0,
            seconds: components.second ?? 0
        )
    }
    
    func calculateProgress() {
        let now = Date()
        
        // If trip hasn't started yet
        if now < trip.startDate {
            tripProgress = 0.0
            return
        }
        
        // If trip is already over
        if now > trip.endDate {
            tripProgress = 1.0
            return
        }
        
        // If trip is ongoing
        let totalDuration = trip.endDate.timeIntervalSince(trip.startDate)
        let elapsedDuration = now.timeIntervalSince(trip.startDate)
        
        tripProgress = Float(min(max(elapsedDuration / totalDuration, 0), 1))
    }
    
    // MARK: - Trip Information
    
    func formattedDateRange() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let startStr = dateFormatter.string(from: trip.startDate)
        let endStr = dateFormatter.string(from: trip.endDate)
        
        return "\(startStr) - \(endStr)"
    }
    
    func getTripStatus() -> TripStatus {
        let now = Date()
        
        if now < trip.startDate {
            return .upcoming
        } else if now <= trip.endDate {
            return .ongoing
        } else {
            return .completed
        }
    }
    
    func getCountdownLabel() -> String {
        switch getTripStatus() {
        case .upcoming:
            return "Time until trip:"
        case .ongoing:
            return "Time remaining:"
        case .completed:
            return "Trip completed"
        }
    }
    
    // MARK: - Participant Management
    
    func getInitials(for index: Int) -> String {
        guard index < trip.participants.count,
              let user = getUserData(for: trip.participants[index].userId) else {
            return "?"
        }
        
        let components = user.displayName.components(separatedBy: " ")
        if components.count > 1,
           let firstInitial = components[0].first,
           let lastInitial = components[1].first {
            return String(firstInitial) + String(lastInitial)
        } else if let firstInitial = user.displayName.first {
            return String(firstInitial)
        }
        
        return "?"
    }
    
    // Simulating fetching user data - in a real app, this would come from your user repository
    func getUserData(for userId: String) -> User? {
        // This is a placeholder - replace with actual user data retrieval
        return User(uid: userId, displayName: "User \(userId.prefix(2))", email: "user\(userId.prefix(2))@example.com", photoURL: nil, phoneNumber: nil, createdAt: Date())
    }
    
    func toggleParticipantDetails() {
        withAnimation {
            showParticipantDetails.toggle()
        }
    }
    
    // MARK: - Trip Actions
    
    func handleInvite() {
        // Implementation for inviting participants
        isLoading = true
        
        // Simulating an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false
            // Handle the result here
        }
    }
    
    func handlePlanActivities() {
        // Implementation for navigating to activities planner
    }
    
    func handleTrackExpenses() {
        // Implementation for navigating to expense tracker
    }
    
    func handleSecureDocuments() {
        // Implementation for navigating to document storage
    }
    
    func handleShareTrip() {
        // Implementation for sharing trip
    }
    
    func handleEditTrip() {
        // Implementation for editing trip
    }
    
    func handleCancelTrip() {
        // Implementation for canceling trip
        isLoading = true
        
        // Simulating an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false
            // Handle the result here
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopTimer()
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Supporting Models



enum TripStatus {
    case upcoming
    case ongoing
    case completed
}

