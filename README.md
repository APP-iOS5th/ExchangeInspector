# Exchange Inspector
실습 3팀 2차 프로젝트


## 설명
* 환율 API를 이용하여 주요 국가의 환율 변화를 시각적으로 파악할 수 있고, 환율을 계산할 수 있으며, 뉴스 API를 통해 환율이 변하게 된 각 나라의 경제적 상황을 알 수 있습니다.


## 프로젝트 기간
* 2024.6.3(월) ~ 2024.6.13(목)


## 팀원
* 어재선
* 한상현
* 황승혜


## 기능
1. 환율 리스트
   1. 5분 간격으로 API를 호출하여 업데이트
   2. 리스트의 각 국가를 선택하면 해당 국가와의 환율 계산기 사용 가능
2. 환율 계산기
   1. 국가를 선택하여 금액을 입력하면 원화로 계산
3. 뉴스
   1. API를 호출해 국가별 경제 뉴스를 검색하여 리스트업
   2. 뉴스를 선택하면 웹뷰로 해당 뉴스 연결


## 사용 API
1. 현재환율 API: <https://www.koreaexim.go.kr/ir/HPHKIR020M01?apino=2&viewtype=C&searchselect=&searchword=>
2. 네이버 검색 API: <https://developers.naver.com/docs/serviceapi/search/news/news.md>
