import SwiftUI
import FirebaseCore
import FirebaseAuth
// 💡 import SwiftData はもう不要なので削除しました！

@main
struct FogNotApp: App {
    
    // 💡 以前ここにあった sharedModelContainer のブロックは
    // クラウド化に伴い不要になったので、まるごと削除しました！

    init() {
        FirebaseApp.configure()
        //Auth.auth().signOut()
        
        NotificationManager.instance.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            RootView().preferredColorScheme(.light)
        }
        // 💡 ここにあった .modelContainer(...) も削除しました！
    }
}

