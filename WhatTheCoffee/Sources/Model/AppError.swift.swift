import UIKit

enum AppError: Error {
  case anything
  case loadInitData
  case network
  case failToSaveImage
  case failToLoadImage
  case failToDeleteImage
  case cannotFindPath
}

extension AppError {
  var localizedDescription: String {
    switch self {
    case .anything: return "😱오류가 발생했습니다. 앱을 다시 실행해주세요."
    case .loadInitData: return "초기 데이터를 불러오는데 실패하였습니다."
    case .network: return "😞네트워크 연결을 할 수 없습니다. 네트워크 연결을 확인해주세요."
    case .failToSaveImage: return "😞 이미지 저장에 실패하였습니다.\n다시 시도해주세요."
    case .failToLoadImage: return "😞 이미지 불러오기에 실패하였습니다.\n다시 시도해주세요."
    case .failToDeleteImage: return "😞 이미지 삭제에 실패하였습니다.\n다시 시도해주세요."
    case .cannotFindPath: return "저장 경로 찾기에 실패하였습니다."
    }
  }
}

extension AppError {
  var alert: UIAlertController {
    let alert = UIAlertController(title: "⚠️", message: self.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
    return alert
  }
}
