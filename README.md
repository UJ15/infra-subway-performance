<p align="center">
    <img width="200px;" src="https://raw.githubusercontent.com/woowacourse/atdd-subway-admin-frontend/master/images/main_logo.png"/>
</p>
<p align="center">
  <img alt="npm" src="https://img.shields.io/badge/npm-%3E%3D%205.5.0-blue">
  <img alt="node" src="https://img.shields.io/badge/node-%3E%3D%209.3.0-blue">
  <a href="https://edu.nextstep.camp/c/R89PYi5H" alt="nextstep atdd">
    <img alt="Website" src="https://img.shields.io/website?url=https%3A%2F%2Fedu.nextstep.camp%2Fc%2FR89PYi5H">
  </a>
  <img alt="GitHub" src="https://img.shields.io/github/license/next-step/atdd-subway-service">
</p>

<br>

# 인프라공방 샘플 서비스 - 지하철 노선도

<br>

## 🚀 Getting Started

### Install
#### npm 설치
```
cd frontend
npm install
```
> `frontend` 디렉토리에서 수행해야 합니다.

### Usage
#### webpack server 구동
```
npm run dev
```
#### application 구동
```
./gradlew clean build
```
<br>

## 미션

* 미션 진행 후에 아래 질문의 답을 작성하여 PR을 보내주세요.


## 1단계 - 화면 응답 개선하기
### 요구사항
- 부하테스트 각 시나리오의 요청시간을 목푯값 이하로 개선
  - 개선 전/후를 직접 계측하여 확인
- [x] reverse proxy 개선
    - cache 활성화
    - http2 적용
    - gzip 압축 적용
- [x] was 개선
  - redis 적용

### 튜닝 전 웹 성능
|               | RUNNINGMAP | 서울교통공사 | 네이버지도  | 카카오맵 |
|---------------|------------|----------|----------|--------|
| Total Bytes   | 2462kb     | 1067kb   | 941kb    | 1456kb |

- First Contentful Paint : 첫 번째 텍스트 또는 이미지가 표시되는 시간
- Largest Contentful Paint : 최대 텍스트 또는 이미지가 표시되는 시간
- Time to Interactive : 사용할 수 있을 때까지 걸리는 시간(완전히 페이지와 상호작용할 수 있게 될 때까지 걸리는 시간)
- Total Blocking Time : FCP와 상호작용 시간 사이의 모든 시간의 합
- Cumulative Layout Shift : 영역 내 이동을 측정

#### MOBILE

|     | RUNNINGMAP                              | 서울교통공사                              | 네이버지도                                   | 카카오맵                                   |
|-----|-----------------------------------------|-------------------------------------|-----------------------------------------|----------------------------------------|
| 성능 | <span style="color:red">34</span>       | <span style="color:red">33</span>   | <span style="color:orange">53</span>    | <span style="color:orange">66</span>   |
| FCP | <span style="color:red">14.9s</span>    | <span style="color:red">6.4s</span> | <span style="color:orange">2.4s</span>  | <span style="color:green">1.7s</span>  |
| LCP | <span style="color:red">15.4s</span>    | <span style="color:red">6.8s</span> | <span style="color:red">7.5s</span>     | <span style="color:red">6.8s</span>    |
| TTI | <span style="color:red">15.4s</span>    | <span style="color:red">8.5s</span> | <span style="color:orange">6.5s</span>  | <span style="color:orange">5.2s</span> |
| TBT | <span style="color:orange">460ms</span> | <span style="color:red">790</span>  | <span style="color:orange">420ms</span> | <span style="color:green">100ms</span> |
| CLS | <span style="color:green">0.042</span>  | <span style="color:green">0</span>  | <span style="color:green">0.03</span>   | <span style="color:green">0.005</span> |

#### PC

|     | RUNNINGMAP                             | 서울교통공사                                       | 네이버지도                                  | 카카오맵                                   |
|-----|----------------------------------------|----------------------------------------------|----------------------------------------|----------------------------------------|
| 성능 | <span style="color:orange">65</span>   | <span style="color:red">44</span>            | <span style="color:green">90</span>    | <span style="color:green">90</span>    |
| FCP | <span style="color:red">2.7s</span>    | <span style="color:orange1">1.4s</span>      | <span style="color:green">0.5s</span>  | <span style="color:green">0.5s</span>  |
| LCP | <span style="color:red">2.8s</span>    | <span style="color:red">3.8s</span>          | <span style="color:orange">1.5s</span> | <span style="color:orange">1.4s</span> |
| TTI | <span style="color:orange">2.8s</span> | <span style="color:green">2.2s</span>        | <span style="color:green">1.2s</span>  | <span style="color:green">0.7s</span>  |
| TBT | <span style="color:green">50ms</span>  | <span style="color:red">620ms</span> | <span style="color:green">10ms</span>  | <span style="color:green">0ms</span>   |
| CLS | <span style="color:green">0.004</span> | <span style="color:green">0.001</span>       | <span style="color:green">0.006</span> | <span style="color:green">0.039</span> |


1. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)
- `docs/step1/` 하위에 결과 올려두었습니다.
  - reverse proxy(nginx) 먼저 개선하였을 때의 부하 테스트 결과와 was 개선 이후의 테스트 결과를 각각 넣어두었습니다.

2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요

**[ reverse proxy ]**
- gzip 압축을 통해 정적 컨텐츠 크기 줄임
- 텍스트 기반 파일(js, css, html..)의 인코딩 및 전송 크기 최적화
- 1 ~ 9단계 중 가장 높은 단계로 압축함 (높은 단계로 압축하면 조금 느릴 수 있다고 함)
- cache 설정
  - 유저 쿠키별로 캐시 구성하며, 10분간 접근 하지 않은 캐시는 제거됨
  - 정적 컨텐츠 대상으로 캐시하며, 해당 내용은 access log를 찍지 않음
  - X-Proxy-Cache 헤더를 추가함으로써 크롬에서 개발자도구로 https://earth-h.tk 접근 시, request header에서 캐시 적중여부 확인 가능
- HTTP/1.1 대신 HTTP/2 사용
  - 하나의 TCP 연결을 통해 다수의 클라이언트 요청과 서버 응답이 비동기 방식으로 이루어질 수 있음
    - 요청과 응답이 message 단위로 구성되고, 이는 frame 등으로 나뉘어 stream 구조를 취하기 때문

**[ was ]**
- caching 설정
  - 서비스레이어에서 캐싱 설정
    - 조회 로직은 캐싱하고, 삭제/수정/등록 로직에서는 캐시를 삭제함

---

## 2단계 - 스케일 아웃

1. Launch Template 링크를 공유해주세요.

2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)

```sh
$ stress -c 2
```

3. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)

---

## 3단계 - 쿼리 최적화

1. 인덱스 설정을 추가하지 않고 아래 요구사항에 대해 1s 이하(M1의 경우 2s)로 반환하도록 쿼리를 작성하세요.

- 활동중인(Active) 부서의 현재 부서관리자 중 연봉 상위 5위안에 드는 사람들이 최근에 각 지역별로 언제 퇴실했는지 조회해보세요. (사원번호, 이름, 연봉, 직급명, 지역, 입출입구분, 입출입시간)

---

### 4단계 - 인덱스 설계

1. 인덱스 적용해보기 실습을 진행해본 과정을 공유해주세요

---

### 추가 미션

1. 페이징 쿼리를 적용한 API endpoint를 알려주세요
