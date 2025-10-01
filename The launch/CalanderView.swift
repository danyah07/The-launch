//
//  CalanderView.swift
//  The launch
//
//  Created by Asail abdulmohsin on 08/04/1447 AH.
//

import SwiftUI
import EventKit

// ==============================
// تحويل HEX إلى لون (نسخة واحدة فقط في المشروع)
// ==============================
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

// ==============================
// نموذج رسالة تنبيه
// ==============================
struct AlertMessage: Identifiable {
    var id = UUID()
    var message: String
}

// ==============================
// DailyHabit لتجنب تكرار اسم Habit
// ==============================
struct DailyHabit: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var isCompleted: Bool = false
}

// ==============================
// مدير التقويم
// ==============================
class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var alertMessage: AlertMessage?

    @Published var daysWithAllTasksCompleted: Set<Int> = []
    @Published var selectedDay: Int? = nil
    @Published var habitsByDay: [Int: [DailyHabit]] = [:]

    private let calendar = Calendar.current

    let todayComponents: DateComponents
    @Published var currentMonth: Int
    @Published var currentYear: Int

    init() {
        let now = Date()
        todayComponents = calendar.dateComponents([.day, .month, .year], from: now)
        currentMonth = todayComponents.month ?? 1
        currentYear = todayComponents.year ?? 2023
        selectedDay = todayComponents.day
        checkAuthorization()
    }

    func checkAuthorization() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        switch authorizationStatus {
        case .notDetermined:
            requestAccess()
        case .authorized:
            break
        default:
            alertMessage = AlertMessage(message: "يرجى منح صلاحية الوصول للتقويم في الإعدادات.")
        }
    }

    func requestAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.authorizationStatus = .authorized
                } else {
                    self.authorizationStatus = .denied
                    self.alertMessage = AlertMessage(message: "يرجى منح صلاحية الوصول للتقويم.")
                }
            }
        }
    }

    func habits(for day: Int) -> [DailyHabit] {
        habitsByDay[day] ?? defaultHabits()
    }

    func toggleHabitCompletion(_ habit: DailyHabit, for day: Int) {
        guard
            day == todayComponents.day,
            currentMonth == todayComponents.month,
            currentYear == todayComponents.year
        else { return }

        var habits = habitsByDay[day] ?? defaultHabits()
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
        }
        habitsByDay[day] = habits
        updateDayCompletion(for: day)
    }

    func updateDayCompletion(for day: Int) {
        let habits = habitsByDay[day] ?? defaultHabits()
        if habits.allSatisfy({ $0.isCompleted }) {
            daysWithAllTasksCompleted.insert(day)
        } else {
            daysWithAllTasksCompleted.remove(day)
        }
    }

    func defaultHabits() -> [DailyHabit] {
        [
            DailyHabit(name: "تنظيف الغرفة"),
            DailyHabit(name: "صلاة السنة"),
            DailyHabit(name: "شرب 1 لتر ماء"),
            DailyHabit(name: "قراءة 5 صفحات"),
            DailyHabit(name: "الجري 3 كم")
        ]
    }

    func moveMonth(by offset: Int) {
        var dateComponents = DateComponents()
        dateComponents.month = offset
        if let currentDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth)) {
            if let newDate = calendar.date(byAdding: dateComponents, to: currentDate) {
                let comps = calendar.dateComponents([.year, .month], from: newDate)
                currentMonth = comps.month ?? currentMonth
                currentYear = comps.year ?? currentYear
                selectedDay = nil
            }
        }
    }

    func daysInCurrentMonth() -> Int {
        let comps = DateComponents(year: currentYear, month: currentMonth)
        if let date = calendar.date(from: comps),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 30
    }

    func firstWeekdayOfCurrentMonth() -> Int {
        let comps = DateComponents(year: currentYear, month: currentMonth, day: 1)
        if let date = calendar.date(from: comps) {
            return calendar.component(.weekday, from: date)
        }
        return 1
    }

    func currentMonthName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "MMMM"
        if let date = calendar.date(from: DateComponents(year: currentYear, month: currentMonth)) {
            return formatter.string(from: date)
        }
        return ""
    }
}

