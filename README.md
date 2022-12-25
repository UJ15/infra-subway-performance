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
- ./monitoring 디렉토리 내 before & after 테스트 결과 업로드 하였습니다.

2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요
- Reverse Proxy 개선
  - gzip 압축
  - cache 적용
  - TLS, HTTP/2 설정
- Was 성능 개선
  - cache 적용
    - 지하철 노선 조회
    - 지하철 역 조회
    - 경로 조회
---

### 2단계 - 스케일 아웃
[X] springboot에 HTTP Cache, gzip 설정하기
[X] Launch Template 작성하기
[X] Auto Scaling Group 생성하기
[X] Smoke, Load, Stress 테스트 후 결과를 기록

1. Launch Template 링크를 공유해주세요.
  - https://ap-northeast-2.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-2#LaunchTemplateDetails:launchTemplateId=lt-0f39af934127fa5c9

2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)
  - 아래 경로 참고 부탁드립니다.
    - ./monitoring/stress/step2/step2_stress_bulk_asg_ec2
    - ./monitoring/stress/step2/step2_stress_bulk_AutoScaling
```sh
$ stress -c 2
```

3. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)
  - 아래 경로 참고 부탁드립니다.
    - ./monitoring/smoke/step2
    - ./monitoring/load/step2
    - ./monitoring/stress/step2
---

### 3단계 - 쿼리 최적화

1. 인덱스 설정을 추가하지 않고 아래 요구사항에 대해 1s 이하(M1의 경우 2s)로 반환하도록 쿼리를 작성하세요.

- 활동중인(Active) 부서의 현재 부서관리자 중 연봉 상위 5위안에 드는 사람들이 최근에 각 지역별로 언제 퇴실했는지 조회해보세요. (사원번호, 이름, 연봉, 직급명, 지역, 입출입구분, 입출입시간)


- Query
  - 쿼리 소요 시간 : 1.645 sec
```mysql
-- (MySQL) chracter set이 'utf8mb4', 'utf8mb4_0900_ai_ci'이면 문자열 검색시 대소문자 비교하지 않음??
-- https://dev.mysql.com/doc/refman/8.0/en/case-sensitivity.html
    
-- The default character set and collation are utf8mb4 and utf8mb4_0900_ai_ci, so nonbinary string comparisons are case-insensitive by default. 
-- This means that if you search with col_name LIKE 'a%', you get all column values that start with A or a.
-- To make this search case-sensitive, make sure that one of the operands has a case-sensitive or binary collation. 
-- For example, if you are comparing a column and a string that both have the utf8mb4 character set, you can use the COLLATE operator to cause either operand to have the utf8mb4_0900_as_cs or utf8mb4_bin collation:

SELECT t.id AS 사원번호,
       t.last_name AS 이름,
       t.annual_income AS 연봉,
       t.position_name AS 직급명,
       r.time AS 입출입시간,
       r.region AS 지역,
       r.record_symbol AS 입출입구분
FROM (SELECT e.id, e.last_name, s.annual_income, p.position_name
      FROM department AS d
      INNER JOIN manager m ON m.department_id = d.id AND m.start_date < now() AND m.end_date > now()
      INNER JOIN employee e ON e.id = m.employee_id
      INNER JOIN position p ON p.id = m.employee_id AND LOWER(p.position_name) = 'manager'
      INNER JOIN salary s ON s.id = m.employee_id AND s.start_date < now() AND s.end_date > now()
      WHERE d.note = 'active'
      ORDER BY s.annual_income DESC LIMIT 5) AS t
INNER JOIN record r ON t.id = r.employee_id AND r.record_symbol = 'O'
;
```

- 쿼리 결과
![쿼리결과](step3/쿼리_결과.png)


- 실행 계획
![실행계획](step3/실행_계획.png)

---

### 4단계 - 인덱스 설계
- 주어진 데이터셋을 활용하여 아래 조회 결과를 100ms 이하로 반환
  - M1의 경우엔 시간 제약사항을 달성하기 어렵습니다. 2배를 기준으로 해보시고 어렵다면, 일단 리뷰요청 부탁드려요

1. 인덱스 적용해보기 실습을 진행해본 과정을 공유해주세요
- (4-1) Coding as a Hobby 와 같은 결과를 반환하세요.
  - Query / Fetch Time : ```0.434 sec``` / ```0.000019 sec```
