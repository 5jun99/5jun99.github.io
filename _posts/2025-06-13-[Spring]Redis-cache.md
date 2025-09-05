---
title: "Spring Cache + Redis 성능 개선 및 전략 검증"
date: 2025-06-13
categories: [Spring]
tags: []
---

## 문제 상황

이미지별 어노테이션 데이터를 조회하는 API를 만들었는데, 데이터 양이 커질수록 DB 쿼리 실행 시간이 늘어났다.

- 작은 데이터: 수십 ms
- 중간 데이터: 수백 ms
- 큰 데이터: 수백 개 쿼리 실행 → 응답 300ms 이상 튐

즉, **조회 성능과 안정성 부족**이 문제였다.

---

## 해결 방안

### 1. Redis 캐시 도입

Spring Cache + Redis를 적용했다.

```java
@Cacheable(value = "annotations:v1", key = "#imageId")
public AnnotationListResponse loadAnnotationsBy(Integer imageId) {
    List<Annotation> annotations = getAnnotations(imageId);
    return AnnotationListResponse.from(mapToResponses(annotations));
}

@Transactional
@CacheEvict(value = "annotations:v1", key = "#request.imageId")
public AnnotationResponse save(AnnotationCreateRequest request) {
    Annotation annotation = saveAnnotation(...);
    return AnnotationResponse.from(annotation);
}
```

- **조회**: 캐시에 있으면 반환, 없으면 DB 조회 후 캐시에 저장
- **쓰기(저장/수정/삭제)**: DB 작업 후 해당 캐시 무효화

### 2. 성능 테스트 (JMeter)

| 케이스    | 평균 응답(ms) | p95 응답(ms) |
| --------- | ------------- | ------------ |
| 캐시 없음 | 97            | 378          |
| 캐시 있음 | 29            | 128          |

- 캐시 적용 시 평균 응답 70% 단축
- 대규모 데이터(hard 케이스)는 235ms → 62ms로 안정화

### 3. 캐시 전략 검증 (JMeter + Redis INFO)

- **Hot key 집중** (특정 imageId 반복)

  - hit ratio 99.9% (처음만 DB, 이후 모두 캐시)

- **랜덤 분산 (1\~1,000)**

  - hit ratio 약 90% (요청 1만 건 중 miss ≈ 1,000)

- **대규모 분산 (1\~100,000)**

  - hit ratio 약 5% (거의 모든 요청이 miss)

---

## 관련 이론

### Cache-aside 패턴

- **조회 시**: 캐시 확인 → 없으면 DB 조회 후 캐시에 저장
- **쓰기 시**: DB 변경 → 캐시 무효화(evict)
- 장점: 단순하고 관리 용이
- 단점: 첫 요청은 무조건 DB 조회 → cold start 문제 존재

### 캐시 Hit/Miss

- **hit**: 요청한 key가 캐시에 있어 빠르게 반환
- **miss**: 캐시에 없어 DB 조회 필요
- 공식:

  ```text
  hit ratio = hits / (hits + misses)
  ```

### Hit율이 떨어지는 경우

1. **랜덤/롱테일 패턴**: key가 골고루 분산돼 대부분 한 번만 조회 → 캐시 효과 거의 없음
2. **TTL 짧음**: 자주 만료돼 miss 증가
3. **쓰기 잦음**: evict 반복 → stale data 방지 때문에 hit율 ↓
4. **메모리 부족**: eviction 발생 → cold key가 날아가서 miss ↑
5. **동시 만료(Cache Stampede)**: 인기 key TTL이 동시에 만료 → 대량 miss + DB 부하

### Cache Stampede (캐시 스탬피드)

- 인기 key TTL 만료 순간 다수 요청 몰림 → 동시에 DB 접근
- 해결책:

  - TTL에 random 지터 추가 (30분 ± 1\~5분)
  - 분산락(예: Redisson)으로 갱신 동시성 제어
  - 미리 캐시 refresh (background refresh)

### Eviction 정책

- Redis `maxmemory-policy`:

  - `allkeys-lru`: 전체 key 중 가장 오래 안 쓴 것 삭제
  - `allkeys-lfu`: 사용 빈도 낮은 것 삭제
  - `volatile-ttl`: TTL 짧은 key 위주로 삭제

- 실무에서는 hot 데이터가 오래 남을 수 있도록 LFU/LRU 조합 사용

---

## 정리

이번 실험을 통해 단순히 캐시만 붙이는 게 아니라,

1. **조회 성능 개선**: 평균 응답시간 70% 단축, p95 지연시간 안정화
2. **패턴별 효율 차이**: hot key는 hit율 99%, 분산 요청은 hit율 5%
3. **운영 전략 필요성**: TTL, eviction, stampede 대응 없이는 실서비스 안정성 보장 어려움

→ **“무엇을 캐시할지, 얼마나 유지할지” 전략 설계가 캐시 활용의 핵심**이라는 걸 배웠다.
