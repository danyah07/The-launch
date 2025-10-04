//
//  HistoryView.swift
//  The launch
//
//  Created by Danyah ALbarqawi on 30/09/2025.
//

import SwiftUI

struct HistoryView: View {
    let answers: [String: String]
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // العنوان الرئيسي
                Text("Every streak tells your\nstory of progress")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .lineSpacing(4)
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                
                // ScrollView للأسئلة والأجوبة
                ScrollView {
                    // بوكس واحد لكل الأسئلة والأجوبة
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(Array(answers.keys.sorted()), id: \.self) { question in
                            VStack(alignment: .leading, spacing: 8) {
                                // السؤال
                                Text(question)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                
                                // الجواب
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
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HistoryView(answers: [
        "How do you feel about yourself now vs. day one?": "I feel much more confident!",
        "If you had to restart your streak, what would you change?": "Focus more on consistency.",
        "What did you learn about yourself today?": "I can push through hard times."
    ])
}
