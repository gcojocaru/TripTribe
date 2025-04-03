//
//  ActivityDetailView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 03.04.2025.
//


import SwiftUI

struct ActivityDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    let activity: Activity
    @State private var showingEditActivity = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image (if available)
                if let photoURL = activity.photoURL, !photoURL.isEmpty {
                    AsyncImage(url: URL(string: photoURL)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 240)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 240)
                                .overlay(
                                    Image(systemName: activity.category.iconName)
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // Placeholder with category icon
                    Rectangle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(height: 240)
                        .overlay(
                            Image(systemName: activity.category.iconName)
                                .font(.system(size: 60))
                                .foregroundColor(categoryColor)
                        )
                }
                
                // Activity Details
                VStack(alignment: .leading, spacing: 24) {
                    // Title and Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.name)
                            .font(.jakartaSans(28, weight: .bold))
                        
                        HStack {
                            Image(systemName: activity.category.iconName)
                                .foregroundColor(categoryColor)
                            
                            Text(activity.category.rawValue)
                                .font(.jakartaSans(16))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Time and Duration
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            // Date
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DATE")
                                    .font(.jakartaSans(12, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Text(formattedDate)
                                    .font(.jakartaSans(16, weight: .medium))
                            }
                            
                            Spacer()
                            
                            // Time
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TIME")
                                    .font(.jakartaSans(12, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Text(formattedTime)
                                    .font(.jakartaSans(16, weight: .medium))
                            }
                            
                            Spacer()
                            
                            // Duration
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DURATION")
                                    .font(.jakartaSans(12, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Text(formattedDuration)
                                    .font(.jakartaSans(16, weight: .medium))
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                    }
                    
                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LOCATION")
                            .font(.jakartaSans(12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text(activity.location)
                                .font(.jakartaSans(16, weight: .medium))
                            
                            Spacer()
                            
                            Button(action: {
                                openMaps()
                            }) {
                                Image(systemName: "map")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppConstants.Colors.primary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                    }
                    
                    // Link (if available)
                    if let link = activity.linkURL, !link.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LINK")
                                .font(.jakartaSans(12, weight: .medium))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text(link)
                                    .font(.jakartaSans(16, weight: .medium))
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Button(action: {
                                    openLink()
                                }) {
                                    Image(systemName: "arrow.up.forward.square")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppConstants.Colors.primary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Edit Button
                    Button(action: {
                        showingEditActivity = true
                    }) {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                            
                            Text("Edit Activity")
                                .font(.jakartaSans(16, weight: .semibold))
                            
                            Spacer()
                        }
                        .padding()
                        .foregroundColor(AppConstants.Colors.primary)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.top, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Activity Details")
                    .font(.jakartaSans(18, weight: .bold))
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    coordinator.navigateBack()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditActivity = true
                    }) {
                        Label("Edit Activity", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        shareActivity()
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                }
            }
        }
        .sheet(isPresented: $showingEditActivity) {
            AddActivityView(activity: activity)
        }
    }
    
    // MARK: - Helper Methods
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: activity.startDateTime)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: activity.startDateTime)
    }
    
    private var formattedDuration: String {
        let hours = Int(activity.duration) / 60
        let minutes = Int(activity.duration) % 60
        
        if hours > 0 {
            let hourText = hours == 1 ? "hour" : "hours"
            if minutes > 0 {
                return "\(hours) \(hourText) \(minutes)m"
            } else {
                return "\(hours) \(hourText)"
            }
        } else {
            return "\(minutes) min"
        }
    }
    
    private var categoryColor: Color {
        switch activity.category {
        case .sightseeing: return .blue
        case .dining: return .orange
        case .adventure: return .green
        case .relaxation: return .purple
        case .cultural: return .red
        case .shopping: return .pink
        case .entertainment: return .yellow
        case .transportation: return .gray
        case .accommodation: return .brown
        case .other: return .black
        }
    }
    
    private func openMaps() {
        let encodedLocation = activity.location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(encodedLocation)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openLink() {
        if let link = activity.linkURL, let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareActivity() {
        // Create activity item to share
        let text = """
        Activity: \(activity.name)
        When: \(formattedDate) at \(formattedTime)
        Location: \(activity.location)
        Duration: \(formattedDuration)
        """
        
        let items: [Any] = [text]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Present the activity controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(ac, animated: true)
        }
    }
}

#Preview {
    NavigationView {
        ActivityDetailView(activity: Activity(
            id: "1",
            tripId: "trip1",
            creatorId: "user1",
            name: "Eiffel Tower Visit",
            location: "Champ de Mars, 5 Avenue Anatole France, 75007 Paris, France",
            startDateTime: Date(),
            duration: 120,
            category: .sightseeing,
            photoURL: nil,
            linkURL: "https://www.toureiffel.paris/en",
            createdAt: Date(),
            updatedAt: Date()
        ))
    }
}
