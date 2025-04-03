//
//  ActivityViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//


//
//  ActivityViewModel.swift
//  TripTribe
//
//  Created by Claude on 03.04.2025.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import Combine

@MainActor
class ActivityViewModel: ObservableObject {
    // Form data
    @Published var activityName: String = ""
    @Published var location: String = ""
    @Published var startDateTime: Date = Date()
    @Published var duration: TimeInterval = 60 // Default 1 hour in minutes
    @Published var category: Activity.ActivityCategory = .sightseeing
    @Published var photoData: Data? = nil
    @Published var photoUIImage: UIImage? = nil  // For UI display purposes
    @Published var linkURL: String = ""
    
    // Trip constraints
    private var tripStartDate: Date
    private var tripEndDate: Date
    
    // UI state
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isShowingImagePicker: Bool = false
    @Published var isShowingCameraSheet: Bool = false
    @Published var isShowingActivitySheet: Bool = false
    @Published var successMessage: String? = nil
    
    // Data state
    @Published var activities: [Activity] = []
    @Published var currentActivity: Activity? = nil
    @Published var isEditing: Bool = false
    
    // Dependencies
    private let activityRepository: ActivityRepositoryProtocol
    private let tripId: String
    
    // Callbacks
    var onDismiss: (() -> Void)?
    var onSave: ((Activity) -> Void)?
    
    // MARK: - Initialization
    
    init(tripId: String, activityRepository: ActivityRepositoryProtocol = AppDependencies.shared.activityRepository) {
        self.tripId = tripId
        self.activityRepository = activityRepository
        
        // Set default start/end date constraints
        self.tripStartDate = Date()
        self.tripEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        
        // Try to load the trip to get actual date constraints
        Task {
            await loadTripDateConstraints()
        }
        
        // Initialize with default date in the valid range
        self.startDateTime = max(Date(), tripStartDate)
    }
    
    // For editing an existing activity
    convenience init(activity: Activity, activityRepository: ActivityRepositoryProtocol = AppDependencies.shared.activityRepository) {
        self.init(tripId: activity.tripId, activityRepository: activityRepository)
        self.currentActivity = activity
        self.isEditing = true
        
        // Populate the form with the activity data
        self.loadActivityData(activity)
    }
    
