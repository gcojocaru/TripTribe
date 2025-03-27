//
//  DateRangePickerSheet.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct DateRangePickerSheet: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var isPresented: Bool
    @State private var tempStartDate: Date
    @State private var tempEndDate: Date
    
    init(startDate: Binding<Date?>, endDate: Binding<Date?>, isPresented: Binding<Bool>) {
        self._startDate = startDate
        self._endDate = endDate
        self._isPresented = isPresented
        self._tempStartDate = State(initialValue: startDate.wrappedValue ?? Date())
        self._tempEndDate = State(initialValue: endDate.wrappedValue ?? Date().addingTimeInterval(86400))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Spacer()
                
                Text("Select Dates")
                    .font(.jakartaSans(18, weight: .semibold))
                
                Spacer()
                
                Button("Done") {
                    startDate = tempStartDate
                    endDate = tempEndDate
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
            .padding()
            
            Divider()
            
            HStack(spacing: 20) {
                // Start date column
                VStack(alignment: .leading, spacing: 8) {
                    Text("START")
                        .font(.jakartaSans(14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    DatePicker("", selection: $tempStartDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                
                // End date column
                VStack(alignment: .leading, spacing: 8) {
                    Text("END")
                        .font(.jakartaSans(14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    DatePicker("", selection: $tempEndDate, in: tempStartDate..., displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
            }
            .padding()
            
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}
