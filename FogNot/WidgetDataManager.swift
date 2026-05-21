import Foundation
import WidgetKit

// 🌟 ウィジェットの小さな画面でも扱いやすいように、タイトルと期限だけにした軽量データ
struct SharedAssignment: Codable, Hashable {
    let title: String
    let dueDate: Date
}

class WidgetDataManager {
    // ⚠️ App Groupの名前（バッチリです！）
    static let sharedBoxName = "group.com.Manato.FogNot"
    
    static func save(assignments: [Assignment]) {
        // 1. 期限が近い順に並び替える
        let sorted = assignments.sorted { $0.dueDate < $1.dueDate }
        
        // 2. ウィジェット用に「タイトル」と「期限」だけを抽出し、最大5件に絞る
        let sharedData = sorted.prefix(5).map { SharedAssignment(title: $0.title, dueDate: $0.dueDate) }
        
        // 3. 宝箱（UserDefaults）に保存する
        if let encoded = try? JSONEncoder().encode(sharedData),
           let userDefaults = UserDefaults(suiteName: sharedBoxName) {
            
            userDefaults.set(encoded, forKey: "widgetData")
            print("📦 宝箱に \(sharedData.count) 件の課題を入れました！")
            
            // 4. 「データが更新されたよ！」とウィジェットの画面をリロードさせる
            WidgetCenter.shared.reloadAllTimelines()
            
        } else {
            // 失敗した時のメッセージ
            print("❌ 宝箱が見つかりません！App Groupの名前が間違っているかも？")
        }
    }
}
