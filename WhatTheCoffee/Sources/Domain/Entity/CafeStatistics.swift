import Foundation

struct CafeStatistics {
  let totalVisitCount: Int
  let averageRating: Double
  let monthlyVisitCounts: [(year: Int, month: Int, count: Int)]
  let ratingDistribution: [Int: Int]
  let topCafes: [(name: String, count: Int)]
  /// 자주 마신 커피. 커피를 남긴 기록만 센다.
  let topCoffees: [(name: String, count: Int, averageRating: Double)]
}
