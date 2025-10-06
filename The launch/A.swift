
/*
import SwiftUI
import EventKit

// ==============================
// Color Extension - HEX to Color
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
// Safe Array Access Extension
// ==============================
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// ==============================
// Shared Habit Model
// ==============================
struct Habit: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var emoji: String
    var progress: Int
    var goal: Int
    var isChecked: Bool = false
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.emoji == rhs.emoji &&
        lhs.progress == rhs.progress &&
        lhs.goal == rhs.goal &&
        lhs.isChecked == rhs.isChecked
    }
}

// ==============================
// Alert Message Model
// ==============================
struct AlertMessage: Identifiable {
    var id = UUID()
    var message: String
}

// ==============================
// Calendar Manager (Updated to use Habit)
// ==============================
class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var alertMessage: AlertMessage?
    
    @Published var daysWithAllTasksCompleted: Set<Int> = []
    @Published var selectedDay: Int? = nil
    @Published var habitsByDay: [Int: [Habit]] = [:]
    
    // Reference to shared habits from main page
    @Published var sharedHabits: [Habit] = []
    
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
    
    func habits(for day: Int) -> [Habit] {
        // Use shared habits from main page
        if sharedHabits.isEmpty {
            return habitsByDay[day] ?? []
        }
        return habitsByDay[day] ?? sharedHabits
    }
    
    func toggleHabitCompletion(_ habit: Habit, for day: Int) {
        guard
            day == todayComponents.day,
            currentMonth == todayComponents.month,
            currentYear == todayComponents.year
        else { return }
        
        var habits = habitsByDay[day] ?? sharedHabits
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isChecked.toggle()
        }
        habitsByDay[day] = habits
        updateDayCompletion(for: day)
    }
    
    func updateDayCompletion(for day: Int) {
        let habits = habitsByDay[day] ?? sharedHabits
        if !habits.isEmpty && habits.allSatisfy({ $0.isChecked }) {
            daysWithAllTasksCompleted.insert(day)
        } else {
            daysWithAllTasksCompleted.remove(day)
        }
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
// Main App Entry
// ==============================
struct NView: View {
    @StateObject private var calendarManager = CalendarManager()
    @State private var habits: [Habit] = []
    
    var body: some View {
        NavigationStack {
            ContentView1(habits: $habits, calendarManager: calendarManager)
        }
        .onChange(of: habits) { oldValue, newValue in
            calendarManager.sharedHabits = newValue
        }
    }
}

// ==============================
// Main Content View with Tab Navigation
// ==============================
struct ContentView1: View {
    @Binding var habits: [Habit]
    @ObservedObject var calendarManager: CalendarManager
    
    @State private var selectedTab = "Calendar"
    @State private var selectedDate: Date? = nil
    @State private var currentWeekIndex = 4
    @State private var showCompletionAlert = false
    @State private var showContentView2 = false
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
            if selectedTab == "Calendar" {
                // Show weekly calendar view
                VStack {
                    HStack {
                        Text(monthYear(for: selectedDate ?? Date()))
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
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
                }
            } else if selectedTab == "FullCalendar" {
                // Show full calendar view
                CalenderView(calendarManager: calendarManager)
            }
            
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
                    Image(systemName: "calendar.badge.clock").font(.title2)
                    Text("Full Calendar").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == "FullCalendar" ? amberColor : .black)
                .onTapGesture { selectedTab = "FullCalendar" }
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
// Add New Habit View
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
    
    private let allEmojis: [String] = ["😀","😃","😄","😁","😆","🥹","😅","😂","🤣","🥲","☺️","😊","😇","🙂","🙃","😉","😌","😍","🥰","😘","😗","😙","😚","😋","😛","😝","😜","🤪","🤨","🧐","🤓","😎","🥸","🤩","🥳","🙂‍↕️","😏","😒","🙂‍↔️","😞","😔","😟","😕","🙁","☹️","😣","😖","😫","😩","🥺","😢","😭","😤","😠","😡","🤬","🤯","😳","🥵","🥶","😶‍🌫️","😱","😨","😰","😥","😓","🤗","🤔","🫣","🤭","🫢","🫡","🤫","🫠","🤥","😶","🫥","😐","🫤","😑","🫨","😬","🙄","😯","😦","😧","😮","😲","🥱","🫩","😴","🤤","😪","😮‍💨","😵","😵‍💫","🤐","🥴","🤢","🤮","🤧","😷","🤒","🤕","🤑","🤠","😈","👿","👹","👺","🤡","💩","👻","💀","☠️","👽","👾","🤖","🎃","😺","😸","😹","😻","😼","😽","🙀","😿","😾"]
    
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
// Day Cell View for Calendar
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
// Custom Calendar Grid
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
// Full Calendar View
// ==============================
struct CalenderView: View {
    @ObservedObject var calendarManager: CalendarManager
    
    var body: some View {
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
                Text("Tasks for day \(selectedDay)")
                    .font(.headline)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                List {
                    ForEach(calendarManager.habits(for: selectedDay)) { habit in
                        HStack {
                            Text(habit.emoji)
                                .font(.title2)
                            Text(habit.name)
                            Spacer()
                            Image(systemName: habit.isChecked ? "checkmark.square.fill" : "square")
                                .font(.title2)
                                .foregroundColor(habit.isChecked ? Color(hex: "6EA7DB") : .gray)
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
                Text("Select a day from the calendar to view tasks")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .alert(item: $calendarManager.alertMessage) { alertMsg in
            Alert(title: Text("Alert"), message: Text(alertMsg.message), dismissButton: .default(Text("OK")))
        }
        .onAppear { calendarManager.checkAuthorization() }
    }
}

// ==============================
// Helper Components
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
// App Entry Point
// ==============================
struct LAApp: App {
    var body: some Scene {
        WindowGroup {
            NView()
        }
    }
}

// ==============================
// Preview
// ==============================
#Preview {
    NView()
}
*/
