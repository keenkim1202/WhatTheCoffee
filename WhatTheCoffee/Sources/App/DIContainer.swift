import RealmSwift

final class DIContainer {
  static let shared = DIContainer()

  // MARK: - DataSource
  private lazy var realmDataSource: RealmDataSource = {
    let realm = try! Realm()
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

  func makeManageRecordsUseCase() -> ManageRecordsUseCase {
    ManageRecordsUseCase(repository: cafeRepository)
  }

  // MARK: - ViewModel
  func makeRecommendViewModel() -> RecommendViewModel {
    RecommendViewModel(useCase: makeRecommendCoffeeUseCase())
  }

  func makeCoffeeListViewModel() -> CoffeeListViewModel {
    CoffeeListViewModel(useCase: makeManageCoffeeListUseCase())
  }

  func makeAddCoffeeViewModel(coffee: CoffeeEntity? = nil) -> AddCoffeeViewModel {
    AddCoffeeViewModel(useCase: makeManageCoffeeListUseCase(), coffee: coffee)
  }

  func makeNearCafeViewModel() -> NearCafeViewModel {
    NearCafeViewModel(useCase: makeFetchNearCafeUseCase())
  }

  func makeRecordsViewModel() -> RecordsViewModel {
    RecordsViewModel(useCase: makeManageRecordsUseCase())
  }

  func makeAddRecordViewModel(cafe: CafeEntity? = nil) -> AddRecordViewModel {
    AddRecordViewModel(useCase: makeManageRecordsUseCase(), cafe: cafe)
  }

  func makeRecordSearchViewModel() -> RecordSearchViewModel {
    RecordSearchViewModel(useCase: makeManageRecordsUseCase())
  }
}
