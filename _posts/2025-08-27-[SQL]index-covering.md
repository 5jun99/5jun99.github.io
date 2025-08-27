---
title: "[인덱싱 2편] 커버링 인덱스 실험"
date: 2025-08-27
categories: [SQL]
tags: []
---

## 1. 문제 상황

지난 글에서 `patient_number` 조회가 인덱스를 타는 것을 확인했다. 하지만 여기서 또 하나 의문이 생겼다.

> “조회할 때 사실상 `patient_number` 값만 필요한데, 왜 MySQL은 항상 테이블까지 접근해서 나머지 컬럼까지 가져올까?”

예를 들어 QueryDSL 기본 코드로 데이터를 가져오면 이렇게 전체 엔티티를 읽는다.

```java
// 전체 엔티티 조회
public List<Patient> findByPatientNumberPrefix(String prefix) {
    return queryFactory
        .selectFrom(patient)
        .where(patient.patientNumber.stringValue().startsWith(prefix))
        .fetch();
}
```

SQL을 찍어보면 이런 식이다.

```sql
SELECT p1_0.id, p1_0.patient_number, p1_0.created_date_time, p1_0.modified_date_time
FROM patients p1_0
WHERE CAST(p1_0.patient_number AS CHAR) LIKE '123%';
```

즉, **인덱스로 후보를 잡은 뒤에도 결국 테이블 row에 접근해야 한다.**

---

## 2. 해결 방식 – 커버링 인덱스 적용

여기서 나온 방법이 커버링 인덱스(Covering Index)다.

쿼리에서 필요한 컬럼이 전부 인덱스에 포함되어 있다면, MySQL은 테이블까지 접근할 필요가 없다. 인덱스만 보고 결과를 바로 반환한다.

이를 위해 SELECT 절을 바꿔보았다.

```java
// patient_number만 조회
public List<Integer> findByPatientNumberPrefixCoveringIndex(String prefix) {
    return queryFactory
        .select(patient.patientNumber)
        .from(patient)
        .where(patient.patientNumber.stringValue().startsWith(prefix))
        .fetch();
}
```

select 절을 좀 줄어든다.

```sql
SELECT p1_0.patient_number
FROM patients p1_0
WHERE CAST(p1_0.patient_number AS CHAR) LIKE '123%';
```

이 경우 인덱스 컬럼만으로 결과를 충족할 수 있으므로 Extra에 `Using index`가 붙게 된다.

---

## 3. 실험 환경

성능 차이를 실제로 보기 위해 JMeter를 사용해 대량 데이터를 조회해 보았다.

- DB: MySQL
- 애플리케이션: Spring Boot + QueryDSL
- 부하 테스트 도구: JMeter
- 데이터 크기:

  - 초기 6,000건 → 성능 차이 미미
  - 최종 100,000건 → 유의미한 차이 발생

대량 데이터를 생성하기 위해 CTE(재귀 쿼리)를 활용했다.

```sql
SET SESSION cte_max_recursion_depth = 100000;

WITH RECURSIVE number_generator AS (
    SELECT 1 AS num
    UNION ALL
    SELECT num + 1 FROM number_generator WHERE num < 100000
)
INSERT INTO patients (patient_number, created_date_time, modified_date_time)
SELECT
    CASE
        WHEN num <= 10000 THEN 100000 + num
        WHEN num <= 20000 THEN 200000 + num
        ...
    END,
    NOW() - INTERVAL FLOOR(RAND() * 365) DAY,
    NOW()
FROM number_generator;
```

이렇게 해서 prefix별로 1만 건씩 분포된 총 10만 건 데이터를 확보했다.

## 4. 실험 결과

JMeter로 조회 성능을 비교한 결과는 아래와 같다.

| 시나리오              | 평균 응답시간 | 성능 향상률 |
| --------------------- | ------------- | ----------- |
| 전체 조회 (기본)      | 615ms         | -           |
| 전체 조회 (커버링)    | 70ms          | 88% 향상    |
| "123" prefix (기본)   | 41ms          | -           |
| "123" prefix (커버링) | 18ms          | 56% 향상    |

- 소규모 데이터(6천 건)에서는 성능 차이가 거의 없었다. → 테이블 전체가 메모리에 캐시되기 때문.
- 대규모 데이터(10만 건)에서는 커버링 인덱스 적용 시 극적인 성능 향상을 확인할 수 있었다.

---

## 5. EXPLAIN 비교

실행 계획을 다시 보면 확연한 차이가 드러난다.

### 일반 조회

```sql
EXPLAIN
SELECT id, patient_number, created_date_time, modified_date_time
FROM patients
WHERE patient_number LIKE '123%';
```

결과:

- Extra: `Using where`
- 의미: 인덱스로 후보를 좁히지만 결국 row 접근이 필요하다.

### 커버링 인덱스 조회

```sql
EXPLAIN
SELECT patient_number
FROM patients
WHERE patient_number LIKE '123%';
```

결과:

- Extra: `Using index`
- 의미: 인덱스만으로 조건과 결과를 모두 만족. 테이블 접근 없음.

---

## 6. 알게된 점

1. **데이터 규모가 커질수록 커버링 인덱스의 효과가 분명해진다.**

   - 소규모 테이블: 캐시 효과 때문에 차이가 거의 없다.
   - 대규모 테이블: 80% 이상 성능 향상 가능.

2. **불필요한 컬럼 조회가 쿼리 성능을 크게 갉아먹는다.**

   - SELECT \*는 습관적으로 쓰면 안 된다.
   - 필요한 컬럼만 명확히 지정해야 인덱스를 최대한 활용할 수 있다.

3. - `Using index`가 붙으면 커버링 인덱스 성공.
   - `Using where`만 보이면 테이블 접근이 여전히 발생 중.
