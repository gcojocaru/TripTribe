//
//  DateRangeFieldView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct DateRangeFieldView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @State private var isShowingCalendar = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date Range")
                .font(.jakartaSans(14, weight: .medium))
                .foregroundColor(.black)
            
            Button(action: {
                isShowingCalendar = true
            }) {
                HStack {
                    Text(getFormattedDateRange())
                        .font(.jakartaSans(16, weight: .regular))
                        .foregroundColor(.black)
                        .padding(16)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .sheet(isPresented: $isShowingCalendar) {
                // Work with non-optional dates since our model now uses non-optional dates
                MinimalistCalendarView(startDate: $startDate, endDate: $endDate)
            }
        }
    }
    
    private func getFormattedDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
