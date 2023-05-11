---
layout: post
title: "비동기 이벤트 기반 테스트 구조 리팩토링 - 트랜잭션과 상태 동기화 문제 해결기"
date: 2025-07-26
categories: Spring
tags: []
---

# 비동기 이벤트 기반 테스트 구조 리팩토링

## 1. 문제 상황

### 배경

AUTA 프로젝트에서는 FastAPI 기반의 두 가지 외부 테스트를 실행하고 있다:

-   **기능 테스트 (Routing / Interaction / Mapping)**
-   **UI/UX 테스트 (Figma → GPT 평가 → 시각화)**

이 두 테스트는 **각각 비동기적으로 수행**되며, 결과가 도착하는 시점도 다르다. 그런데 `ProjectStatus`를 갱신하는 방식이 단일 트랜잭션 내 `project.update()` 호출에 의존하고 있어 다음과 같은 문제가 발생했다.

### 문제

-   **상태 역행 문제**  
    `executeAsyncTest()`가 먼저 끝나 `COMPLETED`로 상태 변경 → 이후 `executeUITest()`의 `project.update()`가 도착하면서 **다시 `IN_PROGRESS`로 덮어써짐**

-   **비동기 처리 간 상태 동기화 실패**  
    각 테스트가 완료될 때마다 상태를 바꾸면, 최종 완료 시점을 보장하기 어려움

-   **트랜잭션 경계 모호**  
    내부에서 `@Transactional`로 묶은 영역과 외부 이벤트/비동기 흐름이 충돌함

---

## 2. 해결 방법

### 핵심 전략

-   **비동기 이벤트 기반 처리로 구조 변경**
-   **중간 상태 추적용 테이블(`ProjectTestProgress`) 도입**
-   **`REQUIRES_NEW` 트랜잭션으로 상태 충돌 방지**

### 2-1. 테스트 실행을 이벤트로 분리

```java
@Component
@RequiredArgsConstructor
public class ProjectTestEventListener {
    private final ProjectTestService projectTestService;

    @Async
    @EventListener
    public void handle(ProjectTestEvent event) {
        projectTestService.runTestInternal(event.getProjectId());
    }
}
```

컨트롤러 → `ApplicationEventPublisher` → `@Async @EventListener`
→ 병렬 실행 가능, 트랜잭션 충돌 없음

---

### 2-2. 상태 추적 전용 테이블 도입

```java
@Entity
public class ProjectTestProgressEntity {
    @Id
    private Long projectId;
    private boolean testDone;
    private boolean uiDone;

    public void updateTest(boolean done) { this.testDone = done; }
    public void updateUITest(boolean done) { this.uiDone = done; }
    public boolean isTestDone() { return testDone; }
    public boolean isUiDone() { return uiDone; }
}
```

두 테스트가 끝날 때마다 각각 `true`로 갱신.
둘 다 `true`일 때만 `ProjectStatus.COMPLETED`로 전환.

---

### 2-3. 상태 갱신 로직은 분리된 트랜잭션으로

```java
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void applyUITestResult(Long projectId) {
    ProjectTestProgressEntity progress = getOrCreate(projectId);
    progress.updateUITest(true);

    if (progress.isTestDone()) {
        updateStatus(projectId, ProjectStatus.COMPLETED);
    }
}
```

→ 별도 트랜잭션으로 분리해서
다른 로직의 rollback 영향 없이 상태만 독립 갱신 가능

---

## 3. 이론 정리

### 3-1. @Async + @EventListener

-   **@Async**: 비동기 스레드에서 메서드 실행
-   **@EventListener**: 이벤트 수신 후 메서드 실행
-   조합 시 `ApplicationEventPublisher`를 통해 완전한 비동기 분리 가능

### 3-2. @Transactional(propagation = REQUIRES_NEW)

-   기존 트랜잭션과 무관하게 **새 트랜잭션 생성**
-   rollback이나 실패에 영향을 받지 않도록 트랜잭션을 분리할 때 사용
-   상태 갱신이나 기록성 로직에 적합

### 3-3. 전체 트랜잭션보다 **분리된 트랜잭션 관리**가 유리한 이유

-   처음엔 모든 로직을 하나의 `@Transactional` 안에서 처리하려 했으나,
    FastAPI 호출 이후 상태를 갱신하는 작업이 **비동기적으로 도착**하면서 문제가 발생했다.
-   이 때 가장 효과적인 해결책은,
    -   **비즈니스 핵심 흐름(삭제, 생성, 테스트 실행 등)**은 기본 트랜잭션으로 처리하고
    -   **상태 갱신, 결과 저장 등은 REQUIRES_NEW로 분리**
-   이렇게 하면 롤백이나 예외 상황에서도 필요한 최소한의 상태 정보는 보존되고, 추적 가능성이 확보된다.

### 3-4. 외부 비동기 호출 후 상태 충돌 방지 전략

-   외부 모듈 결과가 순차적이지 않다면, **단일 상태 관리가 위험**
-   테스트별 완료 여부를 추적하는 `Progress Table`을 두고
    **“모든 조건이 충족될 때만 상태를 바꾼다”** 전략이 안정적

---

## 4. 마무리

이번 리팩토링을 통해 다음과 같은 개선을 이뤘다:

-   상태 덮어쓰기 문제 해결
-   외부 시스템과의 비동기 통신 안정화
-   트랜잭션 분리로 에러 처리 유연성 확보
-   이후 테스트 항목이 추가되어도 확장 가능한 구조 확보
