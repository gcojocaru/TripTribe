//
//  UnsplashService.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//


import Foundation
import Combine

class UnsplashService {
    // You should get your own Unsplash API key from https://unsplash.com/developers
    private let accessKey = "Q1rOAdJoERCVtp2sV-HAcyt1Mf4dJq5f7qFK7SKZ2xs"
    private let baseURL = "https://api.unsplash.com"
    
    static let shared = UnsplashService()
    
    private init() {}
    
    func getImageURL(for destination: String) async throws -> URL {
        let searchTerm = "\(destination) travel landmark"
        let endpoint = "/search/photos"
        
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "per_page", value: "1"),
            URLQueryItem(name: "orientation", value: "landscape")
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            let searchResult = try JSONDecoder().decode(UnsplashSearchResult.self, from: data)
            
            if let firstResult = searchResult.results.first,
               let imageURL = URL(string: firstResult.urls.regular) {
                return imageURL
            } else {
                throw URLError(.cannotDecodeContentData)
            }
        } catch {
            throw error
        }
    }
}

// MARK: - API Response Models

struct UnsplashSearchResult: Codable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

struct UnsplashPhoto: Codable {
    let id: String
    let urls: UnsplashPhotoURLs
    let user: UnsplashUser
}

struct UnsplashPhotoURLs: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashUser: Codable {
    let name: String
    let username: String
}
