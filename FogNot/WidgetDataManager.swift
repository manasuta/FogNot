import Foundation
import WidgetKit

struct SharedAssignment: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var dueDate: Date
    var category: String
    var subjectTag: String?
    var priority: Int

    func daysRemaining(from now: Date = Date()) -> Int {
        let cal = Calendar.current
        let d1 = cal.startOfDay(for: now)
        let d2 = cal.startOfDay(for: dueDate)
        return cal.dateComponents([.day], from: d1, to: d2).day ?? 0
    }
}

class WidgetDataManager {
    static let sharedBoxName = "group.com.Manato.FogNot"
    static let widgetDataKey = "widgetData"

    static func save(assignments: [Assignment], currentUserId: String) {
        let filtered = assignments
            .filter { !$0.isCompleted(for: currentUserId) }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(10)

        let payload: [SharedAssignment] = filtered.map { a in
            SharedAssignment(
                id: a.id,
                title: a.title,
                dueDate: a.dueDate,
                category: a.category.rawValue,
                subjectTag: a.subjectTag?.rawValue,
                priority: a.priority.rawValue
            )
        }

        guard let defaults = UserDefaults(suiteName: sharedBoxName),
              let encoded = try? JSONEncoder().encode(payload) else {
            print("❌ App Group の保存に失敗")
            return
        }
        defaults.set(encoded, forKey: widgetDataKey)
        print("📦 \(payload.count) 件をウィジェット用に保存")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
