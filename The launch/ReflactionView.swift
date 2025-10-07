//
//  ReflactionView.swift
//  The launch
//
//  Created by Jumana on 08/04/1447 AH.
//

import SwiftUI

// هذا هو View الأساسي اللي راح يعرض ReflectionScreenView
struct JView: View {
    var body: some View {
        
        NavigationStack{
            ReflectionScreenView(
                questions: [
                    "How do you feel about yourself now vs. day one?",
                    "If you had to restart your streak, what would you change?",
                    "Write a note to your future self"
                ],
                showSave: true,
                onPrevious: { print("Previous pressed") },
                onNext: { print("Next pressed") }
            )
        }
    }
    
    // هنا تعريف ReflectionScreenView المعدّل
    struct ReflectionScreenView: View {
        
        let questions: [String]
        let showSave: Bool
        let onPrevious: () -> Void
        let onNext: () -> Void
        
        @State private var showNextPage = false
        @State private var text: String = ""
        @State private var currentIndex: Int = 0
        @State private var answers: [Int: String] = [:]
        
        var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    // عنوان الصفحة
                    Text("Reflection")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(red: 0.117, green: 0.206, blue: 0.339))
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // السؤال مع حماية
                    if !questions.isEmpty && currentIndex < questions.count {
                        Text(questions[currentIndex])
                            .font(.system(size: 22, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.black)
                            .padding(.horizontal, 20)
                    } else {
                        Text("No questions available")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.gray)
                            .padding(.horizontal, 20)
                    }
                    
                    // حقل النص
                    TextField("Text field...", text: $text)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .font(.system(size: 14))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.902, green: 0.942, blue: 1.002), lineWidth: 1.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(UIColor.systemGray6))
                                )
                        )
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    
                    // الأسهم للتنقل
                    HStack {
                        Button(action: {
                            if currentIndex > 0 {
                                answers[currentIndex] = text
                                currentIndex -= 1
                                text = answers[currentIndex] ?? ""
                                onPrevious()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(red: 0.58, green: 0.714, blue: 0.907))
                        }
                        .padding(.leading, 18)
                        
                        Spacer()
                        
                        // السهم الأيمن يظهر فقط إذا لم يكن السؤال الأخير
                        if currentIndex < questions.count - 1 {
                            Button(action: {
                                answers[currentIndex] = text
                                currentIndex += 1
                                text = answers[currentIndex] ?? ""
                                onNext()
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.582, green: 0.714, blue: 0.907))
                            }
                            .padding(.trailing, 18)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // زر الحفظ
                    if showSave && currentIndex == questions.count - 1 && !questions.isEmpty {
                        
                        
                        Button(action: {
                            answers[currentIndex] = text
                            
                            var formattedAnswers: [String: String] = [:]
                            for (index, answer) in answers {
                                if index < questions.count {
                                    formattedAnswers[questions[index]] = answer
                                }
                            }
                            
                            NotificationCenter.default.post(name: NSNotification.Name("SaveAnswers"), object: formattedAnswers)
                            
                            showNextPage = true // هذا يجعل الزر يفتح الصفحة التالية
                        }) {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 180, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color(red: 0.64, green: 0.77, blue: 0.96))
                                )
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 28)
                        .padding(.bottom, 28)
                        
                        .padding(.bottom, 28)

                        NavigationLink(
                            destination: HistoryView(
                                answers: [
                                    "How do you feel about yourself now vs. day one?": "I feel more productive.",
                                    "If you had to restart your streak, what would you change?": "I would not miss any days.",
                                    "Write a note to your future self": "Keep going forward!"
                                ],
                                completedHabit: Habit(
                                    name: "Reading",
                                    emoji: "📚",
                                    progress: 30,
                                    goal: 1
                                )
                            ),
                            isActive: $showNextPage
                        ) {
                            EmptyView()
                        }

                        }
                        
                    }
                }
                
                
            }
        }
    }

    #Preview {
        JView()
    }


