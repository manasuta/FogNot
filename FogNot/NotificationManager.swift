import Foundation
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(assignment: Assignment) {
        guard let reminderDate = assignment.reminderDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "課題のリマインダー"
        content.body = "\(assignment.title) の期限が近づいています！"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 💡 変更： assignment.id.uuidString から .uuidString を削除してスッキリさせました！
        let request = UNNotificationRequest(identifier: assignment.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知のセットに失敗しました: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(for assignment: Assignment) {
        // 💡 変更： ここも .uuidString を削除しました！
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [assignment.id])
    }
}
