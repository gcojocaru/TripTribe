//
//  DestinationImageView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct DestinationImageView: View {
    let destination: String
    @State private var imageURL: URL? = nil
    @State private var isLoading = true
    @State private var loadError = false
    
    var height: CGFloat = 160
    
    var body: some View {
        ZStack {
            // Background placeholder or gradient
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: height)
            
            if isLoading {
                // Loading state
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
            } else if loadError || imageURL == nil {
                // Error or fallback state
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text(destination)
                        .font(.jakartaSans(20, weight: .bold))
                        .foregroundColor(.gray)
                }
            } else {
                // Successful image load
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: height)
                            .clipped()
                    case .failure:
                        Text(destination)
                            .font(.jakartaSans(20, weight: .bold))
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(height: height)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        Task {
            do {
                let url = try await UnsplashService.shared.getImageURL(for: destination)
                await MainActor.run {
                    self.imageURL = url
                    self.isLoading = false
                }
            } catch {
                print("Error loading image: \(error.localizedDescription)")
                await MainActor.run {
                    self.loadError = true
                    self.isLoading = false
                }
            }
        }
    }
}
