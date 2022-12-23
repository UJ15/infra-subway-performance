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
* smoke
- Before
![smoke.png](k6test%2Fsmoke%2Fbefore%2Fsmoke.png)
![smoke_dashboard.png](k6test%2Fsmoke%2Fbefore%2Fsmoke_dashboard.png)
- After
![smoke_after.png](k6test%2Fsmoke%2Fafter%2Fsmoke_after.png)
![smoke_after_dashboard.png](k6test%2Fsmoke%2Fafter%2Fsmoke_after_dashboard.png)
* Load
- Before
![load.png](k6test%2Fload%2Fbefore%2Fload.png)
![load_dashboard.png](k6test%2Fload%2Fbefore%2Fload_dashboard.png)
- After
![load_after.png](k6test%2Fload%2Fafter%2Fload_after.png)
![load_after_dashboard.png](k6test%2Fload%2Fafter%2Fload_after_dashboard.png)
* StressF
- Before
![stress.png](k6test%2Fstress%2Fbefore%2Fstress.png)
![smoke_dashboard.png](k6test%2Fstress%2Fbefore%2Fsmoke_dashboard.png)
- After
![stress_after.png](k6test%2Fstress%2Fafter%2Fstress_after.png)
![stress_after_dashboard.png](k6test%2Fstress%2Fafter%2Fstress_after_dashboard.png)

2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요
* Reverse Proxy
* gzip 압축
* cache
* TLS, HTTP/2 설정
* WAS 성능 개선
* Spring Data Cache
---

### 2단계 - 스케일 아웃

1. Launch Template 링크를 공유해주세요.
 - https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#LaunchTemplateDetails:launchTemplateId=lt-0f7f43df641776bc7
2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)
- cloudWatch autoscaling
![auto_scaling.PNG](k6test%2Fasg_ec2%2Fauto_scaling.PNG)
- cloudWatch ec2
![ec2.PNG](k6test%2Fasg_ec2%2Fec2.PNG)
* smoke
![smoke.png](k6test%2Fasg_smoke%2Fsmoke.png)
![smoke_grafana_cache.png](k6test%2Fasg_smoke%2Fsmoke_grafana_cache.png)
* Load
![load.png](k6test%2Fasg_load%2Fload.png)
![load_grafana_cache.png](k6test%2Fasg_load%2Fload_grafana_cache.png)
* Stress
![stress.png](k6test%2Fasg_stress%2Fstress.png)
![stress_grafana_cache.png](k6test%2Fasg_stress%2Fstress_grafana_cache.png)

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
