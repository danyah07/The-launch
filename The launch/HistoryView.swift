//
//  HistoryView.swift
//  The launch
//
//  Created by Danyah ALbarqawi on 30/09/2025.
//

import SwiftUI

struct HistoryView: View {
    let answers: [String: String]
    let completedHabit: Habit?
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Every streak tells your\nstory of progress")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .lineSpacing(4)
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // معلومات العادة المكتملة
                        if let habit = completedHabit {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Completed Habit")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                HStack(spacing: 12) {
                                    Text(habit.emoji)
                                        .font(.system(size: 40))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit.name)
                                            .font(.system(size: 20, weight: .semibold))
                                        Text("Goal: \(habit.goal) days streak")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // الأسئلة والأجوبة
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Your Reflections")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            ForEach(Array(answers.keys.sorted()), id: \.self) { question in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(question)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Text(answers[question] ?? "")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 10)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HistoryView(
        answers: [
            "Question 1": "Answer 1",
            "Question 2": "Answer 2"
        ],
        completedHabit: .some (Habit (
            name: "Reading",
            emoji: "📚",
            progress: 30,
            goal: 30
        )
    )
)}
