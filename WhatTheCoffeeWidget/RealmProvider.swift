import Foundation
import CoreLocation
import Realm
import RealmSwift

/// 앱 그룹 컨테이너의 Realm을 읽기 전용으로 열어 위젯에 필요한 값만 뽑아온다.
/// Realm 객체는 스레드에 묶여 있으므로 이 타입 밖으로 나가는 것은 값 타입뿐이다.
enum RealmProvider {
  static let appGroupID = "group.keen.WhatTheCoffee"

  static func snapshot(mode: WidgetDisplayMode = .recent,
                       location: CLLocation? = nil,
                       now: Date = Date(),
                       calendar: Calendar = .current) -> CafeVisitSnapshot? {
    guard let realm = openRealm() else { return nil }

    let cafes = realm.objects(Cafe.self).sorted(byKeyPath: "visitDate", ascending: false)

    // 통계 탭과 같은 기준으로 이번 달에 속한 기록을 모두 센다.
    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
          let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
      return nil
    }

    // 방문마다 날짜가 남으므로 이번 달에 속한 방문만 센다.
    // 기록 단위로 세면 지난달에 간 것까지 이번 달로 딸려 온다.
    var monthlyCount = 0
    var totalCount = 0
    for cafe in cafes {
      let dates = cafe.visitDates.isEmpty ? [cafe.visitDate] : Array(cafe.visitDates)
      totalCount += dates.count
      monthlyCount += dates.filter { $0 >= startOfMonth && $0 < startOfNextMonth }.count
    }

    let picked = pick(mode: mode, location: location, from: cafes)
    return CafeVisitSnapshot(
      monthlyCount: monthlyCount,
      totalCount: totalCount,
      featured: picked.featured,
      fallback: picked.fallback)
  }

  /// 고른 카페와, 원하는 기준으로 고르지 못했다면 그 이유.
  /// 가까운 곳을 못 찾았을 때 빈 화면을 두는 대신 최근 방문을 보여주고 왜 그런지 밝힌다.
  private static func pick(mode: WidgetDisplayMode,
                           location: CLLocation?,
                           from cafes: Results<Cafe>) -> (featured: CafeVisitSnapshot.Featured?, fallback: CafeVisitSnapshot.Fallback?) {
    let recent = cafes.first.map { CafeVisitSnapshot.Featured(cafe: $0, distance: nil) }
    guard mode == .nearest else { return (recent, nil) }

    guard let location else { return (recent, .locationUnavailable) }

    // 좌표는 나중에 생긴 항목이라 예전 기록에는 없다. 폐점한 곳으로 부를 이유도 없다.
    let measured = cafes.compactMap { cafe -> (Cafe, CLLocationDistance)? in
      guard !cafe.isClosed, let latitude = cafe.latitude, let longitude = cafe.longitude else { return nil }
      return (cafe, CLLocation(latitude: latitude, longitude: longitude).distance(from: location))
    }

    guard let nearest = measured.min(by: { $0.1 < $1.1 }) else { return (recent, .noCoordinates) }
    return (CafeVisitSnapshot.Featured(cafe: nearest.0, distance: nearest.1), nil)
  }

  /// 추천 목록에 담아둔 커피 전부.
  /// 순서가 흔들리면 같은 날에 다른 커피가 나오므로 기본키로 고정한다.
  static func coffees() -> [CoffeeSnapshot] {
    guard let realm = openRealm() else { return [] }
    return realm.objects(Coffee.self)
      .sorted(byKeyPath: "_id", ascending: true)
      .map { CoffeeSnapshot(id: $0._id.stringValue, name: $0.name) }
  }

  /// 위젯에 떠 있던 그 기록의 방문 횟수를 올리고 날짜를 오늘로 옮긴다.
  /// 같은 내용의 기록을 여러 건 만들면 목록이 중복으로 채워진다.
  /// 위젯에서 새 카페를 만들 수는 없으므로, 기록이 없으면 아무것도 하지 않는다.
  static func addVisit(id: String, fallbackName: String) {
    guard let realm = openRealm() else { return }
    guard let target = cafe(withID: id, in: realm) ?? mostRecentCafe(named: fallbackName, in: realm) else {
      return
    }

    try? realm.write {
      let now = Date()
      if target.visitDates.isEmpty {
        target.visitDates.append(target.visitDate)
      }
      target.visitDates.append(now)
      target.visitDate = now
    }
  }

  private static func cafe(withID id: String, in realm: Realm) -> Cafe? {
    guard let objectID = try? ObjectId(string: id) else { return nil }
    return realm.object(ofType: Cafe.self, forPrimaryKey: objectID)
  }

  /// 아직 기본키를 담지 않은 채로 그려진 위젯이 남아 있을 때만 쓰이는 대비책.
  /// 이름이 같은 곳이 여럿이면 어느 하나로 정해지므로 기본키가 있으면 그쪽을 먼저 본다.
  private static func mostRecentCafe(named name: String, in realm: Realm) -> Cafe? {
    return realm.objects(Cafe.self)
      .filter("name == %@", name)
      .sorted(byKeyPath: "visitDate", ascending: false)
      .first
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
      schemaVersion: RealmSchema.version,
      migrationBlock: RealmSchema.migrationBlock,
      objectTypes: [Cafe.self, Coffee.self])

    return try? Realm(configuration: config)
  }
}