    // Load trip constraints (start and end dates)
    private func loadTripDateConstraints() async {
        do {
            let tripRepository = AppDependencies.shared.tripRepository
            let trip = try await tripRepository.getTrip(id: tripId)
            
            await MainActor.run {
                self.tripStartDate = trip.startDate
                self.tripEndDate = trip.endDate
                
                // If we're creating a new activity, ensure the default date is within range
                if !isEditing {
                    let now = Date()
                    self.startDateTime = max(now, trip.startDate)
                }
            }
        } catch {
            print("Failed to load trip date constraints: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Management
    
    /// Load all activities for a trip
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
    
    /// Populate form with activity data for editing
    private func loadActivityData(_ activity: Activity) {
        activityName = activity.name
        location = activity.location
        startDateTime = activity.startDateTime
        duration = activity.duration
        category = activity.category
        linkURL = activity.linkURL ?? ""
        
        // If there's a photo URL, we'll need to download the image
        if let photoURL = activity.photoURL, !photoURL.isEmpty {
            loadImageFromURL(photoURL)
        }
    }
    
    /// Helper to load an image from a URL
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Download the image data
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                self.photoData = data
                self.photoUIImage = UIImage(data: data)
            } catch {
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Form Actions
    
    /// Save a new activity or update an existing one
    func saveActivity() async {
        guard validateForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard let currentUser = Auth.auth().currentUser else {
                errorMessage = "You need to be logged in to create activities"
                isLoading = false
                return
            }
            
            let creatorId = currentUser.uid
            
            if isEditing, let activity = currentActivity {
                // Update existing activity
                var updatedActivity = activity
                updatedActivity.name = activityName
                updatedActivity.location = location
                updatedActivity.startDateTime = startDateTime
                updatedActivity.duration = duration
                updatedActivity.category = category
                updatedActivity.linkURL = linkURL.isEmpty ? nil : linkURL
                
                // If we have new photo data, we need to handle it specially in the repository
                if let newPhotoData = photoData, photoUIImage != nil {
                    // We'll use a special marker in the photoURL field to indicate new photo data
                    // The repository will handle the actual upload
                    updatedActivity.photoURL = "data:image/jpeg;base64," + newPhotoData.base64EncodedString()
                }
                
                try await activityRepository.updateActivity(activity: updatedActivity)
                successMessage = "Activity updated successfully"
                currentActivity = updatedActivity
                
                // Call the onSave callback with the updated activity
                onSave?(updatedActivity)
            } else {
                // Create new activity
                let newActivity = try await activityRepository.createActivity(
                    tripId: tripId,
                    name: activityName,
                    location: location,
                    startDateTime: startDateTime,
                    duration: duration,
                    category: category,
                    photoData: photoData,
                    linkURL: linkURL.isEmpty ? nil : linkURL,
                    creatorId: creatorId
                )
                
                successMessage = "Activity created successfully"
                currentActivity = newActivity
                
                // Call the onSave callback with the new activity
                onSave?(newActivity)
            }
            
            // Dismiss the view after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.onDismiss?()
            }
        } catch {
            errorMessage = "Failed to save activity: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Delete an activity
    func deleteActivity() async {
        guard let activity = currentActivity else {
            errorMessage = "No activity to delete"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await activityRepository.deleteActivity(id: activity.id, tripId: activity.tripId)
            successMessage = "Activity deleted successfully"
            
            // Dismiss the view after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.onDismiss?()
            }
        } catch {
            errorMessage = "Failed to delete activity: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Handle image selection from picker
    func didSelectImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Failed to process image"
            return
        }
        
        photoData = imageData
        photoUIImage = image
    }
    
    // MARK: - Form Validation
    
    private func validateForm() -> Bool {
        // Reset error message
        errorMessage = nil
        
        // Validate required fields
        guard !activityName.isEmpty else {
            errorMessage = "Please enter an activity name"
            return false
        }
        
        guard !location.isEmpty else {
            errorMessage = "Please enter a location"
            return false
        }
        
        // Validate date is within trip range
        guard startDateTime >= tripStartDate && startDateTime <= tripEndDate else {
            errorMessage = "Activity date must be within trip dates"
            return false
        }
        
        // Validate activity end time doesn't exceed trip end date
        let activityEndTime = startDateTime.addingTimeInterval(duration * 60)
        guard activityEndTime <= tripEndDate else {
            errorMessage = "Activity duration exceeds trip end date"
            return false
        }
        
        // Validate duration
        guard duration >= 15 else {
            errorMessage = "Duration must be at least 15 minutes"
            return false
        }
        
        // Validate link URL if provided
        if !linkURL.isEmpty {
            guard URL(string: linkURL) != nil else {
                errorMessage = "Please enter a valid URL"
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Helper Functions
    
    /// Format duration for display
    var formattedDuration: String {
        let hours = Int(duration) / 60
        let minutes = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Valid date range for the date picker
    var validDateRange: ClosedRange<Date> {
        // For editing existing activities, we may need to allow the original date
        // even if it's in the past
        let minDate: Date
        if isEditing, let activity = currentActivity, activity.startDateTime < Date() {
            minDate = activity.startDateTime
        } else {
            minDate = max(Date(), tripStartDate)
        }
        
        return minDate...tripEndDate
    }
    
    /// Reset the form
    func resetForm() {
        activityName = ""
        location = ""
        startDateTime = Date()
        duration = 60
        category = .sightseeing
        photoData = nil
        photoUIImage = nil
        linkURL = ""
        errorMessage = nil
        successMessage = nil
    }
}
