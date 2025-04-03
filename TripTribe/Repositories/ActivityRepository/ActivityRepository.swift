//
//  ActivityRepository.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

// MARK: - Add to AppDependencies.swift:
// let activityRepository: ActivityRepositoryProtocol = FirebaseActivityRepository()

protocol ActivityRepositoryProtocol {
    // Activity CRUD operations
    func createActivity(tripId: String, name: String, location: String, startDateTime: Date, duration: TimeInterval, category: Activity.ActivityCategory, photoData: Data?, linkURL: String?, creatorId: String) async throws -> Activity
    func getActivities(for tripId: String) async throws -> [Activity]
    func getActivity(id: String, tripId: String) async throws -> Activity
    func updateActivity(activity: Activity) async throws
    func deleteActivity(id: String, tripId: String) async throws
}

class FirebaseActivityRepository: ActivityRepositoryProtocol {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - Activity CRUD Operations
    
    /// Create a new activity
    func createActivity(tripId: String, name: String, location: String, startDateTime: Date, duration: TimeInterval, category: Activity.ActivityCategory, photoData: Data?, linkURL: String?, creatorId: String) async throws -> Activity {
        // Generate a new document ID
        let activityRef = db.collection("trips").document(tripId).collection("activities").document()
        let activityId = activityRef.documentID
        
        // Upload photo if provided
        var photoURL: String? = nil
        if let photoData = photoData {
            photoURL = try await uploadActivityPhoto(tripId: tripId, activityId: activityId, photoData: photoData)
        }
        
        let now = Date()
        
        // Create activity object
        let activity = Activity(
            id: activityId,
            tripId: tripId,
            creatorId: creatorId,
            name: name,
            location: location,
            startDateTime: startDateTime,
            duration: duration,
            category: category,
            photoURL: photoURL,
            linkURL: linkURL,
            createdAt: now,
            updatedAt: now
        )
        
        // Save to Firestore
        try await activityRef.setData(activity.asDictionary)
        
        return activity
    }
    
    /// Get activities for a specific trip
    func getActivities(for tripId: String) async throws -> [Activity] {
        let snapshot = try await db.collection("trips").document(tripId).collection("activities").getDocuments()
        
        let activities = snapshot.documents.compactMap { document in
            Activity.fromFirestore(document: document)
        }
        
        // Sort by start date/time
        return activities.sorted { $0.startDateTime < $1.startDateTime }
    }
    
    /// Get a specific activity
    func getActivity(id: String, tripId: String) async throws -> Activity {
        let document = try await db.collection("trips").document(tripId).collection("activities").document(id).getDocument()
        
        guard let activity = Activity.fromFirestore(document: document) else {
            throw NSError(
                domain: "ActivityRepository",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Activity not found"]
            )
        }
        
        return activity
    }
    
    /// Update an existing activity
    func updateActivity(activity: Activity) async throws {
        // Update the timestamp
        var updatedActivity = activity
        updatedActivity.updatedAt = Date()
        
        // Upload new photo if it's a URL string that starts with "data:"
        if let photoURL = updatedActivity.photoURL, photoURL.hasPrefix("data:") {
            // Convert the data URL to actual image data
            if let photoData = extractImageDataFromDataURL(photoURL) {
                let newPhotoURL = try await uploadActivityPhoto(
                    tripId: updatedActivity.tripId,
                    activityId: updatedActivity.id,
                    photoData: photoData
                )
                updatedActivity.photoURL = newPhotoURL
            } else {
                // If we couldn't extract the image data, remove the data URL
                updatedActivity.photoURL = nil
            }
        }
        
        // Update in Firestore
        try await db.collection("trips").document(activity.tripId).collection("activities").document(activity.id).updateData(updatedActivity.asDictionary)
    }
    
    /// Delete an activity
    func deleteActivity(id: String, tripId: String) async throws {
        // Get the activity to check if it has a photo
        do {
            let activity = try await getActivity(id: id, tripId: tripId)
            
            // Delete photo from storage if it exists
            if let photoURL = activity.photoURL {
                try? await deleteActivityPhoto(tripId: tripId, activityId: id, photoURL: photoURL)
            }
        } catch {
            // If we can't get the activity, just continue with deletion
            print("Error getting activity before deletion: \(error.localizedDescription)")
        }
        
        // Delete from Firestore
        try await db.collection("trips").document(tripId).collection("activities").document(id).delete()
    }
    
    // MARK: - Helper Methods
    
    /// Upload an activity photo to Firebase Storage
    private func uploadActivityPhoto(tripId: String, activityId: String, photoData: Data) async throws -> String {
        let storageRef = storage.reference().child("trip_activities/\(tripId)/\(activityId).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(photoData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    /// Delete an activity photo from Firebase Storage
    private func deleteActivityPhoto(tripId: String, activityId: String, photoURL: String) async throws {
        // Check if the photo URL is from Firebase Storage
        if photoURL.contains("firebasestorage") {
            let storageRef = storage.reference().child("trip_activities/\(tripId)/\(activityId).jpg")
            try await storageRef.delete()
        }
    }
    
    /// Extract image data from a data URL
    private func extractImageDataFromDataURL(_ dataURL: String) -> Data? {
        // Format is typically: data:image/jpeg;base64,BASE64_DATA
        let components = dataURL.components(separatedBy: ",")
        guard components.count > 1, let base64String = components.last else {
            return nil
        }
        
        return Data(base64Encoded: base64String)
    }
}
