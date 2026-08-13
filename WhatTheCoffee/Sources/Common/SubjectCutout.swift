import UIKit
import Vision

/// 사진에서 피사체만 떼어내 배경이 투명한 이미지를 만든다.
/// 사진 앱에서 길게 눌러 스티커를 만드는 것과 같은 온디바이스 모델을 쓴다.
enum SubjectCutout {

  struct Subject {
    let title: String
    let image: UIImage
    /// 배경을 지운 결과인지. 원본은 배경이 꽉 차 있어 윤곽선을 그려도 보이지 않는다.
    let isCutout: Bool

    init(title: String, image: UIImage, isCutout: Bool = true) {
      self.title = title
      self.image = image
      self.isCutout = isCutout
    }
  }

  enum Failure: Error {
    /// 사진에서 떼어낼 피사체를 찾지 못함.
    case subjectNotFound
    /// 사진을 분석에 넘길 형태로 만들지 못함.
    case unreadableImage
  }

  /// 사진에서 찾은 피사체들. 둘 이상이면 전부 합친 것을 맨 앞에 둔다.
  /// 잔과 받침처럼 하나로 봐야 자연스러운 경우가 있어서 합친 선택지를 남긴다.
  ///
  /// 분석은 수백 밀리초가 걸릴 수 있어 호출한 쪽을 막지 않는다. 완료는 메인 큐에서 전달한다.
  static func extractSubjects(from image: UIImage, completion: @escaping (Result<[Subject], Error>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let result = extractSubjects(from: image)
      DispatchQueue.main.async { completion(result) }
    }
  }

  private static func extractSubjects(from image: UIImage) -> Result<[Subject], Error> {
    guard let cgImage = cgImage(from: image) else {
      return .failure(Failure.unreadableImage)
    }

    let request = VNGenerateForegroundInstanceMaskRequest()
    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation)

    do {
      try handler.perform([request])

      guard let observation = request.results?.first, !observation.allInstances.isEmpty else {
        return .failure(Failure.subjectNotFound)
      }

      let instances = Array(observation.allInstances)
      var subjects: [Subject] = []

      if instances.count > 1,
         let combined = maskedImage(observation, instances: observation.allInstances, handler: handler) {
        subjects.append(Subject(title: "전체", image: combined))
      }

      for (offset, instance) in instances.enumerated() {
        guard let image = maskedImage(observation, instances: [instance], handler: handler) else { continue }
        subjects.append(Subject(title: "피사체 \(offset + 1)", image: image))
      }

      guard !subjects.isEmpty else {
        return .failure(Failure.subjectNotFound)
      }
      return .success(subjects)
    } catch {
      return .failure(error)
    }
  }

  /// 사진 라이브러리에서 온 UIImage는 CIImage 기반일 수 있고, 그때 cgImage는 nil이다.
  /// 그대로 포기하면 모델을 돌려보지도 못하고 피사체가 없다고 판단하게 된다.
  private static func cgImage(from image: UIImage) -> CGImage? {
    if let cgImage = image.cgImage {
      return cgImage
    }
    if let ciImage = image.ciImage {
      return CIContext().createCGImage(ciImage, from: ciImage.extent)
    }

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = image.scale
    format.opaque = false
    let redrawn = UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
      image.draw(at: .zero)
    }
    return redrawn.cgImage
  }

  private static func maskedImage(_ observation: VNInstanceMaskObservation,
                                  instances: IndexSet,
                                  handler: VNImageRequestHandler) -> UIImage? {
    guard let buffer = try? observation.generateMaskedImage(
      ofInstances: instances,
      from: handler,
      croppedToInstancesExtent: true) else { return nil }

    let ciImage = CIImage(cvPixelBuffer: buffer)
    guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else { return nil }
    return UIImage(cgImage: cgImage)
  }
}

private extension UIImage {
  /// Vision은 CGImage를 쓰므로 UIImage가 들고 있던 회전 정보를 따로 넘겨야 한다.
  var cgImageOrientation: CGImagePropertyOrientation {
    switch imageOrientation {
    case .up: return .up
    case .down: return .down
    case .left: return .left
    case .right: return .right
    case .upMirrored: return .upMirrored
    case .downMirrored: return .downMirrored
    case .leftMirrored: return .leftMirrored
    case .rightMirrored: return .rightMirrored
    @unknown default: return .up
    }
  }
}
