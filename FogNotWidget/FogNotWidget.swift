import WidgetKit
import SwiftUI

// MARK: - SharedAssignment（WidgetDataManager.swift と JSON 構造を合わせること）
struct SharedAssignment: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var dueDate: Date
    var category: String
    var subjectTag: String?
    var priority: Int

    func daysRemaining(from now: Date = Date()) -> Int {
        let cal = Calendar.current
        let d1 = cal.startOfDay(for: now)
        let d2 = cal.startOfDay(for: dueDate)
        return cal.dateComponents([.day], from: d1, to: d2).day ?? 0
    }
}

// MARK: - 緊急度
enum Urgency {
    case overdue(Int)
    case today
    case urgent(Int)
    case soon(Int)
    case calm(Int)

    static func of(days: Int) -> Urgency {
        if days < 0  { return .overdue(-days) }
        if days == 0 { return .today }
        if days <= 2 { return .urgent(days) }
        if days <= 5 { return .soon(days) }
        return .calm(days)
    }

    var color: Color {
        switch self {
        case .overdue, .today, .urgent: return Color(red: 1.0, green: 0.23, blue: 0.19)
        case .soon:                     return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .calm:                     return Color(red: 0.56, green: 0.56, blue: 0.58)
        }
    }

    var label: String {
        switch self {
        case .overdue(let n):            return "\(n)日超過"
        case .today:                     return "今日"
        case .urgent(let n), .soon(let n), .calm(let n): return "あと\(n)日"
        }
    }

    var isFilled: Bool {
        if case .overdue = self { return true }
        if case .today   = self { return true }
        return false
    }
}

// MARK: - 科目・カテゴリ
extension SharedAssignment {
    var subjectColor: Color {
        switch subjectTag {
        case "知能":     return .blue
        case "サイバー": return .purple
        case "実世界":   return .green
        case "共通":     return .orange
        default:        return .gray
        }
    }
    var subjectIcon: String {
        switch subjectTag {
        case "知能":     return "brain.head.profile"
        case "サイバー": return "cpu"
        case "実世界":   return "globe.asia.australia"
        case "共通":     return "book.closed"
        default:        return "folder"
        }
    }
    var categoryIcon: String { category == "共同" ? "house.fill" : "person.fill" }
}

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), tasks: Self.sampleTasks)
    }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), tasks: loadTasks()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let now = Date()
        let entry = SimpleEntry(date: now, tasks: loadTasks())
        let cal = Calendar.current
        let nextMidnight = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 1),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func loadTasks() -> [SharedAssignment] {
        guard let defaults = UserDefaults(suiteName: "group.com.Manato.FogNot"),
              let data = defaults.data(forKey: "widgetData"),
              let tasks = try? JSONDecoder().decode([SharedAssignment].self, from: data)
        else { return [] }
        return tasks
    }

    static let sampleTasks: [SharedAssignment] = [
        .init(id: "1", title: "アルゴリズム論 第6回課題",
              dueDate: Date(), category: "個人", subjectTag: "知能", priority: 2),
        .init(id: "2", title: "セキュリティ実習レポート",
              dueDate: Date().addingTimeInterval(86400 * 2), category: "共同", subjectTag: "サイバー", priority: 2),
        .init(id: "3", title: "IoT演習プレゼン資料",
              dueDate: Date().addingTimeInterval(86400 * 4), category: "共同", subjectTag: "実世界", priority: 1),
    ]
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tasks: [SharedAssignment]
}

// MARK: - 共有パーツ
struct SubjectPill: View {
    let task: SharedAssignment
    var compact: Bool = false
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: task.subjectIcon)
                .font(.system(size: compact ? 8 : 10, weight: .semibold))
            Text(task.subjectTag ?? "")
                .font(.system(size: compact ? 9 : 10, weight: .semibold))
        }
        .padding(.horizontal, compact ? 5 : 6)
        .padding(.vertical, compact ? 1.5 : 2)
        .foregroundColor(task.subjectColor)
        .background(task.subjectColor.opacity(0.12))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(task.subjectColor.opacity(0.2), lineWidth: 0.5))
    }
}

struct DaysPill: View {
    let urgency: Urgency
    var compact: Bool = false
    var body: some View {
        Text(urgency.label)
            .font(.system(size: compact ? 10 : 11, weight: .bold))
            .padding(.horizontal, compact ? 5 : 6)
            .padding(.vertical, compact ? 1.5 : 2)
            .foregroundColor(urgency.isFilled ? .white : urgency.color)
            .background(urgency.isFilled ? urgency.color : urgency.color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

@ViewBuilder
func priorityFlag(_ priority: Int, size: CGFloat = 11) -> some View {
    if priority == 2 {
        Image(systemName: "flag.fill").font(.system(size: size)).foregroundColor(.red)
    } else if priority == 1 {
        Image(systemName: "flag.fill").font(.system(size: size)).foregroundColor(.yellow)
    }
}

// MARK: - Small
struct SmallWidgetView: View {
    let tasks: [SharedAssignment]
    private let accent = Color(red: 0.2, green: 0.29, blue: 0.37)

    var body: some View {
        if let hero = tasks.first {
            let u = Urgency.of(days: hero.daysRemaining())
            let n = hero.daysRemaining()
            HStack(spacing: 0) {
                Rectangle().fill(u.color).frame(width: 4)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label("FogNot", systemImage: "cloud.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(accent)
                        Spacer()
                        Text("\(tasks.count)件")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    Group {
                        if case .overdue = u {
                            HStack(spacing: 3) {
                                Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 11))
                                Text("期限超過").font(.system(size: 10, weight: .bold))
                            }.foregroundColor(u.color)
                        } else if case .today = u {
                            Text("今日が締切").font(.system(size: 10, weight: .bold)).foregroundColor(u.color)
                        } else {
                            Text("つぎの締切").font(.system(size: 10, weight: .semibold)).foregroundColor(.secondary)
                        }
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(abs(n))")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                        Text("日").font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(u.color)
                    Text(hero.title)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        SubjectPill(task: hero, compact: true)
                        Spacer()
                        if tasks.count > 1 {
                            Text("+\(tasks.count - 1)")
                                .font(.system(size: 9.5, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        priorityFlag(hero.priority, size: 10)
                    }
                }
                .padding(12)
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32)).foregroundColor(.green)
                Text("課題なし！").font(.system(size: 12, weight: .semibold))
            }
        }
    }
}

// MARK: - Medium
struct MediumRowView: View {
    let task: SharedAssignment
    var body: some View {
        let u = Urgency.of(days: task.daysRemaining())
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2).fill(u.color).frame(width: 3)
            ZStack {
                RoundedRectangle(cornerRadius: 6).fill(task.subjectColor.opacity(0.12))
                Image(systemName: task.subjectIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(task.subjectColor)
            }.frame(width: 22, height: 22)
            Text(task.title)
                .font(.system(size: 12.5, weight: .semibold))
                .lineLimit(1)
            priorityFlag(task.priority, size: 11)
            Spacer(minLength: 4)
            DaysPill(urgency: u, compact: true)
        }
        .padding(.vertical, 3)
    }
}

struct MediumWidgetView: View {
    let tasks: [SharedAssignment]
    private let accent = Color(red: 0.2, green: 0.29, blue: 0.37)

