import WidgetKit
import SwiftUI

// データ構造
struct SharedAssignment: Codable, Hashable {
    let title: String
    let dueDate: Date
}

// データの供給役
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), tasks: [])
    }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), tasks: loadTasks()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), tasks: loadTasks())
        completion(Timeline(entries: [entry], policy: .atEnd))
    }

    private func loadTasks() -> [SharedAssignment] {
        let sharedBoxName = "group.com.Manato.FogNot"
        guard let userDefaults = UserDefaults(suiteName: sharedBoxName),
              let data = userDefaults.data(forKey: "widgetData"),
              let tasks = try? JSONDecoder().decode([SharedAssignment].self, from: data) else {
            return []
        }
        return tasks
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tasks: [SharedAssignment]
}

// 画面のデザイン
struct FogNotWidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack(alignment: .leading) {
            Text("直近の課題").font(.caption).bold()
            ForEach(entry.tasks.prefix(3), id: \.self) { task in
                Text(task.title).font(.system(size: 12))
            }
        }.padding()
    }
}

// ウィジェットの設定
struct FogNotWidget: Widget {
    let kind: String = "FogNotWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FogNotWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
