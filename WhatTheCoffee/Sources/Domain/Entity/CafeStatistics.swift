import Foundation

struct CafeStatistics {
  let totalVisitCount: Int
  let averageRating: Double
  let monthlyVisitCounts: [(year: Int, month: Int, count: Int)]
  let ratingDistribution: [Int: Int]
  let topCafes: [(name: String, count: Int)]
}
