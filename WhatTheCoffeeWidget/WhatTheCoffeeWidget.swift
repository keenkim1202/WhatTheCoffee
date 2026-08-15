import WidgetKit
import SwiftUI
import AppIntents
import CoreLocation

struct CafeVisitEntry: TimelineEntry {
  let date: Date
  let snapshot: CafeVisitSnapshot
  let mode: WidgetDisplayMode
}

struct Provider: AppIntentTimelineProvider {
  func placeholder(in context: Context) -> CafeVisitEntry {
    return CafeVisitEntry(date: Date(), snapshot: .sample, mode: .recent)
  }

  func snapshot(for configuration: SelectDisplayModeIntent, in context: Context) async -> CafeVisitEntry {
    // 위젯 갤러리에서는 빈 화면 대신 예시 값을 보여준다.
    guard !context.isPreview else {
      let sample: CafeVisitSnapshot = configuration.mode == .nearest ? .nearbySample : .sample
      return CafeVisitEntry(date: Date(), snapshot: sample, mode: configuration.mode)
    }
    return await entry(for: configuration.mode)
  }

  func timeline(for configuration: SelectDisplayModeIntent, in context: Context) async -> Timeline<CafeVisitEntry> {
    let entry = await entry(for: configuration.mode)
    return Timeline(entries: [entry], policy: .after(Self.nextRefresh(for: configuration.mode, after: entry.date)))
  }

  private func entry(for mode: WidgetDisplayMode) async -> CafeVisitEntry {
    // 위치는 가까운 곳을 고를 때만 필요하다. 최근 방문에는 묻지 않는다.
    let location = mode == .nearest ? await WidgetLocation.current() : nil
    let snapshot = RealmProvider.snapshot(mode: mode, location: location) ?? .empty
    return CafeVisitEntry(date: Date(), snapshot: snapshot, mode: mode)
  }

  /// 달이 바뀌면 이번 달 방문 수가 0으로 돌아가야 하므로 자정에 다시 그린다.
  /// 가까운 곳은 움직이면 답이 바뀌므로 자정까지 기다리지 않고 더 자주 다시 잰다.
  private static func nextRefresh(for mode: WidgetDisplayMode,
                                  after date: Date,
                                  calendar: Calendar = .current) -> Date {
    let startOfToday = calendar.startOfDay(for: date)
    let midnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date.addingTimeInterval(3600)
    guard mode == .nearest else { return midnight }
    return min(midnight, date.addingTimeInterval(30 * 60))
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

/// 기록해둔 카페 사진. 없으면 nil이고 위젯은 원래대로 그린다.
private func featuredPhoto(id: String, maxPixelSize: CGFloat) -> UIImage? {
  guard !id.isEmpty else { return nil }
  return SharedImageStore.load(type: .cafe, imageName: "cafe_\(id).jpg", maxPixelSize: maxPixelSize)
}

private struct FeaturedCafeView: View {
  let featured: CafeVisitSnapshot.Featured?
  let fallback: CafeVisitSnapshot.Fallback?
  let totalCount: Int
  let mode: WidgetDisplayMode
  /// small은 사진을 배경으로 쓰므로 안쪽에 또 넣으면 두 장이 되고 높이가 모자란다.
  let showsThumbnail: Bool

  /// 거리를 보여주고 있을 때만 가까운 곳을 고른 것이다.
  /// 위치를 못 얻어 최근 방문으로 물러난 경우에는 제목도 그에 맞춰야 한다.
  private var title: String {
    return featured?.distance == nil ? "최근 방문" : "근처에 갔던 곳"
  }

  private static func dateText(for date: Date) -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) { return "오늘" }
    if calendar.isDateInYesterday(date) { return "어제" }
    return date.formatted(.dateTime.month().day())
  }

