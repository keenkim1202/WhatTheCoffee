# WhatTheCoffee

오늘 마실 커피를 추천하고, 방문한 카페를 기록하는 iOS 앱입니다.

## 기능

| 탭 | 내용 |
|---|---|
| 추천 | 커피 목록에서 랜덤 추천. 목록에 커피 직접 추가·수정·삭제 |
| 근처 카페 | 현재 위치 기준 카페 검색, 지도에 표시. 상세에서 바로 기록 |
| 기록 | 방문한 카페를 날짜·별점·코멘트·사진으로 기록. 방문 횟수와 마신 커피도 남깁니다. 지도에서 위치 확인, 폐점 체크 |
| 통계 | 방문 수, 평균 별점, 월별 차트, 별점 분포, 자주 간 카페·마신 커피 Top 5 |

- 기록 사진은 배경을 지워 스티커처럼 저장할 수 있습니다.
- 사진에서 피사체를 여러 개 찾으면 그중에서 고릅니다.
- 통계 화면은 눌러서 자세히 볼 수 있습니다.
- 월별 차트의 막대를 누르면 그달에 간 곳만 나옵니다.
- 위쪽 요약을 누르면 첫 방문부터 지금까지의 월별 추이를 보여줍니다.

### 그 밖의 기능

| 기능 | 내용 |
|---|---|
| 위젯 | 이번 달 방문 수, 최근 방문 또는 가까운 카페. 버튼 하나로 오늘 방문 기록. 잠금화면 지원 |
| 시리 | "왓더커피에 커피 기록"이라고 말하면 앱을 열지 않고 최근 카페에 방문을 더합니다 |
| 내보내기 | 설정에서 기록과 사진을 zip으로 묶어 내보냅니다 |

## 구조

- Clean Architecture + MVVM + Coordinator
- Code base UI (UIKit)

```
WhatTheCoffee/Sources/
├── App/           AppDelegate, SceneDelegate, DIContainer
│   └── Coordinator/   화면 전환 (탭별 + 공용 AddRecord)
├── Domain/        Entity, UseCase, RepositoryProtocol
├── Data/          Realm DataSource, DTO, Mapper, Repository 구현
├── Presentation/  탭별 ViewController + ViewModel
└── Common/        Extension, ImageManager, SharedImageStore

WhatTheCoffeeWidget/    위젯과 AppIntent
```

- 화면 전환은 Coordinator가 맡습니다.
- `DIContainer`는 `SceneDelegate`가 만들어 `AppCoordinator`에게 넘깁니다.
- 의존성은 Realm, Alamofire, IQKeyboardManager, TextFieldEffects, NMapsMap, Firebase이고, SPM으로 받습니다.

### 앱과 위젯이 공유하는 것

- 앱 샌드박스에 있으면 위젯이 읽지 못하기 때문에, Realm 파일과 사진은 앱 그룹 `group.keen.WhatTheCoffee` 안에 둡니다.
- 예전 위치에 남아 있던 파일은 첫 실행 때 옮깁니다.
- 스키마 버전과 마이그레이션 코드는 `RealmSchema` 한 곳에 두고 앱과 위젯이 같이 씁니다.
- 한쪽만 고치면 파일을 먼저 여는 쪽이 다르게 마이그레이션합니다.

## 필요한 파일

- `WhatTheCoffee/Supporting Files/` 에 두 파일이 있어야 빌드됩니다. 둘 다 gitignore 대상입니다.
- `APIKEY.plist`에 키 두 개를 넣습니다.
  - `KAKAO_APP_KEY`: `KakaoAK <REST API 키>` 형태로 넣습니다. Authorization 헤더에 그대로 실리기 때문에 접두사가 빠지면 카페 검색이 401로 실패합니다.
  - `NAVER_MAP_CLIENT_ID`: 네이버 지도 클라이언트 ID.
- `GoogleService-Info.plist`는 Firebase 콘솔에서 받습니다.

## 배포

```bash
bundle exec fastlane beta                          # TestFlight
bundle exec fastlane release                       # 앱스토어 업로드
bundle exec fastlane submit version:2.1 build:28   # 올라간 빌드로 심사 제출
```

- App Store Connect API 키를 환경변수로 넘깁니다. 없으면 Apple ID 대화형 로그인으로 넘어가 사람이 직접 실행해야 합니다.

```bash
ASC_KEY_PATH=... ASC_KEY_ID=... ASC_ISSUER_ID=... bundle exec fastlane release
```
