# WhatTheCoffee
- 오늘의 커피를 추천하고, 현재 사용자의 위치를 기준으로 가장 가까운 커피점을 추천합니다. 
- 자신이 방문한 카페에 대해 별점과 간단한 코멘트를 남길 수 있습니다.


# [TIL & TeamBuilding Records](https://ossified-gas-bd2.notion.site/2967f50a8f644f29af1b96d5981b2046?v=e7237813ce724507847d8d90f8af25b4)
- 제목에 연결된 링크를 통해 확인하실 수 있습니다.
- 달력에 날짜마다 하위 페이지를 생성하여 작성하였습니다.
- 원하는 날짜의 페이지를 선텍하여 작성 내용을 확인하실 수 있습니다.


# 앱 기획


## Tap 1 : RecommandCoffeeTap
|화면번호|1-1|1-2|1-3|
|:---:|:---:|:---:|:---:|
|UI|<img width= "90%" src="https://user-images.githubusercontent.com/59866819/141937584-009fe5ad-dc6b-4b45-9fe2-70dd6ae2f848.jpg" />|<img width= "90%" src="https://user-images.githubusercontent.com/59866819/141937587-4516cd8e-1cf8-46a1-969a-044f734605b9.jpg" />|<img width= "90%" src="https://user-images.githubusercontent.com/59866819/141937588-59b8621f-374c-469b-9e54-bf539a501e63.jpg" />|
|사용|Button|TableView|Button, TextField|
* 공통 : TapBarController, NavigationController, BarButtonItem, ImageView, Label

### 1-1 기능
- 앱을 실행하면 가장 처음 보이는 화면으로, 오늘의 커피를 추천합니다.
- 커피 종류에 따른 이미지와 커피 이름이 출력됩니다.
- '다시 추천 받기' 버튼을 누르면 커피 목록'에 있는 커피들 중 랜덤으로 새로운 커피를 추천합니다.

### 1-2 기능
- 기본으로 제공되는 커피 목록을 확인할 수 있습니다.
- 오른쪽 상단의 '추가' 버튼을 통해 사용자가 목록에 없는 새로운 커피를 추가할 수 있습니다.
- 커피는 새로 추가한 것이 가장 상단에 위치합니다.
- 목록에서 커피 cell을 클릭하면 이전에 입력한 커피 정보를 수정할 수 있습니다.
- 스와이프를 통해 커피 목록에서 제거할 수 있습니다.

### 1-3 기능
- 추가하고자 하는 커피 이미지와 이름을 입력합니다.
- 오른쪽 상단의 '완료'버튼을 누르면 커피목록에 추가됩니다.
- 왼쪽 상단의 '닫기' 버튼을 누르면 입력한 내용이 있던 없던 커피 목록에 추가되지 않으며 이전 화면으로 돌아갑니다.
- 커피 이름을 적지 않으면 '커피명을 입력해주세요'라는 경고문을 띄웁니다.
- 이미지를 등록하지 않으면 기본 커피 이미지로 설정됩니다.



# Tap 2 : NearCoffeeTap
|화면번호|2-1|2-2|
|:---:|:---:|:---:|
|UI|<img width= "70%" src="https://user-images.githubusercontent.com/59866819/141940234-e6050e5d-1767-48e7-a075-7b8d466f676e.jpg" />|<img width= "70%" src="https://user-images.githubusercontent.com/59866819/141940250-fea27dd1-7617-447c-ae0f-b4370e9d4166.jpg" />|
|사용|TableView|MapView|
* 공통 : TapBarController, NavigationController, BarButtonItem, ImageView, Label
### 2-1 기능
- 사용자의 현재 위치를 기준으로 근처 커피점 리스트를 보여줍니다. (최대 10개)
- 검색 바를 이용하여 원하는 커피점이 있는지 확인할 수 있습니다.
- 오른쪽 상단의 '지도보기'를 누르면 근처 커피점의 위치들을 pin으로 찍어 보여줍니다.
- 목록에서 카페cell을 클릭하면 카페의 상세 정보를 보여줍니다.

### 2-2 기능
- 카페의 상세 정보를 확인할 수 있습니다.
- 위치의 MapView에 해당 카페의 위치에 Pin을 찍어 화면에 보여줍니다.



# Tap 3 : CoffeeStampTap
|화면번호|3-1|3-2|
|:---:|:---:|:---:|
|UI|<img width= "70%" src="https://user-images.githubusercontent.com/59866819/141940826-21752fad-1abd-4c41-a665-ced443450cf0.jpg" />|<img width= "60%" src="https://user-images.githubusercontent.com/59866819/141944772-4ccf718b-1340-4a11-83be-d4f2d990d1bb.jpg" />|
|사용|CollectionView|ImagePicker, DatePicker|
* 공통 : TapBarController, NavigationController, BarButtonItem, ImageView, Label

### 3-1 기능
- 자신이 방문한 카페들에 대한 기록을 할 수 있습니다.
- 기록이 하나도 없을 경우 '아직 방문한 카페가 없으신가요?ㅠㅠ 방문한 카페가 있다면 채워주세요!' 라는 텍스트가 출력됩니다.
- cell에는 카페 사진, 방문일, 카페이름, 평점이 보여집니다.
- 현재 날짜를 기준으로 최신순으로 기록됩니다.
- 오른쪽 상단의 '+' 버튼을 통해 새로운 기록을 작성할 수 있습니다.
- 오른쪽 상단의 '편집' 버튼을 통해 카페 기록을 삭제할 수 있습니다.

### 3-2 기능
- 방문 기록을 작성할 수 있습니다.
- 이미지를 추가하지 않으면 기본 이미지들 중 랜덤하게 사진이 들어갑니다.
- '이미지 선택하기' 버튼을 통해 사용자가 원하는 사진를 지정할 수 있습니다.
- 'PickerView' 를 사용하여 방문 날짜를 선택할 수 있습니다. (년/일/월 정보까지만 선택가능합니다.)
- 날짜를 선택하지 않을 경우, 오늘 날짜로 지정됩니다.
- '카페 명' 이 비어있을 경우, 오른쪽 상단의 '완료' 버튼을 누르면 '카페 명을 입력해주세요' 라는 경고문을 띄웁니다.
- '코멘트'에 카페에서 먹은 음료/디저트, 카페 분위기 등 자유롭게 작성할 수 있습니다.

