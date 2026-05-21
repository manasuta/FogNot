import SwiftUI
import FirebaseAuth

struct AssignmentCell: View {
    var assignment: Assignment
    @EnvironmentObject var store: AssignmentStore
    
    private var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d"
        return formatter
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左側：チェックボタン
            Button(action: {
                withAnimation { store.toggleCompletion(for: assignment) }
            }) {
                if assignment.isCompleted(for: currentUserId) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 24))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(Color(uiColor: .systemGray4))
                        .font(.system(size: 24))
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
            
            // 中央：テキスト情報
            VStack(alignment: .leading, spacing: 8) {
                Text(assignment.title)
                    .strikethrough(assignment.isCompleted(for: currentUserId))
                    .foregroundColor(assignment.isCompleted(for: currentUserId) ? .gray : .primary)
                    .font(.system(size: 16, weight: .medium))
                
                // タグ
                if let subjectTag = assignment.subjectTag, subjectTag != .common {
                    HStack(spacing: 4) {
                        Image(systemName: subjectTag.iconName)
                        Text(subjectTag.rawValue)
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(subjectTag.color.opacity(0.1))
                    .foregroundColor(subjectTag.color)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(subjectTag.color.opacity(0.3), lineWidth: 1))
                }
                
                // 日付と通知
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(dateFormatter.string(from: assignment.dueDate))
                    }
                    if let _ = assignment.reminderDate {
                        HStack(spacing: 4) {
                            Image(systemName: "bell")
                            Text(dateFormatter.string(from: assignment.dueDate)) // 簡略化のため期限を表示
                        }
                    }
                }
                .font(.system(size: 13))
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 右側：優先度フラグ
            if assignment.priority == .red {
                Image(systemName: "flag.fill").foregroundColor(.red).font(.system(size: 20))
            } else if assignment.priority == .yellow {
                Image(systemName: "flag.fill").foregroundColor(.yellow).font(.system(size: 20))
            } else {
                Image(systemName: "flag").foregroundColor(Color(uiColor: .systemGray4)).font(.system(size: 20))
            }
        }
        .padding(16)
        // 🌟 画像のような「白いカードに薄い影・枠線」のスタイル
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}
