---
title: "비동기 subscribe 내부에서 도메인 객체로 update하면 생기는 동시성 문제"
date: 2025-07-29
categories: [Spring, Backend]
tags: []
---

## 1. 문제 상황

`TestExecutor` 클래스에서 `Project` 도메인을 subscribe 바깥에서 미리 조회하고, 이후 `.subscribe()` 내부에서 이 객체에 대해 `updateTestRate()` 또는 `updateScore()`를 호출하고 저장했다.

그런데 테스트 결과가 정상 저장되지 않거나, 상태가 누락되는 현상이 발생했다.

원인을 추적해보니, 비동기 subscribe 시점에서는 `project` 객체가 더 이상 최신 상태가 아니고, 다른 요청 흐름에서 이미 해당 프로젝트가 수정되었을 수도 있었다. 결과적으로 **낡은 상태로 덮어쓰기(stale write)** 가 발생한 것이다.

---

## 2. 문제 해결

비동기 subscribe 내부에서는 `project` 객체를 그대로 쓰지 않고, 해당 시점에서 다시 조회하는 방식으로 변경했다.

```java
projectPort.findById(projectId).ifPresent(freshProject -> {
    freshProject.updateTestRate(tests);
    projectPort.update(freshProject);
});
```

이렇게 하면 항상 **최신 상태의 도메인으로부터 변경을 수행**하므로, 동시성 충돌 위험이 줄어들고, 데이터 정합성도 확보된다.

---

## 3. 이론

이 문제는 넓은 의미에서의 **동시성 제어(Concurrency Control)** 문제다.

비동기 subscribe 흐름에서는 콜백이 실행되는 시점이 예측 불가능하고, 그 사이에 동일한 데이터를 다른 흐름에서 수정하고 저장할 수 있다. 이 경우, 나중에 실행된 흐름이 **더 오래된 상태의 객체로 DB를 덮어쓰는 문제**가 발생한다. 이를 `Stale State`, 또는 도메인/엔티티 분리 설계에서는 `Detached Domain Object`라고 부른다.

---

## 4. 도메인이 **엔티티**일 경우 적용 가능한 동시성 처리 기법

만약 `project`가 엔티티였다면, JPA에서는 다음과 같은 동시성 제어 전략을 적용할 수 있다.

### 1. Optimistic Locking (낙관적 락)

-   `@Version` 필드를 통해 **동시 수정 충돌을 감지**
-   트랜잭션 커밋 시점에 버전이 다르면 `OptimisticLockException` 발생
-   **장점**: 락을 잡지 않아 성능 좋음
-   **단점**: 충돌 시 롤백이 발생하므로 예외 처리 필요

```java
@Entity
public class ProjectEntity {
    @Version
    private Long version;
}
```

```java
project.setScore(newScore);
projectRepository.save(project); // 버전 충돌 시 예외 발생
```

### 2. Pessimistic Locking (비관적 락)

-   조회 시점부터 `select ... for update` 방식으로 락을 잡음
-   다른 트랜잭션이 접근하지 못하게 함

```java
@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("select p from ProjectEntity p where p.id = :id")
Optional<ProjectEntity> findByIdWithWriteLock(@Param("id") Long id);
```

-   **장점**: 충돌 없이 순차적으로 처리 가능
-   **단점**: 성능 낮고 데드락 위험 존재

---

## 5. 도메인-엔티티 분리 구조에서는?

현재 내 프로젝트는 도메인 모델과 JPA 엔티티를 분리한 구조라, 위의 락 기반 전략은 쓸 수 없다.
이 구조에서는 다음이 사실상 정석이다:

-   **subscribe 내부에서는 항상 도메인을 다시 조회하고 update**
-   또는 아예 상태를 `Command` 형식으로 분리해서 전달
    (예: `updateTestRate(projectId, newRate)`)
