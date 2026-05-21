import SwiftUI
import FirebaseAuth

struct CalendarView: View {
    @EnvironmentObject var store: AssignmentStore
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var selectedDateAssignments: [Assignment] {
        store.assignments.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate) }
            .sorted(by: { $0.dueDate < $1.dueDate })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景を薄いグレーに設定
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 🌟 1. ヘッダー（アイコン追加 ＆ 三点リーダー削除済み）
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 24))
                                        .foregroundColor(.red) // カレンダーのアクセントカラー
                                    Text("カレンダー").font(.system(size: 28, weight: .bold))
                                }
                                Text("提出期限を一目で確認").font(.system(size: 14)).foregroundColor(.gray)
                            }
                            
                            Spacer() // これがタイトルを左に押しつける見えないバネ
                        }
                        
                        // 2. 凡例
                        HStack(spacing: 15) {
                            Label("共同課題", systemImage: "circle.fill").foregroundColor(Color(hex: "34495e"))
                            Label("個人課題", systemImage: "circle.fill").foregroundColor(.blue)
                        }
                        .font(.system(size: 12))
                        
                        // 3. カレンダー本体
                        VStack(spacing: 16) {
                            // 月の切り替え
                            HStack {
                                Button(action: { changeMonth(by: -1) }) { Image(systemName: "chevron.left").foregroundColor(.primary) }
                                Spacer()
                                Text(currentMonth, format: .dateTime.year().month()).font(.title3.bold())
                                Spacer()
                                Button(action: { changeMonth(by: 1) }) { Image(systemName: "chevron.right").foregroundColor(.primary) }
                            }
                            .padding(.horizontal)
                            
                            // 曜日
                            HStack {
                                let days = ["日", "月", "火", "水", "木", "金", "土"]
                                ForEach(days, id: \.self) { day in
                                    Text(day)
                                        .font(.system(size: 12, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(day == "日" ? .red : (day == "土" ? .blue : .gray))
                                }
                            }
                            
                            // 日付グリッド
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(extractDates(), id: \.self) { date in
                                    if let date = date {
                                        DaySquareCell(date: date, selectedDate: $selectedDate, assignments: store.assignments)
                                    } else {
                                        Text("").frame(height: 50) // 空白のマス
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        
                        // 4. 今日の課題リスト
                        VStack(alignment: .leading, spacing: 12) {
                            Text("選択した日の課題")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.gray)
                            
                            if selectedDateAssignments.isEmpty {
                                Text("課題はありません")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(selectedDateAssignments) { assignment in
                                    AssignmentCell(assignment: assignment)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(16)
                }
            }
            .navigationBarHidden(true)
        }
        // 🌟 この画面も強制的に「ライトモード」に固定！
        .environment(\.colorScheme, .light)
    }
    
    // --- 以下はカレンダーの計算ロジック（変更なし） ---
    
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) { currentMonth = newMonth }
    }
    
    private func extractDates() -> [Date?] {
        var dates: [Date?] = []
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        for _ in 0..<(firstWeekday - 1) { dates.append(nil) }
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth) else { return [] }
        for day in 1...daysInMonth.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) { dates.append(date) }
        }
        return dates
    }
}

// 🌟 カレンダーの1マス分を描画するビュー
struct DaySquareCell: View {
    var date: Date
    @Binding var selectedDate: Date
    var assignments: [Assignment]
    
    var body: some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        let dayAssignments = assignments.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        let hasCollaborative = dayAssignments.contains { $0.category == .collaborative }
        let hasPersonal = dayAssignments.contains { $0.category == .personal }
        
        VStack(spacing: 0) {
            Spacer()
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .black : .primary)
            Spacer()
            
            // 下部のバー（課題がある場合）
            if hasCollaborative || hasPersonal {
                Rectangle()
                    .fill(hasCollaborative ? Color(hex: "34495e") : Color.blue)
                    .frame(height: 4)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
            } else {
                Rectangle().fill(Color.clear).frame(height: 4).padding(.bottom, 4)
            }
        }
        .frame(height: 50)
        .background(isToday ? Color.gray.opacity(0.1) : Color.white) // 今日は少しグレー
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .onTapGesture { selectedDate = date }
    }
}
