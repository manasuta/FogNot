import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class AssignmentStore: ObservableObject {
    @Published var assignments: [Assignment] = [] {
        didSet {
            // 🌟 課題リストに変化（追加・編集・削除など）があったら、自動で宝箱も最新にする！
            WidgetDataManager.save(assignments: assignments)
        }
    }
    private let db = Firestore.firestore()
    private var userId: String { Auth.auth().currentUser?.uid ?? "" }

    init() {
        fetchAssignments()
    }

    func fetchAssignments() {
        db.collection("assignments").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            self.assignments = documents.compactMap { try? $0.data(as: Assignment.self) }
        }
    }

    func addAssignment(_ assignment: Assignment) {
        try? db.collection("assignments").document(assignment.id).setData(from: assignment)
    }
    
    // 💡追加：編集したデータを上書き保存する
    func updateAssignment(_ assignment: Assignment) {
        try? db.collection("assignments").document(assignment.id).setData(from: assignment)
    }

    func toggleCompletion(for assignment: Assignment) {
        var updatedAssignment = assignment
        if let index = updatedAssignment.completedBy.firstIndex(of: userId) {
            updatedAssignment.completedBy.remove(at: index)
        } else {
            updatedAssignment.completedBy.append(userId)
        }
        try? db.collection("assignments").document(updatedAssignment.id).setData(from: updatedAssignment)
    }
}
