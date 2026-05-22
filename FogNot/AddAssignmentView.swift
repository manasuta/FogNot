import SwiftUI

struct AddAssignmentView: View {
    @EnvironmentObject var store: AssignmentStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date()
    @State private var category: AssignmentCategory = .personal
    @State private var subjectTag: SubjectTag = .common // 💡前回の修正通り
    
    // 機能として残しておきます（裏で保存されます）
    @State private var priority: Priority = .none
    @State private var hasReminder = false
    @State private var reminderDate = Date()

    var body: some View {
        NavigationStack {
            // 🌟背景を薄いグレーにして、白いフォームを目立たせる
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                Form {
                    Section(header: Text("基本情報").foregroundColor(.gray)) {
                        TextField("課題名（タップして入力）", text: $title)
                        TextField("内容（メモ、任意）", text: $notes)
                    }
                    
                    Section(header: Text("分類").foregroundColor(.gray)) {
                                            Picker("カテゴリー", selection: $category) {
                                                // 🌟 ここの順番を上下入れ替えるだけ！
                                                Text("共同").tag(AssignmentCategory.collaborative)
                                                Text("個人").tag(AssignmentCategory.personal)
                                            }
                                            .pickerStyle(.segmented)
                                            .padding(.vertical, 4)
                                            
                                            Picker("科目", selection: $subjectTag) {
                                                ForEach(SubjectTag.allCases, id: \.self) { tag in
                                                    Text(tag.rawValue).tag(tag)
                                                }
                                            }
                                            
                                            Picker("優先度", selection: $priority) {
                                                Text("なし").tag(Priority.none)
                                                Text("中 (黄)").tag(Priority.yellow)
                                                Text("高 (赤)").tag(Priority.red)
                                            }
                                        }
                    
                    Section(header: Text("期限と通知").foregroundColor(.gray)) {
                        DatePicker("提出期限", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        Toggle("リマインダー", isOn: $hasReminder)
                        if hasReminder {
                            DatePicker("通知時間", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                }
                // 💡 Apple標準のフォーム背景を消す魔法
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("課題の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .foregroundColor(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveAssignment() }
                        .fontWeight(.bold)
                        .disabled(title.isEmpty)
                        .foregroundColor(title.isEmpty ? .gray : .blue)
                }
            }
        }
        // 🌟 この画面を強制的に「ライトモード」にする
        .environment(\.colorScheme, .light)
    }
    
    private func saveAssignment() {
        let newAssignment = Assignment(
            title: title,
            dueDate: dueDate,
            category: category,
            subjectTag: subjectTag,
            priority: priority,
            notes: notes,
            reminderDate: hasReminder ? reminderDate : nil
        )
        
        store.addAssignment(newAssignment)
        
        if hasReminder {
            NotificationManager.instance.scheduleNotification(assignment: newAssignment)
        }
        dismiss()
    }
}