/// 위젯이 오늘의 커피로 보여줄 한 잔.
struct CoffeeSnapshot {
  /// 사진 파일 이름이 기본키로 정해지므로 이름만으로는 사진을 찾을 수 없다.
  let id: String
  let name: String
}

extension CoffeeSnapshot {
  /// 위젯 갤러리와 프리뷰에서 쓰는 예시 데이터.
  static let sample = CoffeeSnapshot(id: "", name: "아이스 아메리카노")
}

struct CafeVisitSnapshot {
  /// 위젯이 골라 보여주는 한 곳.
  struct Featured {
    /// 이름은 같은 곳이 여럿일 수 있어 기록을 가리키는 데 쓸 수 없다.
    let id: String
    let name: String
    let visitDate: Date
    let rate: Int
    let visitCount: Int
    /// 현재 위치에서의 거리. 가까운 순으로 골랐을 때만 있다.
    let distance: CLLocationDistance?

    init(id: String, name: String, visitDate: Date, rate: Int, visitCount: Int, distance: CLLocationDistance?) {
      self.id = id
      self.name = name
      self.visitDate = visitDate
      self.rate = rate
      self.visitCount = max(1, visitCount)
      self.distance = distance
    }

    init(cafe: Cafe, distance: CLLocationDistance?) {
      self.init(
        id: cafe._id.stringValue,
        name: cafe.name,
        visitDate: cafe.visitDate,
        rate: cafe.rate,
        visitCount: cafe.visitCount,
        distance: distance)
    }
  }

  /// 가까운 곳을 보여주려다 실패한 이유. 대신 최근 방문을 보여준다.
  enum Fallback {
    case locationUnavailable
    case noCoordinates

    var message: String {
      switch self {
      case .locationUnavailable: return "위치를 못 찾아 최근 방문"
      case .noCoordinates: return "위치 있는 기록이 없어 최근 방문"
      }
    }
  }

  let monthlyCount: Int
  let totalCount: Int
  let featured: Featured?
  let fallback: Fallback?
}

extension CafeVisitSnapshot {
  /// 아직 기록이 없거나 앱 그룹 컨테이너를 열지 못했을 때 보여줄 값.
  static let empty = CafeVisitSnapshot(monthlyCount: 0, totalCount: 0, featured: nil, fallback: nil)

  /// 위젯 갤러리와 프리뷰에서 쓰는 예시 데이터.
  static let sample = CafeVisitSnapshot(
    monthlyCount: 12,
    totalCount: 143,
    featured: Featured(
      id: "",
      name: "언더프레셔",
      visitDate: Date(timeIntervalSinceNow: -3600 * 5),
      rate: 4,
      visitCount: 3,
      distance: nil),
    fallback: nil)

  /// 가까운 곳 모드의 예시. 갤러리에서 두 모드가 어떻게 다른지 보여준다.
  static let nearbySample = CafeVisitSnapshot(
    monthlyCount: 12,
    totalCount: 143,
    featured: Featured(
      id: "",
      name: "언더프레셔",
      visitDate: Date(timeIntervalSinceNow: -3600 * 24 * 6),
      rate: 4,
      visitCount: 3,
      distance: 320),
    fallback: nil)
}
