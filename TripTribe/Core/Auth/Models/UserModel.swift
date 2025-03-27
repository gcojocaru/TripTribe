//
//  UserModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 26.03.2025.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User: Identifiable, Codable {
    var id: String { uid }
    let uid: String
    var displayName: String
    var email: String
    var photoURL: String?
    var phoneNumber: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case uid
        case displayName
        case email
        case photoURL
        case phoneNumber
        case createdAt
    }
}

extension User {
    var asDictionary: [String: Any] {
        return [
            "uid": uid,
            "displayName": displayName,
            "email": email,
            "photoURL": photoURL ?? "",
            "phoneNumber": phoneNumber ?? "",
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}

extension User {
    init?(from document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let uid = data["uid"] as? String,
              let displayName = data["displayName"] as? String,
              let email = data["email"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.photoURL = data["photoURL"] as? String
        self.phoneNumber = data["phoneNumber"] as? String
        self.createdAt = createdAt
    }
}
