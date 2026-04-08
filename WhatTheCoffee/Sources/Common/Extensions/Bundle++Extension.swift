import Foundation

extension Bundle {
  var apiKey: String {
    guard let file = self.path(forResource: "APIKEY", ofType: "plist"),
          let resource = NSDictionary(contentsOfFile: file),
          let key = resource["KAKAO_APP_KEY"] as? String
    else { fatalError("APIKEY.plist에 KAKAO_APP_KEY 설정을 해주세요.") }
    return key
  }

  var naverMapClientId: String {
    guard let file = self.path(forResource: "APIKEY", ofType: "plist"),
          let resource = NSDictionary(contentsOfFile: file),
          let key = resource["NAVER_MAP_CLIENT_ID"] as? String
    else { fatalError("APIKEY.plist에 NAVER_MAP_CLIENT_ID 설정을 해주세요.") }
    return key
  }
}
