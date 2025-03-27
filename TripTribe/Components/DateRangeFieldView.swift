//
//  DateRangeFieldView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//
import SwiftUI

struct DateRangeFieldView: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
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
                        .foregroundColor(startDate == nil ? .gray : .black)
                        .padding(16)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .sheet(isPresented: $isShowingCalendar) {
                MinimalistCalendarView(startDate: $startDate, endDate: $endDate)
            }
        }
    }
    
    private func getFormattedDateRange() -> String {
        if let start = startDate, let end = endDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
        return "Select Date Range"
    }
}