```mysql
-- 인덱스 추가
ALTER TABLE `subway`.`programmer` ADD INDEX idx_programmer_hobby (hobby);

SELECT hobby, 
       ROUND(count(*) / (SELECT count(*) FROM programmer) * 100, 1) AS rate
FROM programmer
GROUP BY hobby
;
```
![쿼리결과](step4/4-1/인덱스_적용후_쿼리결과.png)

![실행계획](step4/4-1/인덱스_적용후_실행계획.png)


- (4-2) 프로그래머별로 해당하는 병원 이름을 반환하세요. (covid.id, hospital.name)
  - Query / Fetch Time : ```0.025 sec``` / ```0.016 sec```
```mysql
ALTER TABLE `subway`.`covid` ADD INDEX idx_hospital_id(hospital_id);
ALTER TABLE `subway`.`programmer` ADD CONSTRAINT pk_programmer PRIMARY KEY (id);

SELECT c.id, h.name
FROM hospital h
    INNER JOIN covid c ON h.id = c.hospital_id
    INNER JOIN programmer p ON c.programmer_id = p.id;
```
---
![쿼리결과](step4/4-2/인덱스_적용후_쿼리결과.png)

![실행계획](step4/4-2/인덱스_적용후_실행계획.png)


- (4-3) 프로그래밍이 취미인 학생 혹은 주니어(0-2년)들이 다닌 병원 이름을 반환하고 user.id 기준으로 정렬하세요. (covid.id, hospital.name, user.Hobby, user.DevType, user.YearsCoding)
  - Query / Fetch Time : ```0.061 sec``` / ```0.360 sec```
  
```mysql
-- 인덱스 추가 없음
SELECT c.id, h.name, p.hobby, p.dev_type, p.years_coding
FROM (SELECT id, hobby, dev_type, years_coding
      FROM programmer
      WHERE LOWER(hobby) = 'yes'
          AND years_coding = '0-2 years' OR LOWER(student) IN ('Yes, part_time', 'Yes, full-time')
      order by id
     ) p
    INNER JOIN covid c ON p.id = c.id
    INNER JOIN hospital h ON c.hospital_id = h.id;
```
---
![쿼리결과](step4/4-3/인덱스_적용후_쿼리결과.png)

![실행계획](step4/4-3/인덱스_적용후_실행계획.png)

- 서울대병원에 다닌 20대 India 환자들을 병원에 머문 기간별로 집계하세요. (covid.Stay)
  - Query / Fetch Time : ```0.131 sec``` / ```0.000014 sec```

```mysql
-- 인덱스 추가
ALTER TABLE `subway`.`hospital` ADD INDEX idx_name(name);
ALTER TABLE `subway`.`member` ADD CONSTRAINT pk_member PRIMARY KEY (id);

select c.stay, count(*)
from programmer p
    INNER JOIN covid c ON c.programmer_id = p.id AND p.country = 'India'
    INNER JOIN member m ON p.member_id = m.id AND m.age between 20 AND 29
    INNER JOIN hospital h ON h.id = c.hospital_id AND h.name = '서울대병원'
GROUP BY c.stay;
;
```
![쿼리결과](step4/4-4/인덱스_적용후_쿼리결과.png)

![실행계획](step4/4-4/인덱스_적용후_실행계획.png)

- 서울대병원에 다닌 30대 환자들을 운동 횟수별로 집계하세요. (user.Exercise)
  - Query / Fetch Time : ```0.177 sec``` / ```0.000020 sec```

```mysql
-- 인덱스 추가 없음

select p.exercise, count(*)
from hospital h
	INNER JOIN covid c ON c.hospital_id = h.id
    INNER JOIN programmer p ON p.id = c.programmer_id
	INNER JOIN member m ON m.id = c.member_id AND m.age between 30 AND 39
WHERE h.name = '서울대병원'
GROUP BY p.exercise
;
```

![쿼리결과](step4/4-5/인덱스_적용후_쿼리결과.png)

![실행계획](step4/4-5/인덱스_적용후_실행계획.png)

### 추가 미션

1. 페이징 쿼리를 적용한 API endpoint를 알려주세요
