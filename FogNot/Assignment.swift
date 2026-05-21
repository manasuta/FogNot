import Foundation
import SwiftUI
import FirebaseFirestore

// 🌟 課題データの設計図
struct Assignment: Identifiable, Codable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var dueDate: Date
    var category: AssignmentCategory
    var subjectTag: SubjectTag?
    var priority: Priority = .none
    var notes: String = ""
    var reminderDate: Date?
    var completedBy: [String] = []

    // ログインしているユーザーが完了しているか判定する機能
    func isCompleted(for userId: String) -> Bool {
        completedBy.contains(userId)
    }
}

// 🌟 カテゴリ（個人 or 共同）
enum AssignmentCategory: String, Codable, CaseIterable {
    case collaborative = "共同"
    case personal = "個人"
}

// 🌟 科目タグ（情報学部コース仕様！）
enum SubjectTag: String, Codable, CaseIterable {
    case intelligence = "知能"
    case cyber = "サイバー"
    case realWorld = "実世界"
    case common = "共通"
    
    // コースごとのアイコン
    var iconName: String {
        switch self {
        case .intelligence: return "brain.head.profile"
        case .cyber: return "cpu"
        case .realWorld: return "globe.asia.australia"
        case .common: return "book.closed"
        }
    }
    
    // コースごとのテーマカラー
    var color: Color {
        switch self {
        case .intelligence: return .blue
        case .cyber: return .purple
        case .realWorld: return .green
        case .common: return .orange
        }
    }
}

// 🌟 優先度
enum Priority: Int, Codable, Comparable {
    case none = 0
    case yellow = 1
    case red = 2
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
