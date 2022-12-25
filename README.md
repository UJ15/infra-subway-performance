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
+ k6 파일 폴더에 넣어뒀습니다 !


#### 성능 개선 전 (http_req_duration 기준 표 작성)
|        | http_req_duration(mean) | http_req_duration(max) | http_req_duration(med) |
|--------|-------------------------|------------------------|------------------------|
| LOAD   | 8.67ms                  | 424.79ms               | 8.21ms                 | 
| SMOKE  | 15.90ms                 | 781.65ms               | 9.04ms                 | 
| STRESS | 57.80ms                 | 353.37ms               | 39.08ms                | 


#### 성능 개선 후 (http_req_duration 기준 표 작성)
|        | http_req_duration(mean) | http_req_duration(max) | http_req_duration(med) |
|--------|-------------------------|------------------------|------------------------|
| LOAD   | 11.07ms                 | 879.08ms               | 9.08ms                 | 
| SMOKE  | 10.75ms                 | 128.89ms               | 10.34ms                | 
| STRESS | 11.16ms                 | 240.36ms               | 10.23ms                | 

2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요
- nginx gzip 압축, cache, HTTP/2 설정을 통해 리버스 프록시를 개선
-  redis와 Spring Data Cache를 이용하여 애플리케이션 내 조회 기능에 캐싱을 적용해 조회 성능을 개선
---

### 2단계 - 스케일 아웃

1. Launch Template 링크를 공유해주세요.
   https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#LaunchTemplateDetails:launchTemplateId=lt-07e6e939a016ef930
2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)

```sh
$ stress -c 2
```

3. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)

---

### 3단계 - 쿼리 최적화

1. 인덱스 설정을 추가하지 않고 아래 요구사항에 대해 1s 이하(M1의 경우 2s)로 반환하도록 쿼리를 작성하세요.

- 활동중인(Active) 부서의 현재 부서관리자 중 연봉 상위 5위안에 드는 사람들이 최근에 각 지역별로 언제 퇴실했는지 조회해보세요. (사원번호, 이름, 연봉, 직급명, 지역, 입출입구분, 입출입시간)
``` sql
select A.id                 as 사원번호,
       A.last_name          as 이름,
       A.annual_income      as 연봉,
       A.position_name      as 직급명,
       record.time          as 입출입시간,
       record.region        as 지역,
       record.record_symbol as 입출입구분
from (select employee.id,
             employee.last_name,
             position.position_name,
             salary.annual_income
      from department
               join manager on department.id = manager.department_id
               join position on position.id = manager.employee_id
               join employee on employee.id = manager.employee_id
               join salary on salary.id = manager.employee_id
      where department.note = 'active'
        and manager.end_date = '9999-01-01'
        and position.end_date = '9999-01-01'
        and salary.end_date = '9999-01-01'
      order by salary.annual_income desc limit 5) as A
         join record on employee_id = A.id
where record.record_symbol = 'O';
```
---

### 4단계 - 인덱스 설계

1. 인덱스 적용해보기 실습을 진행해본 과정을 공유해주세요<br>
- [ ] 주어진 데이터셋을 활용하여 아래 조회 결과를 100ms 이하로 반환
- [ ] M1의 경우엔 시간 제약사항을 달성하기 어렵습니다. 
- 2배를 기준으로 해보시고 어렵다면, 일단 리뷰요청 부탁드려요
#### 1-2 Coding as a Hobby 와 같은 결과를 반환하세요.
```sql
# 인덱스 설정전 : 1s 691ms 
# 인덱스 설정후 : 65ms
select hobby, round((count(1) / (select count(id) from programmer) * 100), 2) as is_coding
from programmer
group by hobby;

ALTER TABLE programmer ADD CONSTRAINT programmer_pk PRIMARY KEY (id);
CREATE INDEX programmer_hobby_index ON programmer (hobby);

```

#### 1-2 프로그래머별로 해당하는 병원 이름을 반환하세요. (covid.id, hospital.name)
```sql
# 인덱스 설정전 : 227ms
# 인덱스 설정후 : 16ms
SELECT 
    c.id, 
    h.name
FROM hospital h
         INNER JOIN covid c ON h.id = c.hospital_id
         INNER JOIN programmer p ON c.programmer_id = p.id;

ALTER TABLE hospital ADD CONSTRAINT hospital_pk PRIMARY KEY (id);
CREATE INDEX covid_programmer_id_index ON covid (programmer_id);

```
#### 1-3 프로그래밍이 취미인 학생 혹은 주니어(0-2년)들이 다닌 병원 이름을 반환하고 user.id 기준으로 정렬하세요. (covid.id, hospital.name, user.Hobby, user.DevType, user.YearsCoding)
```sql
# 인덱스 설정전 : 16ms
SELECT covid.id,
       hospital.NAME,
       student.hobby,
       student.dev_type,
       student.years_coding
FROM covid
         INNER JOIN hospital ON covid.hospital_id = hospital.id
         INNER JOIN (SELECT id,
                            years_coding,
                            hobby,
                            dev_type
                     FROM programmer
                     WHERE hobby = 'Yes'
                       AND (years_coding = '0-2 years'
                         OR student IN ('Yes, full-time',
                                        'Yes, part-time'))) student
                    ON covid.programmer_id = student.id
ORDER BY student.id;

```
#### 1-4 서울대병원에 다닌 20대 India 환자들을 병원에 머문 기간별로 집계하세요. (covid.Stay)
```sql
# 인덱스 설정전 : 1s 710ms
# 인덱스 설정후 : 1s 80ms
SELECT c.stay,
       COUNT(c.id) AS count
FROM member m
         INNER JOIN covid c ON m.id = c.member_id AND m.age BETWEEN 20 AND 29
         INNER JOIN hospital h ON c.hospital_id = h.id AND h.`name` = '서울대병원'
         INNER JOIN programmer p ON p.id = c.programmer_id AND p.country = 'India'
GROUP BY c.stay;

ALTER TABLE covid ADD CONSTRAINT covid_pk PRIMARY KEY (id);
CREATE INDEX covid_hospital_id_index ON covid (hospital_id);
```
#### 1-5 서울대병원에 다닌 30대 환자들을 운동 횟수별로 집계하세요. (user.Exercise)
```sql
# 인덱스 설정전 : 8s 407ms
# 인덱스 설정후 : 726ms
SELECT exercise,
       Count(*)
FROM   programmer
          INNER JOIN covid ON programmer.id = covid.programmer_id
          INNER JOIN hospital ON covid.hospital_id = hospital.id AND hospital.NAME = '서울대병원'
          INNER JOIN member ON covid.member_id = member.id AND member.age BETWEEN 30 AND 39
GROUP  BY exercise;

ALTER TABLE member ADD CONSTRAINT member_pk PRIMARY KEY (id);
CREATE INDEX covid_member_id_index ON covid (member_id);

```
---

### 추가 미션

1. 페이징 쿼리를 적용한 API endpoint를 알려주세요
