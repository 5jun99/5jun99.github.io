---
layout: post
title: "Spring Security 위에서 돌아가는 커스텀 JWT 인증 필터 구현기"
date: 2025-04-07 00:00:00 +0900
category: Spring
tags: []
---

# Spring Security 위에서 돌아가는 커스텀 JWT 인증 필터 구현기

## ✨ 왜 이걸 했는가

프로젝트에서 JWT 인증을 구현하려 했을 때, 단순히 `OncePerRequestFilter`를 사용하는 방식은 나에겐 불충분했다.

-   Spring Security의 인증 흐름을 제대로 타고 싶었고
-   인증 실패 시 에러 응답을 직접 제어하고 싶었으며
-   인증 성공 시 SecurityContext에 자연스럽게 주입되기를 바랐다

그래서 나는 **`AbstractAuthenticationProcessingFilter`** 를 상속받아 필터를 만들기로 결정했다. 처음부터 쉽지는 않았지만, 지금 돌아보면 가장 확장성 있고 안정적인 선택이었다.

---

## 🌎 전체 구성

| 파트                      | 역할                                |
| ------------------------- | ----------------------------------- |
| JwtAuthenticationToken    | 인증 전/후 상태를 나누는 Token 객체 |
| JwtAuthenticationProvider | 토큰 검증 및 인증 주체 반환         |
| JwtFilter                 | 실제 필터. 토큰 파싱, Provider 연결 |
| SecurityConfig            | 필터 체인 구성 및 Provider 주입     |

---

## ⚡ 각 파트 설명과 기능

### 1. `JwtAuthenticationToken`

```java
public class JwtAuthenticationToken extends AbstractAuthenticationToken {
    private final String token;
    private final User principal;
    ...
}
```

**이유**: 인증 전에는 `token`만 존재하고, 인증 후에는 `User`가 존재하는 두 상태가 필요했다.

**기능**:

-   인증 전/후 구분을 위한 생성자 2개 사용
-   인증 정보가 SecurityContext에 저장될 때 사용됨

---

### 2. `JwtAuthenticationProvider`

```java
public class JwtAuthenticationProvider implements AuthenticationProvider {
    public Authentication authenticate(Authentication authentication) { ... }
}
```

**이유**: 토큰을 해석하고 인증 객체를 만들어 줄 실제 로직이 필요했다.

**기능**:

-   토큰 유효성 검증 (validate)
-   토큰에서 userId 추출
-   DB 또는 캐시에서 유저 조회
-   인증된 토큰 객체 반환

---

### 3. `JwtFilter`

```java
public class JwtFilter extends AbstractAuthenticationProcessingFilter { ... }
```

**이유**: Spring Security의 필터 체인을 따라 동작하면서, 토큰을 읽고 검증해주는 필터가 필요했다.

**기능**:

-   `Authorization` 헤더에서 토큰 파싱
-   검증 후 Provider로 인증 위임
-   성공 시 SecurityContextHolder에 주입
-   실패 시 직접 JSON 응답 반환

**주요 포인트**:

-   `setAuthenticationManager()`에 `ProviderManager`를 수동 주입해야 함

---

### 4. `SecurityConfig`

```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http, JwtAuthenticationProvider provider) throws Exception {
    JwtFilter filter = new JwtFilter(new ProviderManager(provider));
    http.addFilterBefore(filter, UsernamePasswordAuthenticationFilter.class);
    ...
    return http.build();
}
```

**이유**: 커스텀 필터를 시큐리티 필터 체인에 정확히 위치시켜야 했다.

**기능**:

-   인증 제외 경로(PERMIT_ALL_URLS) 처리
-   `ProviderManager`를 통해 인증 매니저 구성
-   커스텀 필터 등록

---

## 🤔 시행착오 & 느낀 점

### 시행착오들

-   `JwtAuthenticationProvider`를 필터에서 주입받지 못해 NPE 발생
-   `setAuthenticationManager()`가 필터 생성자에 없으면 인증이 안 됨
-   `supports()`를 구현하지 않으면 Provider가 동작 안 함
-   필터 실패 시 Spring이 `/error`로 이동해서 원하는 응답 못 주는 문제 (직접 핸들링 추가)

### 느낀 점

-   Spring Security는 커스터마이징이 어렵지만, 원리를 이해하면 굉장히 강력하다
-   SecurityContext와 Provider의 개념을 정확히 잡아야 흐름이 명확해진다
-   직접 컨트롤 가능한 구조를 만들면 이후 유지보수와 확장에 유리하다

---

## 🚀 결론

이 글은 JWT 인증을 Spring Security 구조 안에서 깔끔하게 구현하고 싶은 사람들에게 도움이 될 것이다.

나처럼 필터를 커스터마이징하고 싶다면, `AbstractAuthenticationProcessingFilter`를 사용하는 방법도 고려해보길 바란다.

> 인증은 보안의 시작이고, 좋은 구조는 협업과 유지보수의 시작이다.

---
