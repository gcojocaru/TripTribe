//
//  NewTripViewModel.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI
import Combine

class NewTripViewModel: ObservableObject {
    @Published var tripName: String = ""
    @Published var destination: String = ""
    @Published var dateRange: String = ""
    @Published var description: String = ""
    @Published var currentStep: Int = 1
    @Published var totalSteps: Int = 2
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    private var onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    func dismissView() {
        onDismiss()
    }
    
    func continueToNextStep() {
        print("Continue to next step")
    }
}