// ==============================
// عرض كل يوم في التقويم
// ==============================
struct DayCellView: View {
    let day: String
    let isCompleted: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            if isSelected {
                Circle()
                    .fill(Color(hex: "6EA7DB").opacity(0.3))
                    .frame(width: 35, height: 35)
            }
            if isCompleted {
                Circle()
                    .stroke(Color(hex: "6EA7DB"), lineWidth: 3)
                    .frame(width: 35, height: 35)
            }
            Text(day)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isCompleted ? Color(hex: "6EA7DB") : .primary)
                .padding(5)
        }
        .onTapGesture {
            onTap()
        }
    }
}

// ==============================
// شبكة عرض التقويم
// ==============================
struct CustomCalendarGrid: View {
    @ObservedObject var calendarManager: CalendarManager

    let daysOfWeek = ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var calendarDays: [String] {
        let range = 1...calendarManager.daysInCurrentMonth()
        let prefix = Array(repeating: "", count: calendarManager.firstWeekdayOfCurrentMonth() - 1)
        let days = range.map { String($0) }
        return prefix + days
    }

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(calendarDays, id: \.self) { day in
                    if day.isEmpty {
                        Text("").frame(height: 35)
                    } else {
                        let dayInt = Int(day) ?? 0
                        DayCellView(
                            day: day,
                            isCompleted: calendarManager.daysWithAllTasksCompleted.contains(dayInt),
                            isSelected: calendarManager.selectedDay == dayInt,
                            onTap: {
                                calendarManager.selectedDay = dayInt
                            }
                        )
                        .frame(height: 39)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

// ==============================
// العرض الرئيسي للتقويم
// ==============================
struct CalenderView: View {
    @StateObject var calendarManager = CalendarManager()
    @State private var selectedTab = "Calendar"

    var body: some View {
        VStack(spacing: 0) {
            if selectedTab == "Calendar" {
                VStack(spacing: 10) {
                    HStack {
                        Button(action: { calendarManager.moveMonth(by: -1) }) {
                            Image(systemName: "chevron.left").font(.title2).padding()
                        }
                        Spacer()
                        Text("\(calendarManager.currentYear) / \(calendarManager.currentMonthName())")
                            .font(.headline)
                        Spacer()
                        Button(action: { calendarManager.moveMonth(by: 1) }) {
                            Image(systemName: "chevron.right").font(.title2).padding()
                        }
                    }
                    .padding(.horizontal)

                    CustomCalendarGrid(calendarManager: calendarManager)
                        .padding(.horizontal)

                    Divider()

                    if let selectedDay = calendarManager.selectedDay {
                        Text("المهام ليوم \(selectedDay)")
                            .font(.headline)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        List {
                            ForEach(calendarManager.habits(for: selectedDay)) { habit in
                                HStack {
                                    Text(habit.name)
                                    Spacer()
                                    Image(systemName: habit.isCompleted ? "checkmark.square.fill" : "square")
                                        .font(.title2)
                                        .foregroundColor(habit.isCompleted ? Color(hex: "6EA7DB") : .gray)
                                }
                                .contentShape(Rectangle())
                                .opacity(
                                    calendarManager.currentYear == calendarManager.todayComponents.year &&
                                    calendarManager.currentMonth == calendarManager.todayComponents.month &&
                                    selectedDay == calendarManager.todayComponents.day ? 1 : 0.3
                                )
                                .onTapGesture {
                                    calendarManager.toggleHabitCompletion(habit, for: selectedDay)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 300)
                    } else {
                        Text("اختر يومًا من التقويم لعرض المهام")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }

            Divider()
        }
        .alert(item: $calendarManager.alertMessage) { alertMsg in
            Alert(title: Text("تنبيه"), message: Text(alertMsg.message), dismissButton: .default(Text("حسناً")))
        }
        .onAppear { calendarManager.checkAuthorization() }
    }
}

// ==============================
// معاينة
// ==============================
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalenderView()
    }
}
