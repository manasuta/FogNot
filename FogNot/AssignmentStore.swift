import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class AssignmentStore: ObservableObject {
    @Published var assignments: [Assignment] = [] {
        didSet {
            WidgetDataManager.save(assignments: assignments, currentUserId: userId)
        }
    }
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var userId: String { Auth.auth().currentUser?.uid ?? "" }

    init() {
        fetchAssignments()
    }

    deinit {
        listenerRegistration?.remove()
    }

    func fetchAssignments() {
        listenerRegistration = db.collection("assignments").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self else { return }
            if let error = error {
                print("❌ データ取得失敗: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            self.assignments = documents.compactMap { try? $0.data(as: Assignment.self) }
        }
    }

    func addAssignment(_ assignment: Assignment) {
        assignments.append(assignment)
        do {
            try db.collection("assignments").document(assignment.id).setData(from: assignment) { [weak self] error in
                if let error = error {
                    print("❌ 追加失敗（Firestoreルールを確認）: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.assignments.removeAll { $0.id == assignment.id }
                    }
                }
            }
        } catch {
            print("❌ エンコード失敗: \(error.localizedDescription)")
            assignments.removeAll { $0.id == assignment.id }
        }
    }

    func updateAssignment(_ assignment: Assignment) {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments[index] = assignment
        }
        do {
            try db.collection("assignments").document(assignment.id).setData(from: assignment) { error in
                if let error = error {
                    print("❌ 更新失敗（Firestoreルールを確認）: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ エンコード失敗: \(error.localizedDescription)")
        }
    }

    func deleteAssignment(_ assignment: Assignment) {
        assignments.removeAll { $0.id == assignment.id }
        db.collection("assignments").document(assignment.id).delete { error in
            if let error = error {
                print("❌ 削除失敗（Firestoreルールを確認）: \(error.localizedDescription)")
            }
        }
    }

    func toggleCompletion(for assignment: Assignment) {
        var updated = assignment
        if let index = updated.completedBy.firstIndex(of: userId) {
            updated.completedBy.remove(at: index)
        } else {
            updated.completedBy.append(userId)
        }
        try? db.collection("assignments").document(updated.id).setData(from: updated)
    }
}
