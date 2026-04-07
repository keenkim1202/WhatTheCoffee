import Foundation

struct KakaoSearchResponseDTO: Decodable {
  let meta: Meta
  let documents: [Document]

  struct Meta: Decodable {
    let pageableCount: Int
    let isEnd: Bool

    enum CodingKeys: String, CodingKey {
      case pageableCount = "pageable_count"
      case isEnd = "is_end"
    }
  }

  struct Document: Decodable {
    let placeName: String
    let roadAddressName: String
    let placeUrl: String
    let x: String
    let y: String
    let distance: String

    enum CodingKeys: String, CodingKey {
      case placeName = "place_name"
      case roadAddressName = "road_address_name"
      case placeUrl = "place_url"
      case x, y, distance
    }
  }
}
