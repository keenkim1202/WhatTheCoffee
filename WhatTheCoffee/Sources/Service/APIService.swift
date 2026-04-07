import Foundation
import Alamofire

struct KakaoSearchResponse: Decodable {
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

class APIService {
  static let shared = APIService()
  typealias CompletionHandler = (Int, KakaoSearchResponse?) -> Void

  func fetchCafeInfo(pos: (x: Double, y: Double), query: String, page: Int, result: @escaping CompletionHandler) {
    let url = "https://dapi.kakao.com/v2/local/search/keyword.json"
    let header: HTTPHeaders = [
      "Authorization": Bundle.main.apiKey,
      "Content-Type": "multipart/form-data"
    ]

    let params: Parameters = [
      "x": "\(pos.y)",
      "y": "\(pos.x)",
      "radius": 20000,
      "query": query,
      "category_group_code": "CE7",
      "sort": "distance",
      "page": page
    ]

    AF.request(url, method: .get, parameters: params, headers: header)
      .validate(statusCode: 200...500)
      .responseDecodable(of: KakaoSearchResponse.self) { response in
        let code = response.response?.statusCode ?? 500
        switch response.result {
        case .success(let data):
          result(code, data)
        case .failure(let error):
          print("ERROR: \(error)")
          result(code, nil)
        }
      }
  }
}
