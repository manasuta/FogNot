import SwiftUI
import FirebaseAuth

struct AssignmentListView: View {
    @EnvironmentObject var store: AssignmentStore
    var category: AssignmentCategory
    var title: String
    var subtitle: String
    
    @State private var showingAddSheet = false
    @State private var sortOption: SortOption = .dueDate
    // 🌟 選ばれている科目を記憶する変数
    @State private var selectedSubject: SubjectTag? = nil
    
    // 🌟 フィルターロジック
    var filteredAssignments: [Assignment] {
        var list = store.assignments.filter { $0.category == category }
        
        if let subject = selectedSubject {
            list = list.filter { $0.subjectTag == subject }
        }
        
        switch sortOption {
        case .dueDate: return list.sorted(by: { $0.dueDate < $1.dueDate })
        case .priority: return list.sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // 1. ヘッダー（アイコン追加＆「…」削除）
                        HStack(spacing: 16) {
                            if category == .personal {
                                if let photoURL = Auth.auth().currentUser?.photoURL {
                                    AsyncImage(url: photoURL) { image in
                                        image.resizable().scaledToFill().frame(width: 56, height: 56).clipShape(Circle())
                                    } placeholder: {
                                        ProgressView().frame(width: 56, height: 56)
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill").resizable().frame(width: 56, height: 56).foregroundColor(Color(uiColor: .systemGray3))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    if category == .collaborative {
                                        Image(systemName: "house.fill").font(.system(size: 24)).foregroundColor(Color(hex: "34495e"))
                                    }
                                    Text(title).font(.system(size: 28, weight: .bold))
                                }
                                Text(subtitle).font(.system(size: 14)).foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                        
                        // 🌟 2. 科目フィルター（復活！）
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterButton(title: "すべて", icon: "square.grid.2x2", color: .gray, isSelected: selectedSubject == nil) {
                                    withAnimation { selectedSubject = nil }
                                }
                                ForEach(SubjectTag.allCases, id: \.self) { tag in
                                    FilterButton(title: tag.rawValue, icon: getSubjectIcon(tag), color: getSubjectColor(tag), isSelected: selectedSubject == tag) {
                                        withAnimation { selectedSubject = tag }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        
                        // 3. コントロールバー
                        HStack {
                            Menu {
                                Button(action: { sortOption = .dueDate }) { Label("期限順", systemImage: "clock") }
                                Button(action: { sortOption = .priority }) { Label("優先度順", systemImage: "exclamationmark.circle") }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text(sortOption == .dueDate ? "期限順" : "優先度順")
                                }
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(Color.white).cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button(action: { showingAddSheet = true }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("課題を追加")
                                }
                                .fontWeight(.bold).foregroundColor(.white)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color(hex: "34495e")).cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // 4. リスト本体
                                                if filteredAssignments.isEmpty {
                                                    Text("表示する課題がありません")
                                                        .font(.system(size: 16)).foregroundColor(.gray)
                                                        .frame(maxWidth: .infinity, alignment: .center)
                                                        .padding(.top, 40)
                                                } else {
                                                    LazyVStack(spacing: 12) {
                                                        ForEach(filteredAssignments) { assignment in
                                                            // 🌟 ここに「編集画面へのリンク（扉）」を追加！
                                                            NavigationLink(destination: EditAssignmentView(assignment: assignment)) {
                                                                AssignmentCell(assignment: assignment)
                                                            }
                                                            .buttonStyle(PlainButtonStyle()) // 💡タップした時にカード全体が青く変色するのを防ぐおまじない
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)
                                                }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSheet) {
                AddAssignmentView()
            }
        }
        .environment(\.colorScheme, .light)
    }
}

// 🌟 科目フィルター用のデザインパーツ
struct FilterButton: View {
    var title: String
    var icon: String
    var color: Color
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title).fontWeight(.bold)
            }
            .font(.system(size: 14))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .white : color)
            .background(isSelected ? color : Color.white)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(color, lineWidth: 1))
        }
    }
}

func getSubjectIcon(_ tag: SubjectTag) -> String {
    switch tag.rawValue {
    case "知能": return "brain.head.profile"
    case "サイバー": return "cpu"
    case "実世界": return "globe.asia.australia"
    case "共通": return "book.closed"
    default: return "folder"
    }
}

func getSubjectColor(_ tag: SubjectTag) -> Color {
    switch tag.rawValue {
    case "知能": return .blue
    case "サイバー": return .purple
    case "実世界": return .green
    case "共通": return .orange
    default: return .gray
    }
}

// 🌟 抜け落ちていた並び替えのルールを追加！
enum SortOption {
    case dueDate
    case priority
}
