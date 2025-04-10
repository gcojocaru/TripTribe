//
//  TripActivitiesView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

//
//  TripActivitiesView.swift
//  TripTribe
//
//  Created by Claude on 03.04.2025.
//

import SwiftUI

struct TripActivitiesView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: TripActivitiesViewModel
    @State private var showingAddActivity = false
    @State private var selectedActivity: Activity?
    
    init(tripId: String) {
        self._viewModel = StateObject(wrappedValue: TripActivitiesViewModel(tripId: tripId))
    }
    
    var body: some View {
        // Using parent navigation stack from coordinator
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header with trip info summary
                        if let trip = viewModel.trip {
                            TripSummaryHeader(trip: trip)
                                .padding(.bottom, 8)
                        }
                        
                        // Activities list
                        SkeletonLoadingView(isLoading: viewModel.isLoading) {
                            ActivityListView(activities: viewModel.activities) { activity in
                                selectedActivity = activity
                            }
                            .padding(.bottom, 80) // Extra padding for FAB
                        }
                    }
                    .padding(.top)
                }
                
                // FAB for adding activities
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddActivity = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(AppConstants.Colors.primary)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 25)
                        .padding(.bottom, 25)
                    }
                }
            }
            .navigationTitle("Activities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        coordinator.navigateBack()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .onChange(of: showingAddActivity) { newValue in
                if newValue {
                    if let tripId = viewModel.trip?.id {
                        coordinator.showAddActivity(tripId: tripId)
                        showingAddActivity = false
                    }
                }
            }
            .onChange(of: selectedActivity) { activity in
                if let activity = activity {
                    coordinator.showActivityDetail(activity)
                    selectedActivity = nil
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                Task {
                    await viewModel.loadTrip()
                    await viewModel.loadActivities()
                }
            }
        }
    
}

// Trip Summary Header
struct TripSummaryHeader: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Destination and dates
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(trip.destination)
                        .font(.jakartaSans(24, weight: .bold))
                    
                    Text(formatDateRange(start: trip.startDate, end: trip.endDate))
                        .font(.jakartaSans(16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Trip progress if it's an active trip
            if isActiveTrip {
                tripProgressView
            }
        }
        .padding(.vertical, 8)
    }
    
    private var tripProgressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Trip Progress")
                    .font(.jakartaSans(16, weight: .medium))
                
                Spacer()
                
                Text("\(Int(tripProgress * 100))%")
                    .font(.jakartaSans(14))
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppConstants.Colors.primary)
                        .frame(width: geometry.size.width * tripProgress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
    }
    
    // Helper functions
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    private var isActiveTrip: Bool {
        let now = Date()
        return now >= trip.startDate && now <= trip.endDate
    }
    
    private var tripProgress: CGFloat {
        let now = Date()
        
        // If trip hasn't started yet
        if now < trip.startDate {
            return 0.0
        }
        
        // If trip is already over
        if now > trip.endDate {
            return 1.0
        }
        
        // If trip is ongoing
        let totalDuration = trip.endDate.timeIntervalSince(trip.startDate)
        let elapsedDuration = now.timeIntervalSince(trip.startDate)
        
        return min(max(CGFloat(elapsedDuration / totalDuration), 0), 1)
    }
}

// View Model for Trip Activities
class TripActivitiesViewModel: ObservableObject {
    @Published var trip: Trip?
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let tripId: String
    private let tripRepository: TripRepositoryProtocol
    private let activityRepository: ActivityRepositoryProtocol
    
    init(
        tripId: String,
        tripRepository: TripRepositoryProtocol = AppDependencies.shared.tripRepository,
        activityRepository: ActivityRepositoryProtocol = AppDependencies.shared.activityRepository
    ) {
        self.tripId = tripId
        self.tripRepository = tripRepository
        self.activityRepository = activityRepository
    }
    
    @MainActor
    func loadTrip() async {
        isLoading = true
        errorMessage = nil
        
        do {
            trip = try await tripRepository.getTrip(id: tripId)
        } catch {
            errorMessage = "Failed to load trip: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadActivities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            activities = try await activityRepository.getActivities(for: tripId)
        } catch {
            errorMessage = "Failed to load activities: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// Preview
struct TripActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        TripActivitiesView(tripId: "previewTripId")
    }
}
