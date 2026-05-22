import SwiftUI

struct EditAssignmentView: View {
    @EnvironmentObject var store: AssignmentStore
    @Environment(\.dismiss) private var dismiss

    var assignment: Assignment

    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date()
    @State private var category: AssignmentCategory = .collaborative
    @State private var subjectTag: SubjectTag = .common
    @State private var priority: Priority = .none
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var showingDeleteAlert = false

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            Form {
                Section(header: Text("基本情報").foregroundColor(.gray)) {
                    TextField("課題名", text: $title)
                    TextField("内容（メモ、任意）", text: $notes)
                }

                Section(header: Text("分類").foregroundColor(.gray)) {
                    Picker("カテゴリー", selection: $category) {
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

                Section {
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Spacer()
                            Text("課題を削除").fontWeight(.bold).foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("課題の編集")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            title = assignment.title
            notes = assignment.notes
            dueDate = assignment.dueDate
            category = assignment.category
            subjectTag = assignment.subjectTag ?? .common
            priority = assignment.priority
            if let reminder = assignment.reminderDate {
                hasReminder = true
                reminderDate = reminder
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") { dismiss() }.foregroundColor(.gray)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { saveChanges() }
                    .fontWeight(.bold)
                    .disabled(title.isEmpty)
                    .foregroundColor(title.isEmpty ? .gray : .blue)
            }
        }
        .alert("課題の削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) { deleteAssignment() }
        } message: {
            Text("この課題を削除してもよろしいですか？この操作は取り消せません。")
        }
        .environment(\.colorScheme, .light)
    }

    private func saveChanges() {
        NotificationManager.instance.cancelNotification(for: assignment)

        var updated = assignment
        updated.title = title
        updated.notes = notes
        updated.dueDate = dueDate
        updated.category = category
        updated.subjectTag = subjectTag
        updated.priority = priority
        updated.reminderDate = hasReminder ? reminderDate : nil

        store.updateAssignment(updated)

        if hasReminder {
            NotificationManager.instance.scheduleNotification(assignment: updated)
        }

        // カレンダー同期（※編集のたびに新規イベントが追加される。将来的にイベントIDの保持が必要）
        CalendarSyncManager.shared.syncAssignment(updated)

        dismiss()
    }

    private func deleteAssignment() {
        NotificationManager.instance.cancelNotification(for: assignment)
        store.deleteAssignment(assignment)
        dismiss()
    }
}
