//
//  ActivityModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//

import Foundation
import FirebaseFirestore

struct Activity: Identifiable, Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id == rhs.id
    }
    var id: String
    let tripId: String
    let creatorId: String
    var name: String
    var location: String
    var startDateTime: Date
    var duration: TimeInterval // in minutes
    var category: ActivityCategory
    var photoURL: String?
    var linkURL: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case tripId
        case creatorId
        case name
        case location
        case startDateTime
        case duration
        case category
        case photoURL
        case linkURL
        case createdAt
        case updatedAt
    }
    
    enum ActivityCategory: String, Codable, CaseIterable {
        case sightseeing = "Sightseeing"
        case dining = "Dining"
        case adventure = "Adventure"
        case relaxation = "Relaxation"
        case cultural = "Cultural"
        case shopping = "Shopping"
        case entertainment = "Entertainment"
        case transportation = "Transportation"
        case accommodation = "Accommodation"
        case other = "Other"
        
        var iconName: String {
            switch self {
            case .sightseeing: return "binoculars"
            case .dining: return "fork.knife"
            case .adventure: return "figure.hiking"
            case .relaxation: return "beach.umbrella"
            case .cultural: return "building.columns"
            case .shopping: return "bag"
            case .entertainment: return "ticket"
            case .transportation: return "car"
            case .accommodation: return "house"
            case .other: return "ellipsis.circle"
            }
        }
    }
}

// MARK: - Firestore Extensions
extension Activity {
    var asDictionary: [String: Any] {
        return [
            "id": id,
            "tripId": tripId,
            "creatorId": creatorId,
            "name": name,
            "location": location,
            "startDateTime": Timestamp(date: startDateTime),
            "duration": duration,
            "category": category.rawValue,
            "photoURL": photoURL ?? "",
            "linkURL": linkURL ?? "",
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
    
    static func fromFirestore(document: DocumentSnapshot) -> Activity? {
        guard let data = document.data() else { return nil }
        
        guard let id = data["id"] as? String,
              let tripId = data["tripId"] as? String,
              let creatorId = data["creatorId"] as? String,
              let name = data["name"] as? String,
              let location = data["location"] as? String,
              let startTimestamp = data["startDateTime"] as? Timestamp,
              let duration = data["duration"] as? TimeInterval,
              let categoryString = data["category"] as? String,
              let createdTimestamp = data["createdAt"] as? Timestamp,
              let updatedTimestamp = data["updatedAt"] as? Timestamp
        else {
            return nil
        }
        
        let category = ActivityCategory(rawValue: categoryString) ?? .other
        let photoURL = data["photoURL"] as? String
        let linkURL = data["linkURL"] as? String
        
        return Activity(
            id: id,
            tripId: tripId,
            creatorId: creatorId,
            name: name,
            location: location,
            startDateTime: startTimestamp.dateValue(),
            duration: duration,
            category: category,
            photoURL: photoURL?.isEmpty == true ? nil : photoURL,
            linkURL: linkURL?.isEmpty == true ? nil : linkURL,
            createdAt: createdTimestamp.dateValue(),
            updatedAt: updatedTimestamp.dateValue()
        )
    }
}
