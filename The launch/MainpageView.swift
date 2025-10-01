//
//  MainpageView.swift
//  The launch
//
//  Created by Aryam on 30/09/2025.
//
import SwiftUI

// ==============================
// امتداد لتحويل HEX إلى ألوان Color
// ==============================


// ==============================
// امتداد للوصول الآمن إلى عناصر المصفوفة
// ==============================
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// ==============================
// هيكل Habit يمثل عادة واحدة
// ==============================
struct Habit: Identifiable {
    let id = UUID()
    var name: String
    var emoji: String
    var progress: Int
    var goal: Int
    var isChecked: Bool = false
}

// ==============================
// الصفحة الرئيسية للتطبيق
// ==============================
struct NView: View {
    @State private var habits: [Habit] = []

    var body: some View {
        NavigationStack {
            ContentView1(habits: $habits)
        }
    }
}

// ==============================
// الصفحة الأولى لعرض العادات والتقويم
// ==============================
struct ContentView1: View {
    @Binding var habits: [Habit]

    @State private var selectedTab = "Calendar"
    @State private var selectedDate: Date? = nil
    @State private var currentWeekIndex = 4
    @State private var showCompletionAlert = false
    @State private var showContentView2 = false // للتحكم بفتح الصفحة الثانية
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

    let amberColor = Color(hex: "94B6E7")

    var body: some View {
        VStack {
            HStack {
                Text(monthYear(for: selectedDate ?? Date()))
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.leading, 20)

                Spacer()

                // زر الإضافة
                Button {
                    showContentView2.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(amberColor)
                        .padding(.trailing, 20)
                }
                .fullScreenCover(isPresented: $showContentView2) {
                    ContentView2(habits: $habits)
                }
            }
            .padding(.top, 15)

            Divider()

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
                                    .overlay(Text("\(dayNumber)").foregroundColor(.white))
                                    .onTapGesture { selectedDate = date }

                                if calendar.isDate(date, inSameDayAs: Date()) {
                                    Circle().fill(Color.black).frame(width: 6, height: 6)
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

            List {
                ForEach(habits.indices, id: \.self) { index in
                    HStack {
                        HStack(spacing: 12) {
                            Text(habits[index].emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habits[index].name)
                                    .font(.body)
                            }
                        }

                        Spacer()

                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Text("🔥").font(.caption)
                                Button(action: {
                                    if !habits[index].isChecked && habits[index].progress < habits[index].goal {
                                        habits[index].progress += 1
                                        habits[index].isChecked = true
                                        if habits[index].progress >= habits[index].goal {
                                            showCompletionAlert = true
                                        }
                                    }
                                }) {
                                    Image(systemName: habits[index].isChecked ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(habits[index].isChecked ? .green : .gray)
                                }
                            }
                            Text("\(habits[index].progress)/\(habits[index].goal)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(hex: "94B6E7").opacity(0.12))
                    .cornerRadius(12)
                    .padding(.horizontal, 8)
                }
                .onDelete { indexSet in habits.remove(atOffsets: indexSet) }
            }
            .listStyle(PlainListStyle())

            Spacer()

            HStack(spacing: 0) {
                VStack {
                    Image(systemName: "line.3.horizontal").font(.title2)
                    Text("Habits").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == "Habits" ? amberColor : .black)
                .onTapGesture { selectedTab = "Habits" }

                VStack {
                    Image(systemName: "calendar").font(.title2)
                    Text("Calendar").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == "Calendar" ? amberColor : .black)
                .onTapGesture { selectedTab = "Calendar" }

                VStack {
                    Image(systemName: "trophy").font(.title2)
                    Text("Achievement").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == "Achievement" ? amberColor : .black)
                .onTapGesture { selectedTab = "Achievement" }
            }
            .padding(.vertical, 10)
            .background(Color(hex: "FFFFFF"))
        }
        .alert("🎉 You've finished", isPresented: $showCompletionAlert) {
            Button("Reflection", role: .cancel) {}
        } message: {
            Text("your streak successfully")
        }
    }
}

// ==============================
// الصفحة الثانية لإضافة عادة جديدة
// ==============================
struct ContentView2: View {
    @Binding var habits: [Habit]
    @Environment(\.dismiss) var dismiss

