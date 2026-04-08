import Foundation

final class StatisticsViewModel {
  private let useCase: FetchStatisticsUseCase

  private(set) var statistics: CafeStatistics?
  var onStatisticsUpdated: (() -> Void)?

  init(useCase: FetchStatisticsUseCase) {
    self.useCase = useCase
  }

  func fetchData() {
    statistics = useCase.fetch()
    onStatisticsUpdated?()
  }
}
