import WidgetKit
import SwiftUI

struct CafeVisitEntry: TimelineEntry {
  let date: Date
  let snapshot: CafeVisitSnapshot
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> CafeVisitEntry {
    CafeVisitEntry(date: Date(), snapshot: .sample)
  }

  func getSnapshot(in context: Context, completion: @escaping (CafeVisitEntry) -> Void) {
    // 위젯 갤러리에서는 빈 화면 대신 예시 값을 보여준다.
    let snapshot: CafeVisitSnapshot = context.isPreview ? .sample : (RealmProvider.snapshot() ?? .empty)
    completion(CafeVisitEntry(date: Date(), snapshot: snapshot))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<CafeVisitEntry>) -> Void) {
    let now = Date()
    let entry = CafeVisitEntry(date: now, snapshot: RealmProvider.snapshot() ?? .empty)
    completion(Timeline(entries: [entry], policy: .after(Self.nextMidnight(after: now))))
  }

  /// 달이 바뀌면 이번 달 방문 수가 0으로 돌아가야 하므로 자정에 다시 그린다.
  /// 서머타임처럼 하루가 24시간이 아닌 날에도 어긋나지 않도록 캘린더로 계산한다.
  private static func nextMidnight(after date: Date, calendar: Calendar = .current) -> Date {
    let startOfToday = calendar.startOfDay(for: date)
    return calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date.addingTimeInterval(3600)
  }
}

// MARK: - Views

private struct MonthlyCountView: View {
  let count: Int

  var body: some View {
    VStack(spacing: 2) {
      Image(systemName: "cup.and.saucer.fill")
        .font(.title3)
        .foregroundStyle(Color("OrangeMainColor"))
      Text("이번 달 방문")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(.secondary)
      HStack(alignment: .firstTextBaseline, spacing: 2) {
        Text("\(count)")
          .font(.system(size: 32, weight: .bold))
          .foregroundStyle(Color("GreenMainColor"))
          .contentTransition(.numericText())
        Text("회")
          .font(.system(size: 14, weight: .bold))
          .foregroundStyle(.secondary)
      }
    }
  }
}

private struct RecentVisitView: View {
  let visit: CafeVisitSnapshot.Visit?
  let totalCount: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("최근 방문")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(.secondary)

      if let visit {
        Text(visit.name)
          .font(.system(size: 16, weight: .bold))
          .lineLimit(1)
        Text(visit.visitDate, format: .dateTime.month().day())
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
        HStack(spacing: 1) {
          ForEach(1...5, id: \.self) { star in
            Image(systemName: star <= visit.rate ? "star.fill" : "star")
              .font(.system(size: 9))
              .foregroundStyle(Color("OrangeMainColor"))
          }
        }
        Text("전체 \(totalCount)회")
          .font(.system(size: 11))
          .foregroundStyle(.tertiary)
      } else {
        Text("아직 기록이 없어요")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct WhatTheCoffeeWidgetEntryView: View {
  @Environment(\.widgetFamily) private var family
  var entry: CafeVisitEntry

  var body: some View {
    switch family {
    case .systemMedium:
      HStack(spacing: 16) {
        MonthlyCountView(count: entry.snapshot.monthlyCount)
        Divider()
        RecentVisitView(visit: entry.snapshot.recent, totalCount: entry.snapshot.totalCount)
      }
      .containerBackground(.fill.tertiary, for: .widget)

    case .accessoryCircular:
      VStack(spacing: 0) {
        Image(systemName: "cup.and.saucer.fill")
          .font(.system(size: 12))
        Text("\(entry.snapshot.monthlyCount)")
          .font(.system(size: 18, weight: .bold))
      }
      .containerBackground(.fill.tertiary, for: .widget)

    case .accessoryRectangular:
      VStack(alignment: .leading, spacing: 2) {
        Label("이번 달 \(entry.snapshot.monthlyCount)회", systemImage: "cup.and.saucer.fill")
          .font(.system(size: 14, weight: .bold))
        if let recent = entry.snapshot.recent {
          Text(recent.name)
            .font(.system(size: 12))
            .lineLimit(1)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .containerBackground(.fill.tertiary, for: .widget)

    default:
      MonthlyCountView(count: entry.snapshot.monthlyCount)
        .containerBackground(.fill.tertiary, for: .widget)
    }
  }
}

struct WhatTheCoffeeWidget: Widget {
  let kind = "WhatTheCoffeeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      WhatTheCoffeeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("커피 방문 기록")
    .description("이번 달 카페 방문 횟수와 최근 방문한 카페를 확인하세요.")
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
  }
}

#Preview("Small", as: .systemSmall) {
  WhatTheCoffeeWidget()
} timeline: {
  CafeVisitEntry(date: Date(), snapshot: .sample)
  CafeVisitEntry(date: Date(), snapshot: .empty)
}

#Preview("Medium", as: .systemMedium) {
  WhatTheCoffeeWidget()
} timeline: {
  CafeVisitEntry(date: Date(), snapshot: .sample)
  CafeVisitEntry(date: Date(), snapshot: .empty)
}
