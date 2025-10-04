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
                "How do you feel about yourself now vs. day one?": "I feel much more confident!",
                "If you had to restart your streak, what would you change?": "Focus more on consistency.",
                "What did you learn about yourself today?": "I can push through hard times."
            ])
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
