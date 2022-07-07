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
#### 1. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)
* Smoke
  * Before: /loadtest/step1/before_smoke.png
  * After: /loadtest/step1/after_smoke.png
* Load
  * Before: /loadtest/step1/before_load.png
  * After: /loadtest/step1/after_load.png
* Stress
  * Before: /loadtest/step1/before_stress.png
  * After: /loadtest/step1/after_stress.png

#### 2. 어떤 부분을 개선해보셨나요? 과정을 설명해주세요
* Nginx
  * gzip 압축
  * 정적 리소스 캐싱
  * http2 설정
* WAS
  * Redis 캐시 설정

---

### 2단계 - 스케일 아웃

#### 1. Launch Template 링크를 공유해주세요.
* [ttungga-launch-template](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#LaunchTemplateDetails:launchTemplateId=lt-0a27f24997617b038)

#### 2. cpu 부하 실행 후 EC2 추가생성 결과를 공유해주세요. (Cloudwatch 캡쳐)
* /loadtest/step2/cloudwatch_stress_2x.png

3. 성능 개선 결과를 공유해주세요 (Smoke, Load, Stress 테스트 결과)
* /loadtest/step2/smoke.png
* /loadtest/step2/load.png
* /loadtest/step2/stress.png
* /loadtest/step2/stress_2x.png

---

### 1단계 - 쿼리 최적화

#### 1. 인덱스 설정을 추가하지 않고 아래 요구사항에 대해 1s 이하(M1의 경우 2s)로 반환하도록 쿼리를 작성하세요.

- 활동중인(Active) 부서의 현재 부서관리자 중 연봉 상위 5위안에 드는 사람들이 최근에 각 지역별로 언제 퇴실했는지 조회해보세요. (사원번호, 이름, 연봉, 직급명, 지역, 입출입구분, 입출입시간)
```sql
select
    r.employee_id as '사원번호',
    s.last_name as '이름',
    s.annual_income as '연봉',
    s.position_name as '직급명',
    r.region as '지역',
    r.time as '입출입시간',
    r.record_symbol as '입출입구분'
from record r
        inner join (
            select s.annual_income, d.id, d.last_name, d.position_name
            from salary s
            inner join (
                select e.id, e.last_name, p.position_name
                from department d
                inner join manager m on d.id = m.department_id and d.note = 'active'
                inner join employee e on e.id = m.employee_id and m.end_date >= now()
                inner join position p on e.id = p.id and p.position_name = 'manager') d
            on s.id = d.id and s.end_date >= now()
            order by s.annual_income desc limit 5) s
         on r.employee_id = s.id and r.record_symbol = 'O';
```
* 결과 이미지: /sql/tuning_result.png

---

### 2단계 - 인덱스 설계

#### 1. 인덱스 적용해보기 실습을 진행해본 과정을 공유해주세요
```sql
-- Coding as a Hobby 쿼리 0.667 sec -> 0.081 sec
select hobby, count(*) / (select count(*) from programmer p) * 100
from programmer
group by hobby;
-- 인덱스 생성
create index idx_programmer_hobby ON programmer (hobby);

-- 프로그래머별로 해당하는 병원 이름 쿼리 0.770 sec -> 0.026 sec
select c.programmer_id, h.name
from covid c
inner join programmer p on c.programmer_id = p.id
inner join hospital h on c.hospital_id = h.id;
-- 인덱스 생성
create index idx_programmer_id ON programmer (id);
alter table hospital add primary key (id);
create index idx_covid_programmer_id ON covid (programmer_id);
create index idx_covid_hospital_id ON covid (hospital_id);

-- 프로그래밍이 취미인 학생 혹은 주니어(0-2년)들이 다닌 병원 이름 쿼리 -> 0.030 sec
select c.programmer_id, h.name, p.hobby, p.dev_type, p.years_coding
from covid c
inner join (
	select id, hobby, dev_type, years_coding
	from programmer 
	where hobby = 'Yes' 
    and (student != 'No' or years_coding = '0-2 years')) p
on c.programmer_id = p.id
inner join hospital h on c.hospital_id = h.id;

-- 서울대병원에 다닌 20대 India 환자들을 병원에 머문 기간별로 집계 쿼리 1.661 sec -> 0.103 sec
select c.stay, count(*)
from covid c
inner join programmer p on c.programmer_id = p.id
inner join member m on c.member_id = m.id
inner join hospital h on c.hospital_id = h.id
where p.country = 'India'
and m.age between 20 and 29
and h.name = '서울대병원'
group by c.stay;
-- 인덱스 생성
alter table member add primary key (id);
create index idx_member_id_covid on covid (member_id);

-- 서울대병원에 다닌 30대 환자들을 운동 횟수별로 집계 쿼리 0.092 sec
select p.exercise, count(*)
from covid c
inner join programmer p on c.programmer_id = p.id
inner join member m on c.member_id = m.id
inner join hospital h on c.hospital_id = h.id
where m.age between 30 and 39
and h.name = '서울대병원'
group by p.exercise
```
* 결과 이미지: /sql/step4
---

### 추가 미션

1. 페이징 쿼리를 적용한 API endpoint를 알려주세요
