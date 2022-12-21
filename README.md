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
전체 결과 경로: /performance  

**http_req_duration**

| 종류     | Before   | Nginx   | Nginx + WAS |
|--------|----------|---------|-------------|
| smoke  | 5.22ms   | 1.44ms  | 5.75ms      |
| load   | 5.72ms   | 1.19ms  | 1.13ms      |
| stress | 100.62ms | 10.25ms | 6.61ms      |

가장 중요한 지표라 생각되는 stress 테스트에서 개선되는 결과를 확인할 수 있었습니다.

<br/>

2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요

첫 번째 개선
- Nginx 
  - gzip 압축
  - cache 적용
  - TLS, HTTP/2 설정

두 번째 개선
- WAS
  - Spring Data Cache 적용



---

### 2단계 - 스케일 아웃

1. Launch Template 링크를 공유해주세요.  
[템플릿 링크](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#LaunchTemplateDetails:launchTemplateId=lt-0cf08f503f24c1f8c)


2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)
![Auto Scaling Cloudwatch](performance/stress/auto_scaling.png)


```sh
$ stress -c 2
```

3. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)  
   **http_req_duration**

| 종류            | Before   | Nginx   | Nginx + WAS | Auto Scaling |
|---------------|----------|---------|-------------|--------------|
| smoke         | 5.22ms   | 1.44ms  | 5.75ms      | 3.81ms       |
| load          | 5.72ms   | 1.19ms  | 1.13ms      | 3.6ms        |
| stress        | 100.62ms | 10.25ms | 6.61ms      | 5.2ms        |
| stress 600VUs | -        | -       | -           | 7.39ms       |

속도의 개선보다는 VUs를 늘린 stress 테스트에서 Auto Scaling 이 동작해서 부하 분산을 통해
병목 현상 및 서버 다운을 방지하는 모습을 확인했습니다.


---

### 3단계 - 쿼리 최적화

1. 인덱스 설정을 추가하지 않고 아래 요구사항에 대해 1s 이하(M1의 경우 2s)로 반환하도록 쿼리를 작성하세요.

- 활동중인(Active) 부서의 현재 부서관리자 중 연봉 상위 5위안에 드는 사람들이 최근에 각 지역별로 언제 퇴실했는지 조회해보세요. (사원번호, 이름, 연봉, 직급명, 지역, 입출입구분, 입출입시간)

**쿼리**
```sql
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

**조회결과**
![조회결과](query/step3/step3_query_result.png)

**arch**
![m1](query/m1.png)



---

### 4단계 - 인덱스 설계

1. 인덱스 적용해보기 실습을 진행해본 과정을 공유해주세요

#### 요구사항
- [x] 주어진 데이터셋을 활용하여 아래 조회 결과를 100ms 이하로 반환  
- M1의 경우엔 시간 제약사항을 달성하기 어렵습니다. 2배를 기준으로 해보시고 어렵다면, 일단 리뷰요청 부탁드려요
  - [x] Coding as a Hobby 와 같은 결과를 반환하세요.
  - [x] 프로그래머별로 해당하는 병원 이름을 반환하세요. (covid.id, hospital.name)
  - [x] 프로그래밍이 취미인 학생 혹은 주니어(0-2년)들이 다닌 병원 이름을 반환하고 user.id 기준으로 정렬하세요. (covid.id, hospital.name, user.Hobby, user.DevType, user.YearsCoding)
  - [x] 서울대병원에 다닌 20대 India 환자들을 병원에 머문 기간별로 집계하세요. (covid.Stay)
  - [x] 서울대병원에 다닌 30대 환자들을 운동 횟수별로 집계하세요. (user.Exercise)

<br/>

**추가한 인덱스**
```sql
ALTER TABLE `subway`.`covid` ADD INDEX `index_covid_id` (`id` ASC);
ALTER TABLE `subway`.`covid` ADD INDEX `index_covid_hospital_id` (`hospital_id` ASC);
ALTER TABLE `subway`.`covid` ADD INDEX `index_covid_programmer_id` (`programmer_id` ASC);
ALTER TABLE `subway`.`covid` ADD INDEX `index_covid_member_id` (`member_id` ASC);
ALTER TABLE `subway`.`hospital` ADD INDEX `index_hospital_id` (`id` ASC);
ALTER TABLE `subway`.`hospital` ADD INDEX `index_hospital_name` (`name` ASC);
ALTER TABLE `subway`.`member` ADD INDEX `index_member_id` (`id` ASC);
ALTER TABLE `subway`.`programmer` ADD INDEX `index_programmer_id` (`id` ASC);
ALTER TABLE `subway`.`programmer` ADD INDEX `index_programmer_hobby` (`hobby` ASC);
```

<br/>

**Coding as a Hobby 와 같은 결과를 반환하세요.**  
- query
```sql
select hobby as 취미,
       concat(round(count(*) / (select count(*) from programmer) * 100, 1), '%') as 퍼센트
from programmer
group by hobby
order by hobby desc;
```

- 결과
![4-1](query/step4/step4_1_query_result.png)

<br/>

**프로그래머별로 해당하는 병원 이름을 반환하세요. (covid.id, hospital.name)**
- query
```sql
select covid.id,
       hospital.name
from hospital
         join covid on covid.hospital_id = hospital.id
         join programmer on programmer.id = covid.programmer_id;
```

- 결과
![4-2](query/step4/step4_2_query_result.png)

<br/>

**프로그래밍이 취미인 학생 혹은 주니어(0-2년)들이 다닌 병원 이름을 반환하고 user.id 기준으로 정렬하세요. (covid.id, hospital.name, user.Hobby, user.DevType, user.YearsCoding)**
- query
```sql
select covid.id,
       hospital.name,
       programmer.hobby,
       programmer.dev_type,
       programmer.years_coding
from programmer
         join covid on covid.programmer_id = programmer.id
         join hospital on hospital.id = covid.hospital_id
where programmer.hobby = 'yes'
  and (programmer.student like 'Yes%' or programmer.years_coding = '0-2 years')
order by programmer.id;
```

- 결과
![4-3](query/step4/step4_3_query_result.png)

<br/>

**서울대병원에 다닌 20대 India 환자들을 병원에 머문 기간별로 집계하세요. (covid.Stay)**
- query
```sql
select covid.stay,
       count(*)
from programmer
         join covid on covid.programmer_id = programmer.id
         join hospital on hospital.id = covid.hospital_id
         join member on member.id = programmer.id
where hospital.name = '서울대병원'
  and programmer.country = 'india'
  and member.age between 20 and 29
group by covid.stay;    
```

- 결과
![4-4](query/step4/step4_4_query_result.png)

<br/>

**서울대병원에 다닌 30대 환자들을 운동 횟수별로 집계하세요. (user.Exercise)**
- query
```sql
select programmer.exercise,
       count(*)
from programmer
         join covid on covid.programmer_id = programmer.id
         join hospital on hospital.id = covid.hospital_id
         join member on member.id = programmer.id
where hospital.name = '서울대병원'
  and member.age between 30 and 39
group by programmer.exercise;
```

- 결과
![4-5](query/step4/step4_5_query_result.png)


---

### 추가 미션

1. 페이징 쿼리를 적용한 API endpoint를 알려주세요
