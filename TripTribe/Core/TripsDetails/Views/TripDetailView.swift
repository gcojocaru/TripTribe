//
//  TripDetailView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import Foundation
import SwiftUI

// MARK: - Main Trip Detail View

struct TripDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: TripDetailViewModel
    
    init(trip: Trip) {
        self._viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip))
    }
    
    var body: some View {
        ScrollView {
            SkeletonLoadingView(isLoading: viewModel.isLoading) {
                VStack(alignment: .leading, spacing: 0) {
                    TripHeaderView(trip: viewModel.trip, dateRange: viewModel.formattedDateRange())
                    
                    TripCountdownView(
                        remainingTime: viewModel.remainingTime,
                        status: viewModel.getTripStatus(),
                        label: viewModel.getCountdownLabel()
                    )
                    
                    TripParticipantsView(
                        trip: viewModel.trip,
                        showDetails: $viewModel.showParticipantDetails,
                        getInitials: viewModel.getInitials,
                        getUserData: viewModel.getUserData,
                        onToggleDetails: viewModel.toggleParticipantDetails,
                        onInvite: viewModel.handleInvite
                    )
                    
                    TripInfoView(
                        trip: viewModel.trip,
                        progress: viewModel.tripProgress
                    )
                    
                    TripQuickStartView(
                        onPlanActivities: viewModel.handlePlanActivities,
                        onTrackExpenses: viewModel.handleTrackExpenses,
                        onSecureDocuments: viewModel.handleSecureDocuments, trip: viewModel.trip
                    )
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.trip.name)
                    .font(.jakartaSans(18, weight: .bold))
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: viewModel.handleShareTrip) {
                        Label("Share Trip", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: viewModel.handleEditTrip) {
                        Label("Edit Trip", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: viewModel.handleCancelTrip) {
                        Label("Cancel Trip", systemImage: "xmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    LoadingOverlayView()
                }
            }
        )
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}

// MARK: - Trip Countdown View

struct TripCountdownView: View {
    let remainingTime: TimeComponents
    let status: TripStatus
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.jakartaSans(14, weight: .medium))
                .foregroundColor(.gray)
                .padding(.top, 12)
            
            HStack(spacing: 0) {
                countdownItem(value: remainingTime.days, label: "Days")
                divider
                countdownItem(value: remainingTime.hours, label: "Hours")
                divider
                countdownItem(value: remainingTime.minutes, label: "Minutes")
                divider
                countdownItem(value: remainingTime.seconds, label: "Seconds")
            }
            .padding(.vertical, 12)
        }
        .background(Color(.systemGray6).opacity(0.5))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(remainingTime.days) days, \(remainingTime.hours) hours, \(remainingTime.minutes) minutes, and \(remainingTime.seconds) seconds")
    }
    
    private func countdownItem(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.jakartaSans(24, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.jakartaSans(14, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 1, height: 30)
            .accessibilityHidden(true)
    }
}

// MARK: - Trip Participants View

struct TripParticipantsView: View {
    let trip: Trip
    @Binding var showDetails: Bool
    let getInitials: (Int) -> String
    let getUserData: (String) -> User?
    let onToggleDetails: () -> Void
    let onInvite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Participant avatars with overlap
                ZStack(alignment: .leading) {
                    ForEach(0..<min(trip.participants.count, 6), id: \.self) { index in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(getInitials(index))
                                    .font(.jakartaSans(14, weight: .semibold))
                                    .foregroundColor(.gray)
                            )
                            .offset(x: CGFloat(index * 20))
                    }
                }
                .frame(height: 36)
                .padding(.leading, 20)
                .onTapGesture {
                    onToggleDetails()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(trip.participants.count) trip participants")
                .accessibilityHint("Double tap to \(showDetails ? "hide" : "show") participant details")
                
                Spacer()
                
                // Invite button
                Button(action: onInvite) {
                    HStack(spacing: 5) {
                        Text("+ Invite")
                            .font(.jakartaSans(14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppConstants.Colors.secondary)
                    .cornerRadius(16)
                }
                .accessibilityHint("Invite friends to join this trip")
                .padding(.trailing, 20)
            }
            .padding(.top, 20)
            
            if showDetails {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(trip.participants, id: \.userId) { participant in
                        if let user = getUserData(participant.userId) {
                            ParticipantRowView(participant: participant, user: user)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Participant Row View

struct ParticipantRowView: View {
    let participant: Participant
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.displayName.prefix(2).uppercased())
                        .font(.jakartaSans(14, weight: .semibold))
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.jakartaSans(16, weight: .semibold))
                
                Text(participant.role.rawValue.capitalized)
                    .font(.jakartaSans(14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("Joined \(formattedDate(participant.joinedAt))")
                .font(.jakartaSans(12, weight: .regular))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Trip Info View

struct TripInfoView: View {
    let trip: Trip
    let progress: Float
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Location image
            AsyncImage(url: URL(string: "https://placeholderurl.com/destination")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    DestinationImageView(destination: trip.destination, height: 220)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
            }
            .frame(height: 200)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Destination text
            VStack(alignment: .leading, spacing: 8) {
                Text("Your adventure to \(trip.destination) awaits!")
                    .font(.jakartaSans(20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Start mapping your journey by adding activities, tracking expenses, and uploading vital documents.")
                    .font(.jakartaSans(16, weight: .regular))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 20)
            
            // Progress section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Trip progress")
                        .font(.jakartaSans(16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.jakartaSans(14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                ProgressBar(value: progress)
                    .frame(height: 8)
                    .accessibilityValue("\(Int(progress * 100)) percent complete")
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

// MARK: - Trip Quick Start View

struct TripQuickStartView: View {
    let onPlanActivities: () -> Void
    let onTrackExpenses: () -> Void
    let onSecureDocuments: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAddActivity = false
    
    var trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Start")
                .font(.jakartaSans(22, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 12) {
                quickStartButton(
                    title: "Add Activity",
                    icon: "calendar.badge.plus",
                    action: {
                        showingAddActivity = true
                    }
                )
                
                Button {
                    coordinator.showTripActivities(tripId: trip.id)
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 6)
                        
                        Text("Plan Activities")
                            .font(.jakartaSans(16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 6)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(colorScheme == .dark ? Color(.systemGray5) : Color.black)
                    .cornerRadius(27)
                }
                
                quickStartButton(
                    title: "Track Expenses",
                    icon: "dollarsign.circle",
                    action: onTrackExpenses
                )
                
                quickStartButton(
                    title: "Secure Documents",
                    icon: "doc.text",
                    action: onSecureDocuments
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .onChange(of: showingAddActivity) { newValue in
            if newValue {
                coordinator.showAddActivity(tripId: trip.id)
                showingAddActivity = false
            }
        }
    }
    
    private func quickStartButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.leading, 6)
                
                Text(title)
                    .font(.jakartaSans(16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.trailing, 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(colorScheme == .dark ? AppConstants.Colors.secondary : AppConstants.Colors.primary)
            .cornerRadius(27)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Loading Overlay View

struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            AppConstants.Colors.primary.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.8))
            )
        }
    }
}

// MARK: - Supporting Views

struct ProgressBar: View {
    var value: Float
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.2))
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(colorScheme == .dark ? Color.white : AppConstants.Colors.primary)
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width))
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
