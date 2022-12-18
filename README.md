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

- 성능 테스트 조건 근거
  - https://github.com/seogineer/infra-subway-monitoring/tree/step3

### smoke.js
```javascript
import http from 'k6/http';
import { check, group, sleep, fail } from 'k6';

export let options = {
  vus: 600, // 1 user looping for 1 minute
  duration: '1800s',

  thresholds: {
    http_req_duration: ['p(99)<1500'], // 99% of requests must complete below 1.5s
  },
};

const BASE_URL = 'https://seogineer.kro.kr';
const USERNAME = 'dgseo8981@gmail.com';
const PASSWORD = '1234';

export default function ()  {
  // login
  var payload = JSON.stringify({
    email: USERNAME,
    password: PASSWORD,
  });

  var params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  let loginRes = http.post(`${BASE_URL}/login/token`, payload, params);

  check(loginRes, {
    'logged in successfully': (resp) => resp.json('accessToken') !== '',
  });

  let authHeaders = {
    headers: {
      Authorization: `Bearer ${loginRes.json('accessToken')}`,
    },
  };
  let myObjects = http.get(`${BASE_URL}/members/me`, authHeaders).json();
  check(myObjects, { 'retrieved member': (obj) => obj.id != 0 });
  sleep(1);

  // lending page
  let homeUrl = `${BASE_URL}`;
  let lendingPageResponse = http.get(homeUrl);
  check(lendingPageResponse, {
      'lending page running': (response) => response.status === 200
  });
};
```

### load.js
```javascript
import http from 'k6/http';
import { check, group, sleep, fail } from 'k6';

export let options = {
    stages: [
      { duration: '600s', target: 300 },
    ],

    thresholds: {
        http_req_duration: ['p(99)<1500'],
    },
};

const BASE_URL = 'https://seogineer.kro.kr';
const USERNAME = 'dgseo8981@gmail.com';
const PASSWORD = '1234';

export default function () {
    // login
    var payload = JSON.stringify({
        email: USERNAME,
        password: PASSWORD,
    });
    
    var params = {
        headers: {
          'Content-Type': 'application/json',
        },
    };
    
    let loginRes = http.post(`${BASE_URL}/login/token`, payload, params);
    
    check(loginRes, {
        'logged in successfully': (resp) => resp.json('accessToken') !== '',
    });
    
    // myinfo
    let authHeaders = {
        headers: {
            Authorization: `Bearer ${loginRes.json('accessToken')}`,
        },
    };
    let myObjects = http.get(`${BASE_URL}/members/me`, authHeaders).json();
    check(myObjects, {'retrieved member': (obj) => obj.id != 0});

    // create line
    let createLineUrl = `${BASE_URL}/lines`;
    let lineRandomNumber = Math.random().toString().split('.')[1];
    let createLinePayload = JSON.stringify({
        name: `testLine-${lineRandomNumber}`,
        color: "grey darken-4",
        upStationId: 1,
        downStationId: 2,
        distance: 10,
    });
    let createLineParams = {
        headers: {
            'Authorization': `Bearer ${loginRes.json('accessToken')}`,
            'Content-Type': 'application/json',
        },
    };
    let createLinesResponse = http.post(createLineUrl, createLinePayload, createLineParams);
    check(createLinesResponse, {
        'created Line successfully': (response) => response.status === 201,
    });
}
```

### stress.js
```javascript
import http from 'k6/http';
import { check, group, sleep, fail } from 'k6';

export let options = {
    stages: [
      { duration: '300s', target: 100 },
      { duration: '300s', target: 200 },
      { duration: '300s', target: 300 },
      { duration: '300s', target: 400 },
      { duration: '300s', target: 500 },
      { duration: '300s', target: 600 },
    ],
    thresholds: {
        http_req_duration: ['p(99)<1500'],
    },
};

const BASE_URL = 'https://seogineer.kro.kr';
const USERNAME = 'dgseo8981@gmail.com';
const PASSWORD = '1234';

export default function ()  {
  // login
  var payload = JSON.stringify({
    email: USERNAME,
    password: PASSWORD,
  });

  var params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  let loginRes = http.post(`${BASE_URL}/login/token`, payload, params);

  check(loginRes, {
    'logged in successfully': (resp) => resp.json('accessToken') !== '',
  });

  // myinfo
  let authHeaders = {
    headers: {
      Authorization: `Bearer ${loginRes.json('accessToken')}`,
    },
  };
  let myObjects = http.get(`${BASE_URL}/members/me`, authHeaders).json();
  check(myObjects, { 'retrieved member': (obj) => obj.id != 0 });

  // create line
  let createLineUrl = `${BASE_URL}/lines`;
  let lineRandomNumber = Math.random().toString().split('.')[1];
  let createLinePayload = JSON.stringify({
      name: `testLine-${lineRandomNumber}`,
      color: "grey darken-4",
      upStationId: 1,
      downStationId: 2,
      distance: 10,
  });
  let createLineParams = {
      headers: {
          'Authorization': `Bearer ${loginRes.json('accessToken')}`,
          'Content-Type': 'application/json',
      },
  };
  let createLinesResponse = http.post(createLineUrl, createLinePayload, createLineParams);
  check(createLinesResponse, {
      'created Line successfully': (response) => response.status === 201,
  });
}
```
### gzip 압축 적용

