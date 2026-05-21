//
//  WelcomeView.swift
//  FogNot
//
//  Created by 上野愛翔 on 2026/04/08.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var store = AssignmentStore()
    @State private var shouldNavigate = false
    
    var body: some View {
        if shouldNavigate {
            MainView() // 起動後はメイン画面へ
        } else {
            VStack(spacing: 30) {
                Spacer()
                
                // ロゴ
                ZStack {
                    Image(systemName: "cloud")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "34495e"))
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .offset(x: 35, y: 35)
                }
                
                // テキスト群
                VStack(spacing: 10) {
                    Text("FogNot")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(hex: "2c3e50"))
                    Text("課題の霧を晴らす")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text("forget × fog × not\n提出忘れをなくす、大学生のための課題管理アプリ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding(.top)
                
                // 特徴カード
                VStack(spacing: 15) {
                    FeatureCardView(icon: "cloud", color: .blue, title: "共同編集", description: "みんなで課題を共有")
                    FeatureCardView(icon: "checkmark.circle", color: .green, title: "個人管理", description: "自分だけの課題も整理")
                    FeatureCardView(icon: "bell", color: .purple, title: "スマート通知", description: "提出期限を見逃さない")
                }
                
                Spacer()
                
                // はじめるボタン
                Button(action: {
                    withAnimation { shouldNavigate = true }
                }) {
                    Text("はじめる")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 15)
                        .background(Color(hex: "2c3e50"))
                        .cornerRadius(25)
                    
                }
                
                Spacer()
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
        }
    }
}

// 補助的なFeatureCardView
struct FeatureCardView: View {
    var icon: String
    var color: Color
    var title: String
    var description: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(color.opacity(0.1))
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.bold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
