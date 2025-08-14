---
title: "MySQL에서 ENUM 스키마 변경 중 교착 상황 정리"
date: 2025-08-14
categories: [SQL]
tags: []
---

## 1. 문제 상황

-   `layouts` 테이블에 `layout_type` 컬럼이 ENUM(`MERGE`, `SEGMENT`)으로 정의되어 있었음
-   새 요구사항: `MERGE → HORIZONTAL`, `SEGMENT → VERTICAL` 로 변경 필요

---

## 2. 시도 과정

### (1) 데이터 먼저 변경

```sql
UPDATE layouts SET layout_type = 'HORIZONTAL' WHERE layout_type = 'MERGE';
UPDATE layouts SET layout_type = 'VERTICAL'   WHERE layout_type = 'SEGMENT';
```

❌ 실패 → **도메인 무결성 오류**
왜냐하면 `layout_type` ENUM 정의에 `'HORIZONTAL'`, `'VERTICAL'` 값이 없었기 때문

---

### (2) 스키마 먼저 변경

```sql
ALTER TABLE layouts
MODIFY layout_type ENUM('HORIZONTAL', 'VERTICAL') NOT NULL;
```

❌ 실패 → 기존 데이터(`MERGE`, `SEGMENT`)가 ENUM 정의에 없어서 **스키마 변경 불가**

---

### (3) UPDATE 시도 (Safe Update Mode 켜진 상태)

```sql
UPDATE layouts SET layout_type = 'VERTICAL' WHERE layout_type = 'MERGE';
```

❌ 실패 → **Error Code: 1175 (Safe Update Mode)**
MySQL Workbench에서 기본으로 켜져 있어, PK나 KEY 없는 WHERE 조건일 때 UPDATE 막음

---

## 3. 교착 상태 정리

-   **데이터 → 스키마 변경** : 안 됨 (ENUM 제약 위배)
-   **스키마 → 데이터 변경** : 안 됨 (기존 값 ENUM에 없음)
-   **업데이트 자체도** Safe Update Mode 때문에 막힘

즉, 데이터와 스키마가 **서로 발목을 잡는 교착 상태** 발생

---

## 4. 해결 방법

1. **Safe Update Mode 해제**

    ```sql
    SET SQL_SAFE_UPDATES = 0;
    ```

    또는 Workbench Preferences → SQL Editor → Safe Updates 체크 해제 후 재접속

2. **ENUM 확장 → 데이터 업데이트 → ENUM 축소**

    ```sql
    -- (1) 새로운 값 추가
    ALTER TABLE layouts
    MODIFY layout_type ENUM('MERGE', 'SEGMENT', 'HORIZONTAL', 'VERTICAL') NOT NULL;

    -- (2) 기존 데이터 매핑
    UPDATE layouts SET layout_type = 'HORIZONTAL' WHERE layout_type = 'MERGE';
    UPDATE layouts SET layout_type = 'VERTICAL'   WHERE layout_type = 'SEGMENT';

    -- (3) 불필요한 값 제거
    ALTER TABLE layouts
    MODIFY layout_type ENUM('HORIZONTAL', 'VERTICAL') NOT NULL;
    ```

---

## 5. 배운 점

-   ENUM 컬럼 값 변경 시 **데이터와 스키마를 순차적으로 정리**해야 함
-   순서는 항상

    1. 새 값 추가 →
    2. 기존 데이터 업데이트 →
    3. 기존 값 제거

-   Workbench Safe Update Mode는 실수 방지용이지만, PK 없는 WHERE 조건을 쓸 때 걸림돌이 될 수 있음

---
