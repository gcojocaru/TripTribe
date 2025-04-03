//
//  TripsView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//


import SwiftUI
import FirebaseAuth

struct TripsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var viewModel: TripsViewModel

    var body: some View {
        SkeletonLoadingView(isLoading: viewModel.isLoading) {
            ZStack {
                AppConstants.Colors.background.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                } else if !viewModel.hasTrips && !viewModel.hasInvitations {
                    // No trips yet
                    VStack(spacing: 20) {
                        Text("No trips yet")
                            .font(.jakartaSans(22, weight: .bold))
                        
                        Text("Start planning your adventures with friends")
                            .font(.jakartaSans(16, weight: .regular))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            coordinator.showAddTrip()
                        }) {
                            Text("Create a Trip")
                                .font(.jakartaSans(16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 32)
                                .background(AppConstants.Colors.primary)
                                .cornerRadius(25)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    // Has trips or invitations
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Invitations section
                            if viewModel.hasInvitations {
                                InvitationsSection(
                                    invitations: viewModel.invitations,
                                    onAccept: { tripId, invitationId in
                                        Task {
                                            await viewModel.respondToInvitation(
                                                tripId: tripId,
                                                invitationId: invitationId,
                                                accept: true
                                            )
                                        }
                                    },
                                    onDecline: { tripId, invitationId in
                                        Task {
                                            await viewModel.respondToInvitation(
                                                tripId: tripId,
                                                invitationId: invitationId,
                                                accept: false
                                            )
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                            
                            // Upcoming trips section
                            if !viewModel.upcomingTrips.isEmpty {
                                TripsSectionView(
                                    title: "Upcoming Trips",
                                    trips: viewModel.upcomingTrips,
                                    onTripSelected: { trip in
                                        coordinator.showTripDetail(trip)
                                    }
                                )
                                .padding(.horizontal)
                            }
                            
                            // Past trips section
                            if !viewModel.pastTrips.isEmpty {
                                TripsSectionView(
                                    title: "Past Trips",
                                    trips: viewModel.pastTrips,
                                    onTripSelected: { trip in
                                        coordinator.showTripDetail(trip)
                                    }
                                )
                                .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 50)
                        }
                        .padding(.top)
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                }
                
                // Error message
                if let error = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .cornerRadius(10)
                            .padding()
                    }
                }
                
                // FAB for adding trips
                if viewModel.hasTrips {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                coordinator.showAddTrip()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
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
            }
        }
        .navigationTitle("Trips")
        .onAppear {
            Task {
                await viewModel.refreshData()
            }
        }
    }
}

// MARK: - Supporting Views

struct InvitationsSection: View {
    let invitations: [Trip]
    let onAccept: (String, String) -> Void
    let onDecline: (String, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invitations")
                .font(.jakartaSans(20, weight: .bold))
            
            ForEach(invitations) { trip in
                // Find the pending invitation for the current user
                if let invitation = findPendingInvitation(in: trip) {
                    InvitationCardView(
                        trip: trip,
                        invitationId: invitation.id,
                        onAccept: onAccept,
                        onDecline: onDecline
                    )
                }
            }
        }
    }
    
    private func findPendingInvitation(in trip: Trip) -> Invitation? {
        guard let email = Auth.auth().currentUser?.email?.lowercased() else { return nil }
        
        return trip.invitations.first { invitation in
            invitation.email.lowercased() == email && invitation.status == .pending
        }
    }
}

struct InvitationCardView: View {
    let trip: Trip
    let invitationId: String
    let onAccept: (String, String) -> Void
    let onDecline: (String, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(trip.name)
                .font(.jakartaSans(18, weight: .bold))
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.gray)
                Text(trip.destination)
                    .font(.jakartaSans(14, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text(formatDateRange(start: trip.startDate, end: trip.endDate))
                    .font(.jakartaSans(14, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    onDecline(trip.id, invitationId)
                }) {
                    Text("Decline")
                        .font(.jakartaSans(14, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(AppConstants.Colors.secondary)
                        .cornerRadius(20)
                }
                
                Button(action: {
                    onAccept(trip.id, invitationId)
                }) {
                    Text("Accept")
                        .font(.jakartaSans(14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(AppConstants.Colors.primary)
                        .cornerRadius(20)
                }
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(16)
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct TripsSectionView: View {
    let title: String
    let trips: [Trip]
    let onTripSelected: (Trip) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.jakartaSans(20, weight: .bold))
            
            ForEach(trips) { trip in
                Button {
                    onTripSelected(trip)
                } label: {
                    TripCardPreview(trip: trip)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