  private static func distanceText(_ meters: CLLocationDistance) -> String {
    guard meters >= 1000 else { return "\(Int(meters.rounded()))m" }
    return String(format: "%.1fkm", meters / 1000)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(.secondary)

      if let featured {
        // 카페 이름과 방문 정보를 누르면 기록 탭으로 간다.
        // 버튼만 누를 수 있으면 나머지 영역은 눌러도 아무 데도 가지 않는 죽은 자리가 된다.
        Link(destination: WidgetRoute.records.url ?? Self.recordsFallbackURL) {
          VStack(alignment: .leading, spacing: 4) {
            if showsThumbnail, let photo = featuredPhoto(id: featured.id, maxPixelSize: 160) {
              Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            Text(featured.name)
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(.primary)
              .lineLimit(1)

            HStack(spacing: 6) {
              // 가까운 곳을 골랐다면 거리가 곧 이유다. 그게 아니면 언제 갔는지를 보여준다.
              if let distance = featured.distance {
                Text(Self.distanceText(distance))
                  .font(.system(size: 12, weight: .bold))
                  .foregroundStyle(Color("GreenMainColor"))
              } else {
                Text(Self.dateText(for: featured.visitDate))
                  .font(.system(size: 12))
                  .foregroundStyle(.secondary)
              }

              if featured.visitCount > 1 {
                Text("\(featured.visitCount)번 방문")
                  .font(.system(size: 12))
                  .foregroundStyle(.secondary)
              }

              HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { star in
                  Image(systemName: star <= featured.rate ? "star.fill" : "star")
                    .font(.system(size: 9))
                    .foregroundStyle(Color("OrangeMainColor"))
                }
              }
            }
          }
        }

        // 무엇이 일어나는지 버튼이 직접 말하도록 한다.
        // 카페 이름 바로 아래에 두어 어느 곳을 기록하는지도 드러낸다.
        Button(intent: AddVisitIntent(id: featured.id, name: featured.name)) {
          Label("오늘 방문 기록", systemImage: "plus")
            .font(.system(size: 12, weight: .bold))
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("GreenMainColor"))

        // 가까운 곳을 보여주기로 해놓고 다른 걸 보여주면 고장으로 읽힌다. 이유를 밝힌다.
        if let fallback, mode == .nearest {
          Text(fallback.message)
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
            .lineLimit(1)
        } else {
          Text("전체 \(totalCount)회")
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
        }
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

  @Environment(\.colorScheme) private var colorScheme

  private func featuredView(showsThumbnail: Bool) -> FeaturedCafeView {
    return FeaturedCafeView(
      featured: entry.snapshot.featured,
      fallback: entry.snapshot.fallback,
      totalCount: entry.snapshot.totalCount,
      mode: entry.mode,
      showsThumbnail: showsThumbnail)
  }

  /// small 배경에 깔 사진. 어둡게 덮으므로 글씨는 밝은 쪽으로 가야 읽힌다.
  private var backgroundPhoto: UIImage? {
    guard family == .systemSmall, entry.mode == .nearest, let id = entry.snapshot.featured?.id else { return nil }
    return featuredPhoto(id: id, maxPixelSize: 400)
  }

  var body: some View {
    switch family {
    case .systemMedium:
      HStack(spacing: 16) {
        // 왼쪽은 통계, 오른쪽은 기록으로 보낸다. 누른 자리와 열리는 화면을 맞춘다.
        Link(destination: WidgetRoute.statistics.url ?? fallbackURL) {
          MonthlyCountView(count: entry.snapshot.monthlyCount)
        }
        Divider()
        featuredView(showsThumbnail: true)
      }
      .containerBackground(.fill.tertiary, for: .widget)

    case .systemSmall:
      // 가까운 곳을 보라고 골라놓고 이번 달 숫자만 띄우면 고른 의미가 없다.
      if entry.mode == .nearest {
        let photo = backgroundPhoto
        featuredView(showsThumbnail: false)
          // 어두운 사진 위에서는 .primary가 검정으로 풀려 글씨가 묻힌다.
          .environment(\.colorScheme, photo == nil ? colorScheme : .dark)
          .containerBackground(for: .widget) {
            // 사진이 있으면 그 카페가 어디였는지 글보다 빨리 알아본다.
            if let photo {
              Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.55))
            } else {
              Rectangle().fill(.fill.tertiary)
            }
          }
      } else {
        MonthlyCountView(count: entry.snapshot.monthlyCount)
          .containerBackground(.fill.tertiary, for: .widget)
          .widgetURL(WidgetRoute.statistics.url)
      }

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
        if let featured = entry.snapshot.featured {
          Text(featured.name)
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
    AppIntentConfiguration(kind: kind, intent: SelectDisplayModeIntent.self, provider: Provider()) { entry in
      WhatTheCoffeeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("커피 방문 기록")
    .description("최근 간 카페나 지금 가까운 카페를 보고, 그 자리에서 한 번에 기록할 수 있어요.")
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
  }
}

#Preview("Small", as: .systemSmall) {
  WhatTheCoffeeWidget()
} timeline: {
  CafeVisitEntry(date: Date(), snapshot: .sample, mode: .recent)
  CafeVisitEntry(date: Date(), snapshot: .nearbySample, mode: .nearest)
}

#Preview("Medium", as: .systemMedium) {
  WhatTheCoffeeWidget()
} timeline: {
  CafeVisitEntry(date: Date(), snapshot: .sample, mode: .recent)
  CafeVisitEntry(date: Date(), snapshot: .nearbySample, mode: .nearest)
  CafeVisitEntry(date: Date(), snapshot: .empty, mode: .recent)
}
