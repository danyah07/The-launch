//
//  TabbaraView.swift
//  The launch
//
//  Created by Danyah ALbarqawi on 30/09/2025.
//


import SwiftUI

struct TabbarView: View {
    var body: some View {
        TabView {
           NView()
                .tabItem {
                    Image(systemName: "line.3.horizontal")
                    Text("Habits")
                }
            
            CalenderView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
HistoryView ( answers: [
    "How do you feel about yourself now vs. day one?": "I feel more prodictive.",
    
    "If you had to restart your streak, what would you change?": "I would not miss any days"
],
completedHabit: Habit(name: "Reading", emoji: "📚", progress: 30, goal: 30)
)
                .tabItem {
                    Image(systemName: "trophy")
                    Text("History")
                }
        }.tint(Color(red: 0.64, green: 0.77, blue: 0.96))
    }
}

#Preview {
    TabbarView()
}
