---
layout: post
title: "Spring에서 @Async + 트랜잭션 분리 실패 및 해결 전략"
date: 2025-07-05 00:00:00 +0900
category: Spring
tags: []
---

### 문제 상황

아래와 같은 구조로 테스트 실행 흐름을 만들었는데, 트랜잭션이 의도대로 분리되지 않아  
**`IN_PROGRESS` 상태는 반영되지만, `COMPLETED` 상태는 반영되지 않는 현상**이 발생했다.

```java
@Async
@Transactional
@Override
public void executeTest(Long projectId) {
    projectStatusService.updateStatus(projectId, ProjectStatus.IN_PROGRESS);

    // 테스트 수집 및 저장 로직
    ...

    projectStatusService.updateStatus(projectId, ProjectStatus.COMPLETED);
}
```

### 기대했던 흐름

-   `updateStatus(IN_PROGRESS)`는 즉시 커밋 → 사용자는 상태가 바뀐 걸 확인
-   그 뒤 `executeTest()`는 비동기로 테스트를 실행
-   마지막에 `COMPLETED` 상태로 변경

### 실제 동작

-   `IN_PROGRESS`는 반영되지만
-   `COMPLETED`는 커밋되지 않음
-   심지어 내부에서 예외가 발생할 경우 **전체 트랜잭션이 롤백되며**
    `IN_PROGRESS` 변경까지 날아갈 위험이 있음

### 원인 분석

-   `@Async`와 `@Transactional`은 **모두 프록시 기반**
    → **자기 자신(this)** 내부 호출은 프록시를 거치지 않음 → AOP 미적용
-   `@Transactional(REQUIRES_NEW)`는 새로운 트랜잭션을 연다지만,
    **프록시 외부에서 호출될 때만 실제로 분리됨**
-   결국 `@Async`나 `REQUIRES_NEW` 모두 **다른 빈에서 호출돼야 제대로 작동**

### 설계를 다시 고민해보게 된 이유

초기에는 "문제 되는 구간만 `@Transactional(REQUIRES_NEW)`를 붙이면 해결되겠지"라고 생각했지만,
이 방식은 다음과 같은 **위험 요소**를 가지고 있었다:

-   내부 호출로 인해 트랜잭션이 분리되지 않음
-   예외 상황에서 **상태만 커밋되고 테스트 결과는 롤백**되거나 그 반대가 되는 등,
    일관성 유지가 어려움
-   트랜잭션이 어디서 시작되고 어디서 끝나는지 **파악하기 어려워짐**

### 해결 전략: 트랜잭션 경계는 **범위로 조절하자**

최종적으로 트랜잭션의 범위를 **메서드 단위가 아닌 클래스 단위로 분리**했다.
**트랜잭션이 반드시 분리되어야 하는 책임을 다른 빈으로 위임**한 구조는 다음과 같다:

```java
@Service
public class AsyncTestFacade {
    private final ProjectStatusService projectStatusService;
    private final TestExecutor asyncExecutor;

    public void startTest(Long projectId) {
        // @Transactional(REQUIRES_NEW)
        projectStatusService.markAsInProgress(projectId);
        // @Async
        asyncExecutor.execute(projectId);
    }
}
```

-   `markAsInProgress()`는 즉시 커밋되며 별도 트랜잭션으로 안전하게 반영됨
-   이후 `@Async`는 새로운 스레드에서 실행되므로, 본래 흐름에 영향 없음
-   트랜잭션 범위가 명확하게 나뉘어, 예외나 중단 상황에도 **일관성을 유지**할 수 있음

### 핵심 인사이트

-   트랜잭션을 중간에 `flush()`하거나 `REQUIRES_NEW`로 분리하는 건 **단기 처방**에 불과하다
-   **비즈니스 로직의 책임을 기준으로 트랜잭션의 경계를 나눠야 한다**
-   특히 비동기, 상태 저장, 외부 호출이 혼재하는 흐름에서는
    트랜잭션이 언제 시작되고 끝나는지를 분명히 알아야 유지보수가 가능하다

### 결론

-   복잡한 비동기 흐름에선, 트랜잭션을 만들기보다 **애초에 적절한 단위로 분리하는 것이 정답**
