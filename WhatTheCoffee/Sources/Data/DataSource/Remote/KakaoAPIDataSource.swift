import Foundation
import Alamofire

final class KakaoAPIDataSource {
  static let shared = KakaoAPIDataSource()

  typealias CompletionHandler = (Int, KakaoSearchResponseDTO?) -> Void

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
      .responseDecodable(of: KakaoSearchResponseDTO.self) { response in
        let code = response.response?.statusCode ?? 500
        switch response.result {
        case .success(let data):
          result(code, data)
        case .failure(let error):
          print("ERROR: \(error)")
          if let data = response.data, let raw = String(data: data, encoding: .utf8) {
            print("RAW RESPONSE: \(raw)")
          }
          result(code, nil)
        }
      }
  }
}
