import Foundation
import RealmSwift

final class DIContainer {
  static let shared = DIContainer()

  static let appGroupID = "group.keen.WhatTheCoffee"

  /// 위젯의 RealmProvider와 같은 값을 써야 한다.
  private static let realmSchemaVersion: UInt64 = 3

  // MARK: - DataSource
  private lazy var realmDataSource: RealmDataSource = {
    let realm = try! Realm(configuration: Self.makeRealmConfiguration())
    return RealmDataSource(realm: realm)
  }()

  /// 위젯이 같은 Realm 파일을 읽으려면 앱 그룹 컨테이너에 있어야 한다.
  /// 기존 사용자의 기록은 앱 샌드박스에 있으므로 최초 실행 때 한 번 옮긴다.
  /// 옮기지 못하면 원래 위치를 계속 쓴다 — 위젯은 비어 보이지만 기록을 잃지는 않는다.
  private static func makeRealmConfiguration() -> Realm.Configuration {
    let legacyURL = Realm.Configuration.defaultConfiguration.fileURL

    guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
      return Realm.Configuration(schemaVersion: realmSchemaVersion, migrationBlock: { _, _ in })
    }

    let sharedURL = containerURL.appendingPathComponent("default.realm")

    if !FileManager.default.fileExists(atPath: sharedURL.path),
       let legacyURL,
       FileManager.default.fileExists(atPath: legacyURL.path) {
      do {
        try FileManager.default.copyItem(at: legacyURL, to: sharedURL)
      } catch {
        return Realm.Configuration(fileURL: legacyURL, schemaVersion: realmSchemaVersion, migrationBlock: { _, _ in })
      }
    }

    return Realm.Configuration(fileURL: sharedURL, schemaVersion: realmSchemaVersion, migrationBlock: { _, _ in })
  }

  // MARK: - Repository
  lazy var coffeeRepository: CoffeeRepositoryProtocol = CoffeeRepositoryImpl(dataSource: realmDataSource)
  lazy var cafeRepository: CafeRepositoryProtocol = CafeRepositoryImpl(dataSource: realmDataSource)

  // MARK: - UseCase
  func makeRecommendCoffeeUseCase() -> RecommendCoffeeUseCase {
    RecommendCoffeeUseCase(repository: coffeeRepository)
  }

  func makeManageCoffeeListUseCase() -> ManageCoffeeListUseCase {
    ManageCoffeeListUseCase(repository: coffeeRepository)
  }

  func makeFetchNearCafeUseCase() -> FetchNearCafeUseCase {
    FetchNearCafeUseCase()
  }

  func makeCheckClosedCafeUseCase() -> CheckClosedCafeUseCase {
    CheckClosedCafeUseCase(repository: cafeRepository)
  }

  func makeManageRecordsUseCase() -> ManageRecordsUseCase {
    ManageRecordsUseCase(repository: cafeRepository)
  }

  func makeFetchStatisticsUseCase() -> FetchStatisticsUseCase {
    FetchStatisticsUseCase(repository: cafeRepository)
  }

  func makeManageImageUseCase() -> ManageImageUseCase {
    ManageImageUseCase()
  }

  // MARK: - ViewModel
  func makeRecommendViewModel() -> RecommendViewModel {
    RecommendViewModel(useCase: makeRecommendCoffeeUseCase(), imageUseCase: makeManageImageUseCase())
  }

  func makeCoffeeListViewModel() -> CoffeeListViewModel {
    CoffeeListViewModel(useCase: makeManageCoffeeListUseCase(), imageUseCase: makeManageImageUseCase())
  }

  func makeAddCoffeeViewModel(coffee: CoffeeEntity? = nil) -> AddCoffeeViewModel {
    AddCoffeeViewModel(useCase: makeManageCoffeeListUseCase(), imageUseCase: makeManageImageUseCase(), coffee: coffee)
  }

  func makeNearCafeViewModel() -> NearCafeViewModel {
    NearCafeViewModel(useCase: makeFetchNearCafeUseCase())
  }

  func makeRecordsViewModel() -> RecordsViewModel {
    RecordsViewModel(useCase: makeManageRecordsUseCase(), imageUseCase: makeManageImageUseCase())
  }

  func makeAddRecordViewModel(cafe: CafeEntity? = nil) -> AddRecordViewModel {
    AddRecordViewModel(useCase: makeManageRecordsUseCase(), imageUseCase: makeManageImageUseCase(), cafe: cafe)
  }

  func makeStatisticsViewModel() -> StatisticsViewModel {
    StatisticsViewModel(useCase: makeFetchStatisticsUseCase())
  }

  func makeRecordSearchViewModel() -> RecordSearchViewModel {
    RecordSearchViewModel(useCase: makeManageRecordsUseCase(), imageUseCase: makeManageImageUseCase())
  }
}
