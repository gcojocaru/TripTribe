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
                    
                    ContinueButtonView(action: viewModel.continueToNextStep)
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

