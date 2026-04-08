import Foundation

final class FetchStatisticsUseCase {
  private let repository: CafeRepositoryProtocol

  init(repository: CafeRepositoryProtocol) {
    self.repository = repository
  }

  func fetch() -> CafeStatistics {
    let cafes = repository.fetch()

    let totalCount = cafes.count
    let averageRating = totalCount > 0
      ? Double(cafes.reduce(0) { $0 + $1.rate }) / Double(totalCount)
      : 0

    let monthlyVisitCounts = calculateMonthlyVisits(cafes)
    let ratingDistribution = calculateRatingDistribution(cafes)
    let topCafes = calculateTopCafes(cafes)

    return CafeStatistics(
      totalVisitCount: totalCount,
      averageRating: averageRating,
      monthlyVisitCounts: monthlyVisitCounts,
      ratingDistribution: ratingDistribution,
      topCafes: topCafes)
  }

  private func calculateMonthlyVisits(_ cafes: [CafeEntity]) -> [(year: Int, month: Int, count: Int)] {
    let calendar = Calendar.current
    let now = Date()

    let last6Months: [(year: Int, month: Int)] = (0..<6).compactMap { offset in
      guard let date = calendar.date(byAdding: .month, value: -offset, to: now) else { return nil }
      let components = calendar.dateComponents([.year, .month], from: date)
      return (components.year!, components.month!)
    }.reversed()

    let grouped = Dictionary(grouping: cafes) { cafe -> String in
      let components = calendar.dateComponents([.year, .month], from: cafe.visitDate)
      return "\(components.year!)-\(components.month!)"
    }

    return last6Months.map { (year, month) in
      let key = "\(year)-\(month)"
      let count = grouped[key]?.count ?? 0
      return (year: year, month: month, count: count)
    }
  }

  private func calculateRatingDistribution(_ cafes: [CafeEntity]) -> [Int: Int] {
    var distribution: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    for cafe in cafes {
      distribution[cafe.rate, default: 0] += 1
    }
    return distribution
  }

  private func calculateTopCafes(_ cafes: [CafeEntity]) -> [(name: String, count: Int)] {
    let grouped = Dictionary(grouping: cafes) { $0.name }
    return grouped
      .map { (name: $0.key, count: $0.value.count) }
      .sorted { $0.count > $1.count }
      .prefix(5)
      .map { $0 }
  }
}
