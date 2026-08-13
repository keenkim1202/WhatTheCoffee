import Foundation
import Alamofire

final class KakaoAPIDataSource {
  static let shared = KakaoAPIDataSource()

  typealias CompletionHandler = (Result<KakaoSearchResponseDTO, AppError>) -> Void

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
      // 2xx만 성공으로 본다. 이전에는 4xx·5xx까지 성공으로 받아
      // 디코딩 실패로 뭉뚱그려져 원인을 알 수 없었다.
      .validate(statusCode: 200..<300)
      .responseDecodable(of: KakaoSearchResponseDTO.self) { response in
        switch response.result {
        case .success(let data):
          result(.success(data))
        case .failure(let error):
          result(.failure(Self.appError(from: error, statusCode: response.response?.statusCode)))
        }
      }
  }

  /// 사용자가 할 수 있는 일이 다르므로 원인을 구분한다.
  private static func appError(from error: AFError, statusCode: Int?) -> AppError {
    if let statusCode {
      return (500...599).contains(statusCode) ? .serverError : .requestFailed
    }

    guard let urlError = error.underlyingError as? URLError else { return .requestFailed }

    switch urlError.code {
    case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .cannotConnectToHost, .cannotFindHost:
      return .network
    case .timedOut:
      return .timeout
    default:
      return .requestFailed
    }
  }
}
