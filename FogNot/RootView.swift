import SwiftUI
import FirebaseAuth

struct RootView: View {
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @State private var authHandle: AuthStateDidChangeListenerHandle?

    var body: some View {
        Group {
            if isLoggedIn {
                WelcomeView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            authHandle = Auth.auth().addStateDidChangeListener { _, user in
                isLoggedIn = (user != nil)
            }
        }
        .onDisappear {
            if let handle = authHandle {
                Auth.auth().removeStateDidChangeListener(handle)
                authHandle = nil
            }
        }
    }
}
