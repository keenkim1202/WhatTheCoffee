import CoreLocation

/// 위젯에서 현재 위치를 한 번만 받아온다.
/// 앱과 달리 위젯은 잠깐 깨어났다 잠들기 때문에 계속 추적하지 않고 한 번 묻고 끝낸다.
enum WidgetLocation {

  /// 이보다 오래된 값은 다시 묻는다. 카페까지의 거리를 재는 데는 이 정도면 충분히 최신이다.
  private static let cacheLifetime: TimeInterval = 5 * 60

  /// 위치를 기다리다 위젯에 주어진 시간을 다 쓰면 아무것도 그리지 못한다.
  private static let timeout: TimeInterval = 5

  static func current() async -> CLLocation? {
    let fetcher = await LocationFetcher()

    guard await fetcher.isAvailable else { return nil }
    if let cached = await fetcher.cachedLocation(newerThan: cacheLifetime) { return cached }

    return await fetcher.request(timeout: timeout)
  }
}

/// CLLocationManager는 만들어진 스레드의 런루프로 콜백을 보낸다.
/// 백그라운드 스레드에서 만들면 런루프가 없어 응답이 영영 오지 않으므로 메인에 묶어둔다.
@MainActor
private final class LocationFetcher: NSObject {

  private let manager = CLLocationManager()
  private var continuation: CheckedContinuation<CLLocation?, Never>?
  private var timeoutTask: Task<Void, Never>?

  override init() {
    super.init()
    manager.delegate = self
    // 카페까지의 거리는 100m 단위면 충분하다. 정밀도를 낮추면 응답도 빨라진다.
    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
  }

  /// 위젯이 위치를 받을 수 있는 상태인지. 앱에서 권한을 준 적이 없으면 false다.
  var isAvailable: Bool {
    return manager.isAuthorizedForWidgetUpdates
  }

  func cachedLocation(newerThan lifetime: TimeInterval) -> CLLocation? {
    guard let location = manager.location else { return nil }
    guard -location.timestamp.timeIntervalSinceNow < lifetime else { return nil }
    return location
  }

  func request(timeout: TimeInterval) async -> CLLocation? {
    return await withCheckedContinuation { continuation in
      self.continuation = continuation

      // 응답이 아예 오지 않는 경우가 있어 스스로 끊는다.
      timeoutTask = Task { [weak self] in
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        guard !Task.isCancelled else { return }
        self?.finish(nil)
      }

      manager.requestLocation()
    }
  }

  /// 어느 경로로 끝나든 continuation은 한 번만 재개해야 한다.
  private func finish(_ location: CLLocation?) {
    timeoutTask?.cancel()
    timeoutTask = nil
    continuation?.resume(returning: location)
    continuation = nil
  }
}

// MARK: - CLLocationManagerDelegate
extension LocationFetcher: CLLocationManagerDelegate {
  /// 콜백은 manager를 만든 메인 스레드로 오므로 그 위에 있다고 단언해도 안전하다.
  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    MainActor.assumeIsolated { finish(locations.last) }
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    MainActor.assumeIsolated { finish(nil) }
  }
}
