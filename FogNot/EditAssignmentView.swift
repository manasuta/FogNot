import SwiftUI
import FirebaseFirestore

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
    
    // 🌟 削除確認用
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                Form {
                    Section(header: Text("基本情報").foregroundColor(.gray)) {
                        TextField("課題名", text: $title)
                        TextField("内容（メモ、任意）", text: $notes)
                    }
                    
                    Section(header: Text("分類").foregroundColor(.gray)) {
                        // 🌟 Apple純正の切り替えボタン（左：共同、右：個人の順）
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
                        DatePicker("提出期限", selection: $dueDate)
                        Toggle("リマインダー", isOn: $hasReminder)
                        if hasReminder {
                            DatePicker("通知時間", selection: $reminderDate)
                        }
                    }
                    
                    // 🌟 削除ボタン
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
            // 🌟 削除確認アラート
            .alert("課題の削除", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) { deleteAssignment() }
            } message: {
                Text("この課題を削除してもよろしいですか？この操作は取り消せません。")
            }
        }
        .environment(\.colorScheme, .light)
    }
    
    // 保存の処理
    // ==========================================
        // 1. 保存の処理（さっき追加したカレンダー同期入り！）
        // ==========================================
        private func saveChanges() {
            NotificationManager.instance.cancelNotification(for: assignment)
            
            var updatedAssignment = assignment
            updatedAssignment.title = title
            updatedAssignment.notes = notes
            updatedAssignment.dueDate = dueDate
            updatedAssignment.category = category
            updatedAssignment.subjectTag = subjectTag
            updatedAssignment.priority = priority
            updatedAssignment.reminderDate = hasReminder ? reminderDate : nil
            
            store.updateAssignment(updatedAssignment)
            
            if hasReminder {
                NotificationManager.instance.scheduleNotification(assignment: updatedAssignment)
            }
            
            // カレンダーに同期
            CalendarSyncManager.shared.syncAssignment(updatedAssignment)
            
            dismiss()
        }
        
        // ==========================================
        // 🌟 2. 削除の処理（これが消えちゃってました！）
        // ==========================================
        private func deleteAssignment() {
            // 1. セットされていた通知をキャンセル
            NotificationManager.instance.cancelNotification(for: assignment)
            
            // 2. クラウド（Firestore）からデータを削除
            Firestore.firestore().collection("assignments").document(assignment.id).delete()
            
            // 3. 画面を閉じる
            dismiss()
        }
    } // ← ファイルの一番最後にある、画面全体を閉じる波括弧
