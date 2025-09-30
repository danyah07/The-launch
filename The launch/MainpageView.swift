//
//  MainpageView.swift
//  The launch
//
//  Created by Aryam on 30/09/2025.
//
import SwiftUI

// امتداد لتحويل HEX إلى Color
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// امتداد آمن للوصول لمصفوفة بدون كراش
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct MainpageView: View {
    @State private var selectedTab = "Calendar"
    @State private var selectedDate: Date? = nil
    @State private var currentWeekIndex = 4
    let calendar = Calendar.current
    
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var startOfWeek: Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return calendar.date(from: components)!
    }
    
    var weeks: [[Date]] {
        var allWeeks: [[Date]] = []
        for weekOffset in -4...4 {
            var week: [Date] = []
            if let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek) {
                for day in 0..<7 {
                    if let date = calendar.date(byAdding: .day, value: day, to: weekStart) {
                        week.append(date)
                    }
                }
            }
            allWeeks.append(week)
        }
        return allWeeks
    }
    
    func monthYear(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    let amberColor = Color(hex: "94B6E7") // لون أمب
    
    var body: some View {
        VStack {
            HStack {
                Text(monthYear(for: selectedDate ?? Date()))
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.leading, 20)
                
                Spacer()
                
                Button(action: {
                    print("Add button tapped")
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(amberColor) // لون زر البلس
                        .padding(.trailing, 20)
                }
            }
            .padding(.top, 15)
            
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.4))
            
            HStack(spacing: 0.1) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)
            
            TabView(selection: $currentWeekIndex) {
                ForEach(weeks.indices, id: \.self) { index in
                    HStack(spacing: 15) {
                        ForEach(weeks[index], id: \.self) { date in
                            let dayNumber = calendar.component(.day, from: date)
                            
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(selectedDate != nil && calendar.isDate(selectedDate!, inSameDayAs: date) ? Color(hex: "345889") : Color(hex: "94B6E7"))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("\(dayNumber)")
                                            .foregroundColor(.white)
                                    )
                                    .onTapGesture {
                                        selectedDate = date
                                    }
                                
                                if calendar.isDate(date, inSameDayAs: Date()) {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 6, height: 6)
                                } else {
                                    Spacer().frame(height: 6)
                                }
                            }
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 70)
            
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.4))
            
            Spacer()
            
            HStack(spacing: 0) {
                VStack {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                    Text("Habits")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == "Habits" ? amberColor : .black) // لون أيقونة الشريط السفلي
                .onTapGesture { selectedTab = "Habits" }
                
                VStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                    Text("Calendar")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == "Calendar" ? amberColor : .black)
                .onTapGesture { selectedTab = "Calendar" }
                
                VStack {
                    Image(systemName: "trophy")
                        .font(.title2)
                    Text("Achievement")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == "Achievement" ? amberColor : .black)
                .onTapGesture { selectedTab = "Achievement" }
            }
            .padding(.vertical, 10)
            .background(Color(hex: "FFFFFF"))
        }
    }
}

#Preview {
    MainpageView()
}
