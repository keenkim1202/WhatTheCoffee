import WidgetKit
import SwiftUI
import AppIntents

struct TodayCoffeeEntry: TimelineEntry {
  let date: Date
  let coffee: CoffeeSnapshot?
  /// 커피가 한 잔뿐이면 다시 뽑아도 같은 잔이라 버튼을 두지 않는다.
  let canReroll: Bool
}

struct TodayCoffeeProvider: TimelineProvider {
  func placeholder(in context: Context) -> TodayCoffeeEntry {
    return TodayCoffeeEntry(date: Date(), coffee: .sample, canReroll: true)
  }

  func getSnapshot(in context: Context, completion: @escaping (TodayCoffeeEntry) -> Void) {
    // 위젯 갤러리에서는 빈 화면 대신 예시 값을 보여준다.
    guard !context.isPreview else {
      completion(TodayCoffeeEntry(date: Date(), coffee: .sample, canReroll: true))
      return
    }
    completion(currentEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TodayCoffeeEntry>) -> Void) {
    let entry = currentEntry()
    completion(Timeline(entries: [entry], policy: .after(Self.midnight(after: entry.date))))
  }

  private func currentEntry() -> TodayCoffeeEntry {
    let coffees = RealmProvider.coffees()
    return TodayCoffeeEntry(
      date: Date(),
      coffee: TodayCoffee.pick(from: coffees),
      canReroll: coffees.count > 1)
  }

  /// 날이 바뀌면 다른 잔이 나와야 하므로 자정에 다시 그린다.
  private static func midnight(after date: Date, calendar: Calendar = .current) -> Date {
    let startOfToday = calendar.startOfDay(for: date)
    return calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date.addingTimeInterval(3600)
  }
}

// MARK: - Views

/// 등록해둔 커피 사진. 없으면 nil이고 위젯은 컵 아이콘으로 대신한다.
private func coffeePhoto(id: String, maxPixelSize: CGFloat) -> UIImage? {
  guard !id.isEmpty else { return nil }
  return SharedImageStore.load(type: .coffee, imageName: "coffee_\(id).jpg", maxPixelSize: maxPixelSize)
}

private struct RerollButton: View {
  var body: some View {
    // 위젯에서 바로 다시 뽑는다. 앱을 열었다 닫는 왕복이 없어야 누를 만하다.
    Button(intent: RerollCoffeeIntent()) {
      Label("다시 추천", systemImage: "arrow.triangle.2.circlepath")
        .font(.system(size: 12, weight: .bold))
    }
    .buttonStyle(.borderedProminent)
    .tint(Color("GreenMainColor"))
  }
}

private struct EmptyCoffeeView: View {
  var body: some View {
    // 뽑을 것이 없을 때 갈 곳은 추천 화면이 아니라 커피를 채우는 목록이다.
    Link(destination: WidgetRoute.recommend.url ?? TodayCoffeeEntryView.recommendFallbackURL) {
      VStack(spacing: 4) {
        Image(systemName: "cup.and.saucer")
          .font(.title3)
          .foregroundStyle(.secondary)
        Text("커피 목록이 비어 있어요")
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
    }
  }
}

struct TodayCoffeeEntryView: View {
  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var colorScheme
  var entry: TodayCoffeeEntry

  private var name: String {
    return entry.coffee?.name ?? ""
  }

  private var header: some View {
    Text("오늘의 커피")
      .font(.system(size: 12, weight: .bold))
      .foregroundStyle(.secondary)
  }

  private var coffeeName: some View {
    Text(name)
      .font(.system(size: 17, weight: .bold))
      .foregroundStyle(.primary)
      .lineLimit(2)
      .minimumScaleFactor(0.8)
      .multilineTextAlignment(.leading)
  }

