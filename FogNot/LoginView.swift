import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore // 💡先ほどのエラー修正も入ってます！

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoginMode = true
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // ロゴとタイトル
                Image(systemName: "cloud.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "34495e"))
                    .padding(.bottom, 10)
                
                Text("FogNot")
                    .font(.system(size: 32, weight: .bold))
                
                Text(isLoginMode ? "おかえりなさい！" : "新しくアカウントを作成します")
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                // メールアドレス入力フォーム
                VStack(spacing: 15) {
                    TextField("メールアドレス", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                    
                    SecureField("パスワード（6文字以上）", text: $password)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }
                
                // 1. メールアドレスでログイン/登録ボタン
                Button(action: handleEmailAction) {
                    Text(isLoginMode ? "メールアドレスでログイン" : "メールアドレスで登録")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "34495e"))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                // 💡ここが抜けていた可能性が高いです！
                // 2. Googleログインボタン
                Button(action: signInWithGoogle) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text("Googleでログイン")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal, 30)
                
                // 3. モード切り替えボタン
                Button(action: {
                    isLoginMode.toggle()
                    errorMessage = ""
                }) {
                    Text(isLoginMode ? "アカウントをお持ちでない方はこちら" : "すでにアカウントをお持ちの方はこちら")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
    
    // メールアドレスの処理
    private func handleEmailAction() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "メールアドレスとパスワードを入力してください。"
            return
        }
        
        if isLoginMode {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error { errorMessage = "ログイン失敗: \(error.localizedDescription)" }
                else { isLoggedIn = true }
            }
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error { errorMessage = "登録失敗: \(error.localizedDescription)" }
                else { isLoggedIn = true }
            }
        }
    }
    
    // Googleログインの裏側処理
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            errorMessage = "画面の取得に失敗しました"
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Googleログインキャンセル: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                errorMessage = "Googleの認証情報の取得に失敗しました"
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    errorMessage = "Firebaseログイン失敗: \(error.localizedDescription)"
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}