    var body: some View {
        let overdue = tasks.filter { $0.daysRemaining() < 0 }.count
        let weekly  = tasks.filter { (0...7).contains($0.daysRemaining()) }.count
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label("直近の課題", systemImage: "cloud.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accent)
                Spacer()
                if overdue > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 9))
                        Text("\(overdue)").font(.system(size: 10.5, weight: .bold))
                    }.foregroundColor(.red)
                }
                Text("今週 \(weekly)件")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            ForEach(tasks.prefix(3)) { task in
                MediumRowView(task: task)
            }
            if tasks.isEmpty {
                Spacer()
                Text("課題はありません 🎉")
                    .font(.system(size: 12)).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }
}

// MARK: - Large
struct LargeRowView: View {
    let task: SharedAssignment
    var body: some View {
        let u = Urgency.of(days: task.daysRemaining())
        HStack(spacing: 9) {
            RoundedRectangle(cornerRadius: 2).fill(u.color).frame(width: 3)
            ZStack {
                RoundedRectangle(cornerRadius: 7).fill(task.subjectColor.opacity(0.12))
                Image(systemName: task.subjectIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(task.subjectColor)
            }.frame(width: 26, height: 26)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(task.title).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                    priorityFlag(task.priority, size: 11)
                }
                HStack(spacing: 4) {
                    Image(systemName: task.categoryIcon).font(.system(size: 9))
                    Text(task.category).font(.system(size: 10, weight: .medium))
                    Text("·").font(.system(size: 10))
                    Text(task.subjectTag ?? "")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(task.subjectColor)
                }.foregroundColor(.secondary)
            }
            Spacer(minLength: 4)
            DaysPill(urgency: u)
        }
        .padding(.vertical, 5)
    }
}

struct LargeWidgetView: View {
    let tasks: [SharedAssignment]
    let date: Date
    private let accent = Color(red: 0.2, green: 0.29, blue: 0.37)

    var body: some View {
        let overdue = tasks.filter { $0.daysRemaining() < 0 }.count
        let urgent  = tasks.filter { (0...2).contains($0.daysRemaining()) }.count
        let weekly  = tasks.filter { (0...7).contains($0.daysRemaining()) }.count

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("直近の課題", systemImage: "cloud.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(accent)
                Spacer()
                Text("全\(tasks.count)件").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
            }
            HStack(spacing: 6) {
                if overdue > 0 {
                    summaryBadge("期限超過 \(overdue)", icon: "exclamationmark.triangle.fill", color: .red)
                }
                summaryBadge("緊急 \(urgent)", icon: "clock.fill", color: .red)
                summaryBadge("今週 \(weekly)", icon: nil, color: .gray)
                Spacer()
            }
            Divider()
            ForEach(tasks.prefix(6)) { task in
                LargeRowView(task: task)
            }
            if tasks.isEmpty {
                Spacer()
                Text("課題はありません 🎉").font(.system(size: 13)).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Spacer(minLength: 0)
            Divider()
            HStack {
                Text("タップで FogNot を開く").font(.system(size: 10)).foregroundColor(.secondary)
                Spacer()
                Text("更新 \(date, format: .dateTime.hour().minute())")
                    .font(.system(size: 10)).foregroundColor(.secondary)
            }
        }
        .padding(16)
    }

    @ViewBuilder
    func summaryBadge(_ text: String, icon: String?, color: Color) -> some View {
        HStack(spacing: 3) {
            if let icon { Image(systemName: icon).font(.system(size: 10)) }
            Text(text).font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8).padding(.vertical, 3.5)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Entry View
struct FogNotWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(tasks: entry.tasks)
        case .systemMedium: MediumWidgetView(tasks: entry.tasks)
        case .systemLarge:  LargeWidgetView(tasks: entry.tasks, date: entry.date)
        default:            MediumWidgetView(tasks: entry.tasks)
        }
    }
}

// MARK: - Widget
struct FogNotWidget: Widget {
    let kind: String = "FogNotWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FogNotWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) { Color(.systemBackground) }
        }
        .configurationDisplayName("直近の課題")
        .description("締切が近い課題を表示します。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
