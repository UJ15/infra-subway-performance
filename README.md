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


### 1단계 - 화면 응답 개선하기
1. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)

#### 개선 전 측정
- Smoke : `k6/smoke/*`
![Smoke](k6/smoke/before_smoke_k6.png)
![Smoke](k6/smoke/after_smoke_k6.png)
![Smoke](k6/smoke/before_smoke_grafana.png)
![Smoke](k6/smoke/after_smoke_grafana.png)

- Load : `k6/load/*`
![Load](k6/load/before_load_k6.png)
![Load](k6/load/after_load_k6.png)
![Load](k6/load/before_load_grafana.png)
![Load](k6/load/after_load_grafana.png)

- Stress : `k6/stress/*`
![Stress](k6/stress/before_stress_k6.png)
![Stress](k6/stress/after_stress_k6.png)
![Stress](k6/stress/before_stress_grafana.png)
![Stress](k6/stress/after_stress_grafana.png)

2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요

#### 요구사항
- [ ] Reverse Proxy 개선
  - [x] 개선 전 측정 
  - [x] gzip 압축
  - [x] cache
  - [x] TLS, HTTP/2 설정
- [x] WAS 성능 개선
  - [x] Spring Data Cache
  - [x] 비동기 처리

---

### 2단계 - 스케일 아웃

#### 요구사항
- [ ] 모든 정적 자원에 대해 no-cache, private 설정을 하고 테스트 코드를 통해 검증
- [ ] 확장자는 css인 경우는 max-age를 1년, js인 경우는 no-cache, private 설정
- [ ] 모든 정적 자원에 대해 no-cache, no-store 설정이 가능한가?
- [ ] springboot에 HTTP Cache, gzip 설정
- [ ] Launch Template 작성
- [ ] Auto Scaling Group 생성
- [ ] Smoke, Load, Stress 테스트 후 결과를 기록

1. Launch Template 링크를 공유해주세요.

2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)

```sh
$ stress -c 2
```

3. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)

---

### 3단계 - 쿼리 최적화

1. 인덱스 설정을 추가하지 않고 아래 요구사항에 대해 1s 이하(M1의 경우 2s)로 반환하도록 쿼리를 작성하세요.

- 활동중인(Active) 부서의 현재 부서관리자 중 연봉 상위 5위안에 드는 사람들이 최근에 각 지역별로 언제 퇴실했는지 조회해보세요. (사원번호, 이름, 연봉, 직급명, 지역, 입출입구분, 입출입시간)

---

### 4단계 - 인덱스 설계

1. 인덱스 적용해보기 실습을 진행해본 과정을 공유해주세요

---

### 추가 미션

1. 페이징 쿼리를 적용한 API endpoint를 알려주세요
