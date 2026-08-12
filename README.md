# WhatTheCoffee

오늘 마실 커피를 추천하고, 방문한 카페를 기록하는 iOS 앱.

## 기능

| 탭 | 내용 |
|---|---|
| 추천 | 커피 목록에서 랜덤 추천. 목록에 커피 직접 추가·수정·삭제 |
| 근처 카페 | 현재 위치 기준 카페 검색, 지도에 표시 |
| 기록 | 방문한 카페를 날짜·별점·코멘트·사진으로 기록. 지도에서 위치 확인, 폐점 체크 |
| 통계 | 방문 수, 평균 별점, 월별 차트, 별점 분포, 자주 간 카페 Top 5 |

## 구조

Clean Architecture + MVVM. Storyboard 없이 코드로 UI 구성.

```
WhatTheCoffee/Sources/
├── App/           DIContainer, AppDelegate, SceneDelegate
├── Domain/        Entity, UseCase, RepositoryProtocol
├── Data/          Realm DataSource, DTO, Mapper, Repository 구현
├── Presentation/  탭별 ViewController + ViewModel
└── Common/        Extension, ImageManager
```

의존성은 전부 SPM — Realm, Alamofire, IQKeyboardManager, TextFieldEffects, NMapsMap, Firebase.

## 실행 준비

`WhatTheCoffee/Supporting Files/` 에 두 파일이 필요하다. 둘 다 gitignore 대상.

- `APIKEY.plist` — `KAKAO_APP_KEY`(`KakaoAK <REST API 키>` 형태로 넣는다. Authorization 헤더에 그대로 실린다), `NAVER_MAP_CLIENT_ID`
- `GoogleService-Info.plist` — Firebase 콘솔에서 받는다

## 배포

```bash
bundle exec fastlane beta      # TestFlight
bundle exec fastlane release   # 앱스토어 업로드 (심사 제출은 App Store Connect에서)
```

App Store Connect API 키가 필요하다.

```bash
ASC_KEY_PATH=... ASC_KEY_ID=... ASC_ISSUER_ID=... bundle exec fastlane release
```
