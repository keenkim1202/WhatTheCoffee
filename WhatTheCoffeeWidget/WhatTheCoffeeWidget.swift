import WidgetKit
import SwiftUI
import AppIntents

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

  /// 숫자만 있으면 위젯이 계기판처럼 보인다. 상황에 맞는 한마디를 붙인다.
  private var message: String {
    switch count {
    case 0: return "이번 달 첫 잔은 언제?"
    case 1: return "이번 달 첫 잔"
    case 2...4: return "이번 달 방문"
    case 5...9: return "꾸준히 가는 중"
    case 10...19: return "벌써 열 잔 넘게"
    default: return "이 달의 단골"
    }
  }

  var body: some View {
    VStack(spacing: 2) {
      Image(systemName: "cup.and.saucer.fill")
        .font(.title3)
        .foregroundStyle(Color("OrangeMainColor"))
      Text(message)
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
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

  private static func dateText(for date: Date) -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) { return "오늘" }
    if calendar.isDateInYesterday(date) { return "어제" }
    return date.formatted(.dateTime.month().day())
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("최근 방문")
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(.secondary)

      if let visit {
        // 카페 이름과 방문 정보를 누르면 기록 탭으로 간다.
        // 버튼만 누를 수 있으면 나머지 영역은 눌러도 아무 데도 가지 않는 죽은 자리가 된다.
        Link(destination: WidgetRoute.records.url ?? Self.recordsFallbackURL) {
          VStack(alignment: .leading, spacing: 4) {
            Text(visit.name)
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(.primary)
              .lineLimit(1)
            HStack(spacing: 6) {
              // 눌러서 기록하면 이 날짜가 '오늘'로 바뀐다. 그게 눈에 보이는 결과가 된다.
              Text(Self.dateText(for: visit.visitDate))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
              HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { star in
                  Image(systemName: star <= visit.rate ? "star.fill" : "star")
                    .font(.system(size: 9))
                    .foregroundStyle(Color("OrangeMainColor"))
                }
              }
            }
          }
        }

        // 무엇이 일어나는지 버튼이 직접 말하도록 한다.
        // 카페 이름 바로 아래에 두어 어느 곳을 기록하는지도 드러낸다.
        Button(intent: AddVisitIntent(name: visit.name)) {
          Label("오늘 방문 기록", systemImage: "plus")
            .font(.system(size: 12, weight: .bold))
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("GreenMainColor"))

        Text("전체 \(totalCount)회")
          .font(.system(size: 11))
          .foregroundStyle(.tertiary)
      } else {
        // 기록이 없을 때 눌러서 갈 곳은 목록이 아니라 기록 추가 화면이다.
        Link(destination: WidgetRoute.addRecord.url ?? Self.addRecordFallbackURL) {
          Text("아직 기록이 없어요")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  /// Link는 옵셔널을 받지 않아 만들어두는 대비책. 실제로 쓰일 일은 없다.
  private static let recordsFallbackURL = URL(string: "whatthecoffee://records")!
  private static let addRecordFallbackURL = URL(string: "whatthecoffee://addRecord")!
}

struct WhatTheCoffeeWidgetEntryView: View {
  @Environment(\.widgetFamily) private var family
  var entry: CafeVisitEntry

  var body: some View {
    switch family {
    case .systemMedium:
      HStack(spacing: 16) {
        // 왼쪽은 통계, 오른쪽은 기록으로 보낸다. 누른 자리와 열리는 화면을 맞춘다.
        Link(destination: WidgetRoute.statistics.url ?? fallbackURL) {
          MonthlyCountView(count: entry.snapshot.monthlyCount)
        }
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
      // 잠금화면 위젯도 이번 달 숫자를 보여주므로 누르면 통계로 간다.
      .widgetURL(WidgetRoute.statistics.url)

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
      .widgetURL(WidgetRoute.statistics.url)

    default:
      MonthlyCountView(count: entry.snapshot.monthlyCount)
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(WidgetRoute.statistics.url)
    }
  }

  /// Link는 옵셔널을 받지 않아 만들어두는 대비책. 실제로 쓰일 일은 없다.
  private var fallbackURL: URL {
    return URL(string: "whatthecoffee://statistics")!
  }
}

struct WhatTheCoffeeWidget: Widget {
  let kind = "WhatTheCoffeeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      WhatTheCoffeeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("커피 방문 기록")
    .description("이번 달 방문 횟수와 최근 간 카페를 보고, 같은 곳을 한 번에 기록할 수 있어요.")
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
