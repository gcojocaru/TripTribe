//
//  DateRangeSelectionView.swift
//  TripTribe
//
//  Created by Gheorghe Cojocaru on 27.03.2025.
//

import SwiftUI

struct MinimalistCalendarView: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var currentMonth: Date
    @Environment(\.dismiss) private var dismiss
    
    private let calendar = Calendar.current
    private let daySymbols = Calendar.current.veryShortWeekdaySymbols
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init(startDate: Binding<Date?>, endDate: Binding<Date?>) {
        self._startDate = startDate
        self._endDate = endDate
        self._currentMonth = State(initialValue: Date())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button (optional)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Select Dates")
                    .font(.jakartaSans(16, weight: .semibold))
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.jakartaSans(16, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            Divider()
                .padding(.bottom, 16)
            
            // Month navigation header
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(8)
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.jakartaSans(18, weight: .bold))
                
                Spacer()
                
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            // Day of week headers
            HStack(spacing: 0) {
                ForEach(daySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.jakartaSans(14, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        // Day cell
                        DayCell(
                            date: date,
                            isToday: calendar.isDateInToday(date),
                            isSelected: isDateSelected(date),
                            isInRange: isDateInRange(date),
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectDate(date)
                                }
                            }
                        )
                    } else {
                        // Empty cell for padding days
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6).opacity(0.5))
                    .padding(.horizontal, 12)
            )
            
            Spacer()
            
            // Date range summary
            if let start = startDate {
                VStack(spacing: 24) {
                    Divider()
                        .padding(.top, 16)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("YOUR TRIP")
                                .font(.jakartaSans(12, weight: .medium))
                                .foregroundColor(.gray)
                            
                            if let end = endDate {
                                Text("\(formattedDate(start)) - \(formattedDate(end))")
                                    .font(.jakartaSans(16, weight: .semibold))
                            } else {
                                Text("\(formattedDate(start)) - Select end date")
                                    .font(.jakartaSans(16, weight: .semibold))
                            }
                        }
                        
                        Spacer()
                        
                        if let end = endDate {
                            let days = daysBetween(start: start, end: end)
                            Text("\(days) \(days == 1 ? "day" : "days")")
                                .font(.jakartaSans(14, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.05))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Continue button
                    Button(action: { dismiss() }) {
                        Text("Continue")
                            .font(.jakartaSans(16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 27)
                                    .fill(Color.black)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .disabled(endDate == nil)
                    .opacity(endDate == nil ? 0.6 : 1.0)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func daysInMonth() -> [Date?] {
        // Get the range of days in month
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count
        
        // Get the first day of the month
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // Get the weekday of the first day (0 = Sunday, 1 = Monday, etc.)
        let firstDayWeekday = calendar.component(.weekday, from: firstDay)
        
        // In US calendar, first day is Sunday (1), so we need to shift by 1 to get proper alignment
        let shift = (firstDayWeekday - 1) % 7
        
        // Create the array of dates to display
        var days = Array(repeating: nil as Date?, count: shift)
        
        for day in 1...numDays {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            days.append(date)
        }
        
        // Ensure we have complete weeks for clean grid layout
        let remainingCells = (7 - (days.count % 7)) % 7
        if remainingCells > 0 {
            days.append(contentsOf: Array(repeating: nil as Date?, count: remainingCells))
        }
        
        return days
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func moveMonth(by amount: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: amount, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        if let start = startDate, calendar.isDate(date, inSameDayAs: start) {
            return true
        }
        if let end = endDate, calendar.isDate(date, inSameDayAs: end) {
            return true
        }
        return false
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        guard let start = startDate, let end = endDate else { return false }
        return date > start && date < end
    }
    
    private func selectDate(_ date: Date) {
        if startDate == nil || (startDate != nil && endDate != nil) {
            // Start new selection
            startDate = date
            endDate = nil
        } else if let start = startDate {
            if calendar.isDate(date, inSameDayAs: start) {
                // Tapped the same date again, do nothing
            } else if date < start {
                // Selected a date before start, make it the new start
                startDate = date
                endDate = nil
            } else {
                // Complete the range
                endDate = date
            }
        }
    }
    
    private func daysBetween(start: Date, end: Date) -> Int {
        let components = calendar.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
}

// MARK: - Day Cell Component

struct DayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let isInRange: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Range background (needs to be behind everything)
                if isInRange {
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, -4) // Extend horizontally to connect with adjacent cells
                }
                
                // Selection or today indicator
                if isSelected {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .strokeBorder(Color.black, lineWidth: 1)
                        .frame(width: 36, height: 36)
                }
                
                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(.jakartaSans(16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .black)
            }
        }
        .frame(height: 40)
    }
}