    @State private var habitName: String = ""
    @State private var selectedEmoji: String = "🇸🇦"
    @State private var isEditingEmoji: Bool = false
    @State private var startDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var streak: Int = 1
    @State private var dailyNotification: Bool = false
    @State private var notificationTime: Date = Date()

    private let allEmojis: [String] = ["😀","😃","😄","😁","😆","🥹","😅"]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    HStack {
                        Spacer()
                        Button("Cancel") { dismiss() }
                            .foregroundColor(Color(red: 0.58, green: 0.71, blue: 0.91))
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add a New Habit")
                            .font(.system(size: 28, weight: .bold))
                        Text("Habit Name and Icon")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 68.0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    WhiteRow {
                        HStack {
                            TextField("Enter habit name", text: $habitName)
                                .font(.system(size: 18))
                            Spacer()
                            Button(action: {
                                withAnimation { isEditingEmoji.toggle() }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 40, height: 40)
                                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                    Text(selectedEmoji)
                                        .font(.system(size: 22))
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }

                    if isEditingEmoji {
                        WhiteRow {
                            ScrollView(.vertical, showsIndicators: true) {
                                let columns = Array(repeating: GridItem(.flexible(minimum: 32, maximum: 44), spacing: 8), count: 8)
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(allEmojis, id: \.self) { emoji in
                                        Button(action: {
                                            selectedEmoji = emoji
                                            withAnimation { isEditingEmoji = false }
                                        }) {
                                            Text(emoji)
                                                .font(.system(size: 26))
                                                .frame(width: 36, height: 36)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .frame(maxHeight: 220)
                        }
                        .padding(.horizontal)
                    }

                    WhiteRow {
                        HStack {
                            IconCircle(systemName: "play.fill")
                            Text("Starting From")
                                .font(.system(size: 16))
                            Spacer()
                            Button(action: {
                                withAnimation { showDatePicker.toggle() }
                            }) {
                                Text(startDate, format: .dateTime.day().month().year())
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    if showDatePicker {
                        WhiteRow {
                            DatePicker("", selection: $startDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                        }
                        .padding(.horizontal)
                    }

                    WhiteRow {
                        HStack {
                            IconCircle(systemName: "flame.fill")
                            Text("Your streak")
                                .font(.system(size: 16))
                            Spacer()
                            HStack(spacing: 8) {
                                Button(action: { if streak > 1 { streak -= 1 } }) {
                                    Image(systemName: "minus")
                                        .foregroundColor(.black)
                                        .frame(width: 36, height: 36)
                                        .background(Color(.systemGray5))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                Text("\(streak)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(width: 44, height: 36)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                Button(action: { streak += 1 }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .frame(width: 36, height: 36)
                                        .background(Color(.systemGray5))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    WhiteRow {
                        HStack {
                            IconCircle(systemName: "bell.fill")
                            Text("Daily Notification")
                                .font(.system(size: 16))
                            Spacer()
                            Toggle("", isOn: $dailyNotification)
                                .labelsHidden()
                                .fixedSize()
                        }
                    }

                    if dailyNotification {
                        WhiteRow {
                            DatePicker("", selection: $notificationTime, displayedComponents: [.hourAndMinute])
                                .frame(width: 49.499, height: 3.0)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(.horizontal)
                    }

                    Text("Great Note : 70 streaks is the best!")
                        .font(.system(size: 12, weight: .semibold))
                        .fontWeight(.light)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)

                    Button(action: {
                        habits.append(Habit(name: habitName, emoji: selectedEmoji, progress: 0, goal: streak))
                        habitName = ""
                        streak = 1
                        dailyNotification = false
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.58, green: 0.71, blue: 0.91))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 61))
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// ==============================
// مكون صف أبيض مع ظل
// ==============================
struct WhiteRow<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        HStack { content }
            .padding(.horizontal)
            .padding(.vertical, 17)
            .background(Color.white)
            .cornerRadius(50)
            .shadow(color: Color.black.opacity(0.20), radius: 5, x: 0, y: 3)
    }
}

// ==============================
// مكون دائرة أيقونة
// ==============================
struct IconCircle: View {
    let systemName: String
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .foregroundColor(.gray)
                .font(.system(size: 16))
        }
    }
}

// ==============================
// نقطة البداية للتطبيق
// ==============================
@main
struct LAApp: App {
    var body: some Scene {
        WindowGroup {
            NView()
        }
    }
}

// ==============================
// معاينات الكود
// ==============================
#Preview {
 NView()
}
