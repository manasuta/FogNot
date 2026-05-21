//
//  PersonalView.swift
//  FogNot
//
//  Created by 上野愛翔 on 2026/04/08.
//

import SwiftUI

struct PersonalView: View {
    var body: some View {
        AssignmentListView(
            category: .personal,
            title: "個人",
            subtitle: "自分だけの課題管理エリア"
        )
    }
}
