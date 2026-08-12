import Foundation
import RealmSwift

/// 앱 그룹 컨테이너의 Realm을 읽기 전용으로 열어 위젯에 필요한 값만 뽑아온다.
/// Realm 객체는 스레드에 묶여 있으므로 이 타입 밖으로 나가는 것은 값 타입뿐이다.
enum RealmProvider {
  static let appGroupID = "group.keen.WhatTheCoffee"

  static func snapshot(now: Date = Date(), calendar: Calendar = .current) -> CafeVisitSnapshot? {
    guard let realm = openRealm() else { return nil }

    let cafes = realm.objects(Cafe.self).sorted(byKeyPath: "visitDate", ascending: false)

    // 통계 탭과 같은 기준으로 이번 달에 속한 기록을 모두 센다.
    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
          let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
      return nil
    }

    let monthlyCount = cafes.filter("visitDate >= %@ AND visitDate < %@", startOfMonth, startOfNextMonth).count
    let recent = cafes.first.map {
      CafeVisitSnapshot.Visit(name: $0.name, visitDate: $0.visitDate, rate: $0.rate)
    }

    return CafeVisitSnapshot(monthlyCount: monthlyCount, totalCount: cafes.count, recent: recent)
  }

  private static func openRealm() -> Realm? {
    guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
      return nil
    }

    let realmURL = containerURL.appendingPathComponent("default.realm")

    // 파일이 없으면 열지 않는다. 위젯이 먼저 실행되어 빈 Realm을 만들어 버리면
    // 앱은 이전할 파일이 이미 있다고 보고 기존 기록을 두고 빈 DB로 넘어간다.
    guard FileManager.default.fileExists(atPath: realmURL.path) else { return nil }

    let config = Realm.Configuration(
      fileURL: realmURL,
      schemaVersion: 3,
      migrationBlock: { _, _ in },
      objectTypes: [Cafe.self])

    return try? Realm(configuration: config)
  }
}

struct CafeVisitSnapshot {
  struct Visit {
    let name: String
    let visitDate: Date
    let rate: Int
  }

  let monthlyCount: Int
  let totalCount: Int
  let recent: Visit?
}

extension CafeVisitSnapshot {
  /// 아직 기록이 없거나 앱 그룹 컨테이너를 열지 못했을 때 보여줄 값.
  static let empty = CafeVisitSnapshot(monthlyCount: 0, totalCount: 0, recent: nil)

  /// 위젯 갤러리와 프리뷰에서 쓰는 예시 데이터.
  static let sample = CafeVisitSnapshot(
    monthlyCount: 12,
    totalCount: 143,
    recent: Visit(name: "언더프레셔", visitDate: Date(timeIntervalSinceNow: -3600 * 5), rate: 4))
}
