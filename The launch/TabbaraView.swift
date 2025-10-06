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
    "Question 1": "Answer 1",
    "Question 2": "Answer 2"
],
completedHabit: Habit(name: "Reading", emoji: "📚", progress: 30, goal: 30)
)
                .tabItem {
                    Image(systemName: "trophy")
                    Text("History")
                }
        }
    }
}

#Preview {
    TabbarView()
}
