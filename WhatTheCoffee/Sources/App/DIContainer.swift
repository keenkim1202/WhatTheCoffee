import RealmSwift

final class DIContainer {
  static let shared = DIContainer()

  // MARK: - DataSource
  private lazy var realmDataSource: RealmDataSource = {
    let config = Realm.Configuration(
      schemaVersion: 1,
      migrationBlock: { _, oldSchemaVersion in
        // latitude, longitude, isClosed 필드 추가 — 기본값이 있어서 별도 처리 불필요
      })
    let realm = try! Realm(configuration: config)
    return RealmDataSource(realm: realm)
  }()

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

  func makeRecordSearchViewModel() -> RecordSearchViewModel {
    RecordSearchViewModel(useCase: makeManageRecordsUseCase(), imageUseCase: makeManageImageUseCase())
  }
}
