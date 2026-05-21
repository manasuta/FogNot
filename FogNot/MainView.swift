import SwiftUI

struct MainView: View {
    // 💡ここを追加！：クラウドマネージャーを誕生させる
    @StateObject private var store = AssignmentStore()
    
    var body: some View {
        TabView {
            // 1. ホーム（共同管理）
            CollaborativeView()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
            
            // 2. 個人管理
            PersonalView()
                .tabItem {
                    Label("個人", systemImage: "person")
                }
            
            // 3. カレンダー
            CalendarView()
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
        }
        // 💡ここを追加！：アプリ全体（TabViewの中身すべて）にマネージャーを配る
        .environmentObject(store)
    }
}
