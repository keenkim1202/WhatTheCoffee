import Foundation

final class FetchStatisticsUseCase {
  private let repository: CafeRepositoryProtocol

  init(repository: CafeRepositoryProtocol) {
    self.repository = repository
  }

  func fetch() -> CafeStatistics {
    let cafes = repository.fetch()

    // 기록 한 건이 여러 번의 방문을 담을 수 있어 횟수를 더한다.
    let totalCount = cafes.reduce(0) { $0 + $1.visitCount }
    let averageRating = cafes.isEmpty
      ? 0
      : Double(cafes.reduce(0) { $0 + $1.rate * $1.visitCount }) / Double(totalCount)

    let monthlyVisitCounts = calculateMonthlyVisits(cafes)
    let ratingDistribution = calculateRatingDistribution(cafes)
    let topCafes = calculateTopCafes(cafes)
    let topCoffees = calculateTopCoffees(cafes)

    return CafeStatistics(
      totalVisitCount: totalCount,
      averageRating: averageRating,
      monthlyVisitCounts: monthlyVisitCounts,
      ratingDistribution: ratingDistribution,
      topCafes: topCafes,
      topCoffees: topCoffees)
  }

  private func calculateMonthlyVisits(_ cafes: [CafeEntity]) -> [(year: Int, month: Int, count: Int)] {
    let calendar = Calendar.current
    let now = Date()

    let last6Months: [(year: Int, month: Int)] = (0..<6).compactMap { offset in
      guard let date = calendar.date(byAdding: .month, value: -offset, to: now) else { return nil }
      let components = calendar.dateComponents([.year, .month], from: date)
      return (components.year!, components.month!)
    }.reversed()

    // 방문마다 날짜가 남으므로 각 방문을 그 달에 센다.
    // 마지막 방문일 하나로 세면 3월에 간 것까지 8월로 몰린다.
    var countsByMonth: [String: Int] = [:]
    for cafe in cafes {
      for date in cafe.visitDates {
        let components = calendar.dateComponents([.year, .month], from: date)
        countsByMonth["\(components.year!)-\(components.month!)", default: 0] += 1
      }
    }

    return last6Months.map { (year, month) in
      return (year: year, month: month, count: countsByMonth["\(year)-\(month)"] ?? 0)
    }
  }

  private func calculateRatingDistribution(_ cafes: [CafeEntity]) -> [Int: Int] {
    var distribution: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    for cafe in cafes {
      distribution[cafe.rate, default: 0] += cafe.visitCount
    }
    return distribution
  }

  /// 어떤 커피를 자주 마셨는지, 그리고 그 커피가 몇 점이었는지.
  /// 커피를 남기지 않은 기록은 세지 않는다. 안 마신 것과 안 적은 것은 다르다.
  private func calculateTopCoffees(_ cafes: [CafeEntity]) -> [(name: String, count: Int, averageRating: Double)] {
    let named = cafes.filter { $0.coffeeName?.isEmpty == false }
    let grouped = Dictionary(grouping: named) { $0.coffeeName! }

    var summaries: [(name: String, count: Int, averageRating: Double)] = []
    for (name, records) in grouped {
      // 한 기록이 여러 번의 방문을 담으므로 별점도 그만큼 무게를 갖는다.
      var count = 0
      var ratingTotal = 0
      for record in records {
        count += record.visitCount
        ratingTotal += record.rate * record.visitCount
      }

      let average: Double = count == 0 ? 0 : Double(ratingTotal) / Double(count)
      summaries.append((name: name, count: count, averageRating: average))
    }

    summaries.sort { first, second in
      return first.count == second.count ? first.name < second.name : first.count > second.count
    }
    return Array(summaries.prefix(5))
  }

  private func calculateTopCafes(_ cafes: [CafeEntity]) -> [(name: String, count: Int)] {
    let grouped = Dictionary(grouping: cafes) { $0.name }
    return grouped
      .map { (name: $0.key, count: $0.value.reduce(0) { $0 + $1.visitCount }) }
      .sorted { $0.count > $1.count }
      .prefix(5)
      .map { $0 }
  }
}
