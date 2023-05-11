---
layout: post
title: "[Spring] 쿠키에도 보안 설정이 있다?"
date: 2024-07-26 00:00:00 +0900
category: Web
tags: []
original_url: https://velog.io/@9409velog/spring-%EC%BF%A0%ED%82%A4%EC%97%90%EB%8F%84-%EB%B3%B4%EC%95%88-%EC%84%A4%EC%A0%95%EC%9D%B4-%EC%9E%88%EB%8B%A4
---

때는 프로젝트 배포 단계,,  
로컬에선 잘 돌아가던 프로젝트가 어세스 토큰을 재발급받는 엔드포인트에서 문제가 발생하게 된 것이다.

어세스 토큰을 재발급 받으려면 클라이언트에서 보내주는 리퀘스트 안에 있는 쿠키 중에 refreshtoken을 찾아서 그 리프레시 토큰이 멀쩡하면 어세스 토큰을 재발급해주는 로직이다.

그런데 자꾸 쿠키에 있는 리프레시 토큰을 못찾고 null 이라고 뽑아오는 것이 문제였던 것.  
그래서 리프레시 토큰을 발급하는 부분의 과정에서 문제가 있을 것이라고 판단. 찾아봤다.

```
return ResponseCookie.from("refreshToken", token)
                .httpOnly(true)
                .secure(false) // https 사용시
                .path("/")
                .maxAge(maxAge)
                .sameSite("None")
                .build();
```

속성

-   httpOnly: 자바스크립트에서 접근 불가능 (XSS 공격 방지)
-   secure: HTTPS 연결에서만 쿠키 전송
-   path: 쿠키가 유효한 URL 경로 설정
-   maxAge: 쿠키의 유효 기간 설정 (초 단위)
-   sameSite: 쿠키가 전송될 수 있는 컨텍스트 설정 (Strict, Lax, None)

문제는 아마 secure 부분이었던 것 같은데, secure(true) 일 경우 https 경로의 리퀘스트에만 반응하는 쿠키를 만들겠다는 것. false 로 바꿔주니 잘 되었다.

samSite는 다른 도메인으로의 리퀘스트에 대한 설정인데, 코스오류를 막기위해 none으로 설정해주었다.
