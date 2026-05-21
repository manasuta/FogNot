//
//  CalenderSyncManager.swift
//  FogNot
//
//  Created by 上野愛翔 on 2026/04/09.
//

import Foundation
import EventKit

class CalendarSyncManager {
    static let shared = CalendarSyncManager()
    private let eventStore = EKEventStore()

    // カレンダーへの書き込み許可を求める
    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // 課題をカレンダーに登録する
    func syncAssignment(_ assignment: Assignment) {
        requestAccess { granted in
            guard granted else { return }

            // すでに同じ課題が登録されていないか確認（簡易版として新規作成のみ解説）
            let event = EKEvent(eventStore: self.eventStore)
            event.title = "【課題】\(assignment.title)"
            event.notes = assignment.notes
            event.startDate = assignment.dueDate
            event.endDate = assignment.dueDate.addingTimeInterval(3600) // 1時間の予定として登録
            event.calendar = self.eventStore.defaultCalendarForNewEvents

            do {
                try self.eventStore.save(event, span: .thisEvent)
                print("カレンダーに登録成功！")
            } catch {
                print("登録失敗: \(error)")
            }
        }
    }
}
