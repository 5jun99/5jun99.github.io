---
title: "Spring Security 위에서 돌아가는 커스텀 JWT 인증 필터 구현기 (Feat. `AbstractAuthenticationProcessingFilter`)"
date: 2025-04-07 00:00:00 +0900
category: security
tags: []
---

# Spring Security 위에서 돌아가는 커스텀 JWT 인증 필터 구현기 (Feat. `AbstractAuthenticationProcessingFilter`)

## 👋 Intro

최근 프로젝트에서 JWT 인증을 커스텀 필터로 구현해야 하는 상황이 생겼다.  
기존의 `OncePerRequestFilter`가 아닌, Spring Security의 흐름을 제대로 타기 위해  
`AbstractAuthenticationProcessingFilter`를 상속해서 필터를 설계했고,  
이 과정에서 마주한 시행착오와 구조에 대해 정리해보려 한다.

---

## 🧩 왜 `AbstractAuthenticationProcessingFilter`?

Spring Security의 인증 구조에서 아래와 같은 흐름을 제대로 타기 위해:

1. `attemptAuthentication()` → `AuthenticationManager`로 위임
2. 인증 성공 시 `successfulAuthentication()`에서 `SecurityContext`에 사용자 등록
3. 인증 실패 시 필터 레벨에서 응답 조작 가능

이런 **“Spring Security와 자연스럽게 통합되는 인증 흐름”**을 만들기 위해 선택했다.

---

## ⚙️ 전체 구조 요약

```
- JwtAuthenticationToken       // 인증 전후 두 가지 상태 표현
- JwtAuthenticationProvider    // 실제 토큰 검증 로직 처리
- JwtFilter                    // 커스텀 필터. AbstractAuthenticationProcessingFilter 상속
- SecurityConfig               // FilterChain 설정 및 Provider 등록
```

---

## 🔐 JwtAuthenticationToken

```java
public class JwtAuthenticationToken extends AbstractAuthenticationToken {
    private final String token;
    private final User principal;

    public JwtAuthenticationToken(String token) {
        super(null);
        this.token = token;
        this.principal = null;
        setAuthenticated(false);
    }

    public JwtAuthenticationToken(User principal) {
        super(Collections.emptyList());
        this.token = null;
        this.principal = principal;
        setAuthenticated(true);
    }

    @Override public Object getCredentials() { return token; }
    @Override public Object getPrincipal() { return principal; }
}
```

---

## 🔧 JwtAuthenticationProvider

```java
@Component
@RequiredArgsConstructor
public class JwtAuthenticationProvider implements AuthenticationProvider {

    private final TokenManager tokenManager;
    private final UserDetailsService userDetailsService;

    @Override
    public Authentication authenticate(Authentication authentication) {
        String token = (String) authentication.getCredentials();
        tokenManager.validate(token);
        String userId = tokenManager.extractUserId(token);
        User user = (User) userDetailsService.loadUserByUsername(userId);
        return new JwtAuthenticationToken(user);
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return JwtAuthenticationToken.class.isAssignableFrom(authentication);
    }
}
```

---

## 🧼 JwtFilter - 필터 구현

```java
public class JwtFilter extends AbstractAuthenticationProcessingFilter {

    public JwtFilter(AuthenticationManager authenticationManager) {
        super(new AntPathRequestMatcher("/api/**")); // JWT 검사할 경로
        setAuthenticationManager(authenticationManager);
    }

    @Override
    protected boolean requiresAuthentication(HttpServletRequest request, HttpServletResponse response) {
        return !PermitAllUrls.isPermitAll(request.getRequestURI());
    }

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)
            throws AuthenticationException {
        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            throw new AuthenticationException(ErrorCode.INVALID_AUTH_HEADER);
        }
        String token = header.substring(7);
        return getAuthenticationManager().authenticate(new JwtAuthenticationToken(token));
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response,
                                            FilterChain chain, Authentication authResult)
            throws IOException, ServletException {
        SecurityContextHolder.getContext().setAuthentication(authResult);
        chain.doFilter(request, response);
    }
}
```

---

## 🧱 SecurityConfig에서 등록

```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http, JwtAuthenticationProvider jwtAuthenticationProvider) throws Exception {
    JwtFilter jwtFilter = new JwtFilter(new ProviderManager(jwtAuthenticationProvider));

    http
        .csrf().disable()
        .authorizeHttpRequests(auth -> auth
            .requestMatchers(PERMIT_ALL_URLS).permitAll()
            .anyRequest().authenticated()
        )
        .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

    return http.build();
}
```

---

## 😵 시행착오 및 팁

### 1. `@Component`로 Provider 등록해도 `Filter`에 직접 넣어줘야 한다

```java
new JwtFilter(new ProviderManager(jwtAuthenticationProvider));
```

단순 DI만으로는 `setAuthenticationManager()` 호출이 안 되기 때문에 명시적으로 ProviderManager를 만들어 넣었다.

---

### 2. `AbstractAuthenticationProcessingFilter`는 인증 실패 시 자동으로 `/error`로 리다이렉트

-   이걸 막고 직접 응답을 주고 싶다면 `handleException()`을 커스터마이징해야 한다.
-   나는 직접 `response.getWriter().write(json)` 방식으로 처리했다.

---

### 3. `AuthenticationProvider`가 `JwtAuthenticationToken`을 인식 못 하면?

-   `supports()`를 반드시 구현할 것

```java
@Override
public boolean supports(Class<?> authentication) {
    return JwtAuthenticationToken.class.isAssignableFrom(authentication);
}
```

---

## ✅ 마무리

Spring Security 위에서 유연하게 동작하는 JWT 인증 흐름을 만들고 싶다면  
`AbstractAuthenticationProcessingFilter`를 커스터마이징하는 방식은 꽤 강력하다.  
기본적인 스프링 시큐리티의 컨벤션을 따르면서도,  
나만의 인증 로직을 유연하게 녹일 수 있어서 유지보수성과 확장성 모두 챙길 수 있다.

---

원하면 마크다운으로 정리해서 `.md` 파일로도 줄게. 블로그 포스팅용 이미지, 코드 하이라이트, 링크 등도 더 넣어줄 수 있어 😎  
필요한 형식 있으면 말해줘!