  var body: some View {
    switch family {
    case .systemMedium:
      if entry.coffee == nil {
        EmptyCoffeeView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        HStack(spacing: 14) {
          if let coffee = entry.coffee, let photo = coffeePhoto(id: coffee.id, maxPixelSize: 300) {
            Image(uiImage: photo)
              .resizable()
              .scaledToFill()
              .frame(width: 92, height: 92)
              .clipShape(RoundedRectangle(cornerRadius: 10))
          } else {
            Image(systemName: "cup.and.saucer.fill")
              .font(.system(size: 36))
              .foregroundStyle(Color("OrangeMainColor"))
              .frame(width: 92, height: 92)
          }

          VStack(alignment: .leading, spacing: 6) {
            header
            // 이름을 누르면 추천 탭으로 간다. 버튼 밖도 눌리는 자리가 있어야 한다.
            Link(destination: WidgetRoute.recommend.url ?? Self.recommendFallbackURL) {
              coffeeName
            }
            if entry.canReroll {
              RerollButton()
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerBackground(.fill.tertiary, for: .widget)
      }

    case .systemSmall:
      if entry.coffee == nil {
        EmptyCoffeeView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        let photo = entry.coffee.flatMap { coffeePhoto(id: $0.id, maxPixelSize: 400) }
        VStack(alignment: .leading, spacing: 6) {
          header
          coffeeName
          Spacer(minLength: 0)
          if entry.canReroll {
            RerollButton()
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // 어두운 사진 위에서는 .primary가 검정으로 풀려 글씨가 묻힌다.
        .environment(\.colorScheme, photo == nil ? colorScheme : .dark)
        .containerBackground(for: .widget) {
          // 사진이 있으면 어떤 커피인지 글보다 빨리 알아본다.
          if let photo {
            Image(uiImage: photo)
              .resizable()
              .scaledToFill()
              .overlay(Color.black.opacity(0.55))
          } else {
            Rectangle().fill(.fill.tertiary)
          }
        }
        .widgetURL(WidgetRoute.recommend.url)
      }

    case .accessoryRectangular:
      VStack(alignment: .leading, spacing: 2) {
        Label("오늘의 커피", systemImage: "cup.and.saucer.fill")
          .font(.system(size: 14, weight: .bold))
        Text(entry.coffee?.name ?? "커피 목록이 비어 있어요")
          .font(.system(size: 12))
          .lineLimit(1)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .containerBackground(.fill.tertiary, for: .widget)
      .widgetURL(WidgetRoute.recommend.url)

    default:
      VStack(spacing: 2) {
        Image(systemName: "cup.and.saucer.fill")
          .font(.system(size: 12))
        Text(entry.coffee?.name ?? "")
          .font(.system(size: 11, weight: .bold))
          .lineLimit(1)
      }
      .containerBackground(.fill.tertiary, for: .widget)
      .widgetURL(WidgetRoute.recommend.url)
    }
  }

  /// Link는 옵셔널을 받지 않아 만들어두는 대비책. 실제로 쓰일 일은 없다.
  static let recommendFallbackURL = URL(string: "whatthecoffee://recommend")!
}

struct TodayCoffeeWidget: Widget {
  static let kind = "TodayCoffeeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: Self.kind, provider: TodayCoffeeProvider()) { entry in
      TodayCoffeeEntryView(entry: entry)
    }
    .configurationDisplayName("오늘의 커피")
    .description("커피 목록에서 오늘 마실 한 잔을 골라줘요. 마음에 안 들면 그 자리에서 다시 뽑을 수 있어요.")
    .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
  }
}

#Preview("Small", as: .systemSmall) {
  TodayCoffeeWidget()
} timeline: {
  TodayCoffeeEntry(date: Date(), coffee: .sample, canReroll: true)
  TodayCoffeeEntry(date: Date(), coffee: .sample, canReroll: false)
  TodayCoffeeEntry(date: Date(), coffee: nil, canReroll: false)
}

#Preview("Medium", as: .systemMedium) {
  TodayCoffeeWidget()
} timeline: {
  TodayCoffeeEntry(date: Date(), coffee: .sample, canReroll: true)
  TodayCoffeeEntry(date: Date(), coffee: .sample, canReroll: false)
  TodayCoffeeEntry(date: Date(), coffee: nil, canReroll: false)
}
