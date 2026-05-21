//
//  RootView.swift
//  FogNot
//
//  Created by 上野愛翔 on 2026/04/08.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    // ログイン状態を管理する変数（初期値はFirebaseに確認する）
    @State private var isLoggedIn: Bool = Auth.auth().currentUser != nil
    
    var body: some View {
        Group {
            if isLoggedIn {
                // ログイン済みならいつもの画面へ！
                WelcomeView()
            } else {
                // 未ログインならログイン画面へ！
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // アプリ起動中にもしログイン状態が変わったら感知する
            Auth.auth().addStateDidChangeListener { auth, user in
                isLoggedIn = (user != nil)
            }
        }
    }
}
//tonama1226@gmail.com
