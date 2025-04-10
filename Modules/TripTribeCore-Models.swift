// TripTribeCore/Sources/TripTribeCore/Models/User.swift
import Foundation

public struct User: Identifiable, Codable, Hashable {
    public var id: String { uid }
    public let uid: String
    public var displayName: String
    public var email: String
    public var photoURL: String?
    public var phoneNumber: String?
    public let createdAt: Date
    
    public init(uid: String, displayName: String, email: String, photoURL: String? = nil, 
                phoneNumber: String? = nil, createdAt: Date) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }
    
    // Convert to dictionary for Firestore
    public var asDictionary: [String: Any] {
        return [
            "uid": uid,
            "displayName": displayName,
            "email": email,
            "photoURL": photoURL ?? "",
            "phoneNumber": phoneNumber ?? "",
            "createdAt": createdAt
        ]
    }
}

// TripTribeCore/Sources/TripTribeCore/Models/Trip.swift
import Foundation

public struct Trip: Identifiable, Codable, Hashable {
    public var id: String
    public let creatorId: String
    public var name: String
    public var destination: String
    public var startDate: Date
    public var endDate: Date
    public var description: String?
    public var participants: [Participant]
    public var invitations: [Invitation]
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String,
        creatorId: String,
        name: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        description: String? = nil,
        participants: [Participant] = [],
        invitations: [Invitation] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.creatorId = creatorId
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
        self.participants = participants
        self.invitations = invitations
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct Participant: Identifiable, Codable, Hashable {
    public var id: String { userId }
    public let userId: String
    public let role: ParticipantRole
    public let joinedAt: Date
    
    public init(userId: String, role: ParticipantRole, joinedAt: Date = Date()) {
        self.userId = userId
        self.role = role
        self.joinedAt = joinedAt
    }
    
    public enum ParticipantRole: String, Codable {
        case creator
        case admin
        case member
    }
}

public struct Invitation: Identifiable, Codable, Hashable {
    public var id: String
    public let email: String
    public var status: InvitationStatus
    public var message: String?
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String,
        email: String,
        status: InvitationStatus = .pending,
        message: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.status = status
        self.message = message
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public enum InvitationStatus: String, Codable {
        case pending
        case accepted
        case declined
        case expired
    }
}

// TripTribeCore/Sources/TripTribeCore/Models/Activity.swift
import Foundation

public struct Activity: Identifiable, Codable, Hashable {
    public var id: String
    public let tripId: String
    public let creatorId: String
    public var name: String
    public var location: String
    public var startDateTime: Date
    public var duration: TimeInterval
    public var category: ActivityCategory
    public var photoURL: String?
    public var linkURL: String?
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String,
        tripId: String,
        creatorId: String,
        name: String,
        location: String,
        startDateTime: Date,
        duration: TimeInterval,
        category: ActivityCategory,
        photoURL: String? = nil,
        linkURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.tripId = tripId
        self.creatorId = creatorId
        self.name = name
        self.location = location
        self.startDateTime = startDateTime
        self.duration = duration
        self.category = category
        self.photoURL = photoURL
        self.linkURL = linkURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.id == rhs.id
    }
    
    public enum ActivityCategory: String, Codable, CaseIterable {
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
        
        public var iconName: String {
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
