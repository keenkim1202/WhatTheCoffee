import Foundation
import RealmSwift

/// 앱의 의존성을 만드는 유일한 자리.
/// AppCoordinator가 소유하고, 필요한 곳에는 만들어진 것만 건네준다.
final class DIContainer {

  private static let appGroupID = "group.keen.WhatTheCoffee"


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
      return Realm.Configuration(schemaVersion: RealmSchema.version, migrationBlock: RealmSchema.migrationBlock)
    }

    let sharedURL = containerURL.appendingPathComponent("default.realm")

    if !FileManager.default.fileExists(atPath: sharedURL.path),
       let legacyURL,
       FileManager.default.fileExists(atPath: legacyURL.path) {
      do {
        try FileManager.default.copyItem(at: legacyURL, to: sharedURL)
      } catch {
        return Realm.Configuration(fileURL: legacyURL, schemaVersion: RealmSchema.version, migrationBlock: RealmSchema.migrationBlock)
      }
    }

    return Realm.Configuration(fileURL: sharedURL, schemaVersion: RealmSchema.version, migrationBlock: RealmSchema.migrationBlock)
  }

  // MARK: - Repository
  /// 바깥에 열어두면 화면이 UseCase를 건너뛰고 저장소를 직접 만지게 된다.
  private lazy var coffeeRepository: CoffeeRepositoryProtocol = CoffeeRepositoryImpl(dataSource: realmDataSource)
  private lazy var cafeRepository: CafeRepositoryProtocol = CafeRepositoryImpl(dataSource: realmDataSource)

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

  func makeManageDefaultDataUseCase() -> ManageDefaultDataUseCase {
    ManageDefaultDataUseCase(
      coffeeRepository: coffeeRepository,
      cafeRepository: cafeRepository,
      imageUseCase: makeManageImageUseCase())
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
    NearCafeViewModel(
      useCase: makeFetchNearCafeUseCase(),
      recordsUseCase: makeManageRecordsUseCase(),
      imageUseCase: makeManageImageUseCase())
  }

  func makeRecordsViewModel() -> RecordsViewModel {
    RecordsViewModel(useCase: makeManageRecordsUseCase(), imageUseCase: makeManageImageUseCase())
  }

  func makeAddRecordViewModel(cafe: CafeEntity? = nil, prefilledLocation: SelectedLocation? = nil) -> AddRecordViewModel {
    AddRecordViewModel(
      useCase: makeManageRecordsUseCase(),
      imageUseCase: makeManageImageUseCase(),
      cafe: cafe,
      prefilledLocation: prefilledLocation)
  }

  func makeStatisticsViewModel() -> StatisticsViewModel {
    StatisticsViewModel(useCase: makeFetchStatisticsUseCase())
  }

  func makeRecordSearchViewModel() -> RecordSearchViewModel {
    RecordSearchViewModel(useCase: makeManageRecordsUseCase(), imageUseCase: makeManageImageUseCase())
  }
}
