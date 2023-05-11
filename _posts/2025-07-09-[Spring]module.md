---
layout: post
title: "인터페이스를 이용한 공통 로직 유틸화"
date: 2025-07-09 00:00:00 +0900
category: Spring
tags: []
---

### 문제 상황

병리학 이미지 기반 프로젝트를 개발하며, 두 개의 도메인(`Layout`, `Image`)에서 공통적으로 **리스트의 순서를 바꾸는 로직**이 존재했다.
각 객체 리스트를 주어진 인덱스에 재배치하고, `order` 값을 재계산하는 코드가 반복되면서 다음과 같은 문제가 있었음.

-   중복 로직이 각 서비스 클래스에 존재 (코드 유지보수 불편)
-   순서 재정렬(balancing) 및 삽입 시 `order` 계산 방식이 동일함에도 중복 구현됨
-   각 엔티티의 `order` 필드명이 달라 유틸화에 제약이 있었음

---

### 문제 해결 방법

유사한 정렬 로직을 **공통 유틸 클래스**로 분리하기 위해, 아래와 같은 방식으로 해결했다.

#### 1. 공통 인터페이스 `Orderable` 정의

```java
public interface Orderable {
    Integer getOrder();
    void updateOrder(Integer order);
}
```

`getOrder()`와 `updateOrder()`만 구현하면 정렬 가능하도록 설계.

#### 2. 각 엔티티가 `Orderable`을 구현

```java
@Entity
public class Image implements Orderable {
    private Integer imageOrder;

    @Override
    public Integer getOrder() {
        return imageOrder;
    }

    @Override
    public void updateOrder(Integer order) {
        this.imageOrder = order;
    }
}
```

`Layout`도 마찬가지 방식으로 `layoutOrder` 필드를 기준으로 구현.

#### 3. 유틸 클래스 생성

```java
public class OrderUtils {
    private static final int BASE_ORDER = 1024;

    public static <T extends Orderable> void arrangeList(List<T> list, T target, Integer targetIndex) {
        //...
    }

    public static <T extends Orderable> int calculateOrderForReOrder(List<T> list, Integer targetIndex) {
        // ...
    }

    public static <T extends Orderable> void balance(List<T> list) {
        // ...
    }
}
```

---

### 인터페이스 다형성

-   전략 교체가 쉬움

-   테스트 환경에서 Mock 대체가 쉬움

-   도메인 간 결합도 감소

실무에서 자주 쓰는 패턴별 사례

**(1) 전략 패턴 (Strategy Pattern)**

주요 목적: 알고리즘을 유연하게 교체<br>
예시: 결제

```java

public interface PaymentStrategy {
    void pay(int amount);
}
```

```java
@Component
public class KakaoPay implements PaymentStrategy { ... }

@Component
public class TossPay implements PaymentStrategy { ... }
```

```java
@Service
public class PaymentService {
    public PaymentService(List<PaymentStrategy> strategies) {
        strategyMap = strategies.stream().collect(...);
    }
    public void pay(String type, int amount) {
        strategyMap.get(type).pay(amount);
    }
}
```

적용 이점: if-else 제거, 전략 추가 시 코드 수정 없음, 테스트 시 전략 주입 가능

**(2) Bean Map 등록 패턴** <br>
주요 목적: 구현체들을 key-value 형태로 주입받아 동적으로 선택
예시: Reward 계산 정책, 할인 정책 등

```java
public interface RewardPolicy {
    int applyReward(int amount);
}
```

```java
@Service
public class RewardService {
    private final Map<String, RewardPolicy> policyMap;
    ...
}
```

적용 이점: 외부 설정으로 전략 선택 가능, 신규 정책 추가 용이

**(3) 파일 업로드 전략 추상화**

주요 목적: 인프라 추상화 (Local / S3 / FTP 등)
예시: 운영환경에서는 S3, 테스트에서는 로컬

```java
public interface FileUploader {
    String upload(MultipartFile file);
}
```

```java
@Service
public class FileService {
    public FileService(@Qualifier("s3Uploader") FileUploader uploader) {
        ...
    }
}
```

적용 이점: 테스트 환경 분리 가능, 인프라 변경 시 구현체만 교체

**(4) 유효성 검사기 분리**

예시: 회원가입 시 다양한 유효성 검사

```java
// 인터페이스
public interface Validator<T> {
    boolean supports(Class<?> clazz);
    void validate(T target, Errors errors);
}

// 이메일 유효성 검사기
@Component
public class EmailValidator implements Validator<User> {
    public boolean supports(Class<?> clazz) {
        return User.class.equals(clazz);
    }
    public void validate(User target, Errors errors) {
        if (!target.getEmail().contains("@")) {
            errors.rejectValue("email", "Invalid email");
        }
    }
}

// 서비스에서 사용
@Service
public class UserService {
    private final List<Validator<User>> validators;

    public UserService(List<Validator<User>> validators) {
        this.validators = validators;
    }

    public void register(User user) {
        Errors errors = new BeanPropertyBindingResult(user, "user");
        for (Validator<User> validator : validators) {
            if (validator.supports(user.getClass())) {
                validator.validate(user, errors);
            }
        }
        if (errors.hasErrors()) throw new IllegalArgumentException(errors.toString());
        // 저장 로직
    }
}

```

**(5) DTO 매퍼 분리**

주요 목적: Entity → DTO 매핑을 모듈화
예시: API Response 가공 시

```java
public interface DtoMapper<S, T> {
    T map(S source);
}

@Component
public class UserDtoMapper implements DtoMapper<User, UserResponse> {
    public UserResponse map(User user) {
        return new UserResponse(user.getId(), user.getName());
    }
}

// 컨트롤러
@RestController
public class UserController {
    private final DtoMapper<User, UserResponse> userDtoMapper;

    public UserController(DtoMapper<User, UserResponse> userDtoMapper) {
        this.userDtoMapper = userDtoMapper;
    }

    @GetMapping("/user/{id}")
    public UserResponse getUser(@PathVariable Long id) {
        User user = findUser(id); // 생략
        return userDtoMapper.map(user);
    }
}

```
