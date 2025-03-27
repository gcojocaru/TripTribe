//
//  TripModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//


//
//  TripModel.swift
//  TripTribe
//
//  Created by Claude on 27.03.2025.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Trip: Identifiable, Codable {
    var id: String
    let creatorId: String
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var description: String?
    var participants: [Participant]
    var invitations: [Invitation]
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId
        case name
        case destination
        case startDate
        case endDate
        case description
        case participants
        case invitations
        case createdAt
        case updatedAt
    }
}

struct Participant: Identifiable, Codable {
    var id: String { userId }
    let userId: String
    let role: ParticipantRole
    let joinedAt: Date
    
    enum ParticipantRole: String, Codable {
        case creator
        case admin
        case member
    }
}

struct Invitation: Identifiable, Codable {
    var id: String
    let email: String
    var status: InvitationStatus  // Changed from let to var
    var message: String?         // Changed from let to var
    let createdAt: Date
    var updatedAt: Date
    
    enum InvitationStatus: String, Codable {
        case pending
        case accepted
        case declined
        case expired
    }
}

// MARK: - Firebase Extensions

extension Trip {
    var asDictionary: [String: Any] {
        return [
            "id": id,
            "creatorId": creatorId,
            "name": name,
            "destination": destination,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "description": description ?? "",
            "participants": participants.map { $0.asDictionary },
            "invitations": invitations.map { $0.asDictionary },
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
    
    static func fromFirestore(document: DocumentSnapshot) -> Trip? {
        guard let data = document.data() else { return nil }
        
        guard let id = data["id"] as? String,
              let creatorId = data["creatorId"] as? String,
              let name = data["name"] as? String,
              let destination = data["destination"] as? String,
              let startTimestamp = data["startDate"] as? Timestamp,
              let endTimestamp = data["endDate"] as? Timestamp,
              let participantsData = data["participants"] as? [[String: Any]],
              let invitationsData = data["invitations"] as? [[String: Any]],
              let createdTimestamp = data["createdAt"] as? Timestamp,
              let updatedTimestamp = data["updatedAt"] as? Timestamp else {
            return nil
        }
        
        let startDate = startTimestamp.dateValue()
        let endDate = endTimestamp.dateValue()
        let description = data["description"] as? String
        let createdAt = createdTimestamp.dateValue()
        let updatedAt = updatedTimestamp.dateValue()
        
        let participants = participantsData.compactMap { Participant.fromDictionary($0) }
        let invitations = invitationsData.compactMap { Invitation.fromDictionary($0) }
        
        return Trip(
            id: id,
            creatorId: creatorId,
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            description: description,
            participants: participants,
            invitations: invitations,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Participant {
    var asDictionary: [String: Any] {
        return [
            "userId": userId,
            "role": role.rawValue,
            "joinedAt": Timestamp(date: joinedAt)
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Participant? {
        guard let userId = dict["userId"] as? String,
              let roleString = dict["role"] as? String,
              let role = ParticipantRole(rawValue: roleString),
              let joinedTimestamp = dict["joinedAt"] as? Timestamp else {
            return nil
        }
        
        return Participant(
            userId: userId,
            role: role,
            joinedAt: joinedTimestamp.dateValue()
        )
    }
}

extension Invitation {
    var asDictionary: [String: Any] {
        return [
            "id": id,
            "email": email,
            "status": status.rawValue,
            "message": message ?? "",
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Invitation? {
        guard let id = dict["id"] as? String,
              let email = dict["email"] as? String,
              let statusString = dict["status"] as? String,
              let status = InvitationStatus(rawValue: statusString),
              let createdTimestamp = dict["createdAt"] as? Timestamp,
              let updatedTimestamp = dict["updatedAt"] as? Timestamp else {
            return nil
        }
        
        let message = dict["message"] as? String
        
        return Invitation(
            id: id,
            email: email,
            status: status,
            message: message,
            createdAt: createdTimestamp.dateValue(),
            updatedAt: updatedTimestamp.dateValue()
        )
    }
}
