//
//  NewTripView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct NewTripView: View {
    @ObservedObject var viewModel: NewTripViewModel
    
    var body: some View {
        ZStack {
            if viewModel.currentStep == 1 {
                TripDetailsView(viewModel: viewModel)
                    .transition(.opacity)
            } else if viewModel.currentStep == 2 {
                InviteFriendsView(viewModel: viewModel)
                    .transition(.opacity)
            }
            
            // Error alert
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .cornerRadius(10)
                        .padding()
                        .onAppear {
                            // Dismiss after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                viewModel.errorMessage = nil
                            }
                        }
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: viewModel.errorMessage != nil)
                .zIndex(100)
            }
            
            // Success alert
            if viewModel.showSuccessAlert {
                VStack {
                    Spacer()
                    Text("Invites sent successfully!")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green.opacity(0.9))
                        .cornerRadius(10)
                        .padding()
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: viewModel.showSuccessAlert)
                .zIndex(100)
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }
}

// The first step view - extracted from the original NewTripView
struct TripDetailsView: View {
    @ObservedObject var viewModel: NewTripViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            NewTripHeaderView(onBackTap: viewModel.dismissView)

            ScrollView {
                // Progress Indicator
                ProgressDotsView(currentStep: viewModel.currentStep, totalSteps: viewModel.totalSteps)
                    .padding(.bottom, 40)
            
                // Form content
                VStack(alignment: .leading, spacing: 32) {
                    // Trip name field
                    FormFieldView(
                        label: "Trip name",
                        placeholder: "e.g., Ski Trip 2024",
                        text: $viewModel.tripName
                    )
                    
                    DestinationFieldView(destination: $viewModel.destination)
                    
                    DateRangeFieldView(startDate: $viewModel.startDate, endDate: $viewModel.endDate)
                    
                    DescriptionFieldView(description: $viewModel.description)
                    
                    // Custom Continue Button with loading state
                    Button(action: viewModel.continueToNextStep) {
                        if viewModel.isCreatingTrip {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.black)
                                .cornerRadius(28)
                        } else {
                            Text("Continue")
                                .font(.jakartaSans(16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.black)
                                .cornerRadius(28)
                        }
                    }
                    .disabled(viewModel.isCreatingTrip)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

// Preview
struct NewTripView_Previews: PreviewProvider {
    static var previews: some View {
        NewTripView(viewModel: NewTripViewModel(onDismiss: {}))
    }
}