| Before                                                    | After                                                        |
|-----------------------------------------------------------|--------------------------------------------------------------|
| ![before_smoke_test](image/step1/before/smoke_test.png)   | ![after_smoke_test](image/step1/after/gzip/smoke_test.png)   |
| ![before_load_test](image/step1/before/load_test.png)     | ![after_load_test](image/step1/after/gzip/load_test.png)     |
| ![before_stress_test](image/step1/before/stress_test.png) | ![after_stress_test](image/step1/after/gzip/stress_test.png) |

### gzip 압축 적용 + cache 적용

| Before                                                    | After                                                                |
|-----------------------------------------------------------|----------------------------------------------------------------------|
| ![before_smoke_test](image/step1/before/smoke_test.png)   | ![after_smoke_test](image/step1/after/gzipAndCache/smoke_test.png)   |
| ![before_load_test](image/step1/before/load_test.png)     | ![after_load_test](image/step1/after/gzipAndCache/load_test.png)     |
| ![before_stress_test](image/step1/before/stress_test.png) | ![after_stress_test](image/step1/after/gzipAndCache/stress_test.png) |

### gzip 압축 적용 + cache 적용 + TLS, HTTP/2 설정

| Before                                                    | After                                                                        |
|-----------------------------------------------------------|------------------------------------------------------------------------------|
| ![before_smoke_test](image/step1/before/smoke_test.png)   | ![after_smoke_test](image/step1/after/gzipAndCacheAndHttp2/smoke_test.png)   |
| ![before_load_test](image/step1/before/load_test.png)     | ![after_load_test](image/step1/after/gzipAndCacheAndHttp2/load_test.png)     |
| ![before_stress_test](image/step1/before/stress_test.png) | ![after_stress_test](image/step1/after/gzipAndCacheAndHttp2/stress_test.png) |

### redis

| gzip 압축 적용 + cache 적용                                        | redis 추가                                                                     |
|--------------------------------------------------------------|------------------------------------------------------------------------------|
| ![after_smoke_test](image/step1/after/gzipAndCache/smoke_test.png) | ![after_smoke_test]()   |
| ![after_load_test](image/step1/after/gzipAndCache/load_test.png) | ![after_load_test]()     |
| ![after_stress_test](image/step1/after/gzipAndCache/stress_test.png) | ![after_stress_test]() |

2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요

- Reverse Proxy 개선
  - gzip 압축
  - cache
  - TLS, HTTP/2 설정
    - 원인은 모르겠으나 위 설정 후에 부하 테스트 시에 "ERRO[1804] some thresholds have failed"가 보임. 

- redis

---

### 2단계 - 스케일 아웃

1. Launch Template 링크를 공유해주세요.

2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)

```sh
$ stress -c 2
```

3. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)

---

### 1단계 - 쿼리 최적화

1. 인덱스 설정을 추가하지 않고 아래 요구사항에 대해 1s 이하(M1의 경우 2s)로 반환하도록 쿼리를 작성하세요.

- 활동중인(Active) 부서의 현재 부서관리자 중 연봉 상위 5위안에 드는 사람들이 최근에 각 지역별로 언제 퇴실했는지 조회해보세요. (사원번호, 이름, 연봉, 직급명, 지역, 입출입구분, 입출입시간)

---

### 2단계 - 인덱스 설계

1. 인덱스 적용해보기 실습을 진행해본 과정을 공유해주세요

---

### 추가 미션

1. 페이징 쿼리를 적용한 API endpoint를 알려주세요
