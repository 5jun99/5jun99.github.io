---
layout: post
title: "[Spring] JWT 토큰 과정 feat. spring security"
date: 2024-07-03 00:00:00 +0900
category: Spring
tags: []
original_url: https://velog.io/@9409velog/JWT-%ED%86%A0%ED%81%B0-%EA%B3%BC%EC%A0%95-feat.-spring-security
---

로그인때문에 이번년도 초반 프로젝트를 다 말아먹었었던,, 기억땜에 힘들었지만,, 다시 마주하게 된 토큰 발급 로그인,, 해커톤을 위해서 공부해봤다.

# jwt 란

JSON Web Token의 약어로, json 객체를 주고 받을 때 안전하게 전송하기 위해 쓰이는 방식이다.

왜 공부해야하느냐?

**기본적인 아이디 비번 입력 시 로그인,회원가입되는 구조는 너무 허술하기 때문!**

에시 상황을 생각하자면

-   페이지 접속을 할 때마다 로그인 해야하면 너무 귀찮다.
-   로그인한 유저에게만 보여줘야하는 페이지가 있을 때 권한 설정이 필요하다.

등등 인증과 인가에 관한 필요성은 크다.

해서! 로그인 시에 token을 발급해서 클라이언트 쪽에 가지고 있다가 페이지 재접시에 야 나나 들어온 적 있음! 하면서 token을 제시하면 서버 쪽에서 아 ㅇㅋ 너 인정. 들어와도 돼. 하는 구조를 만들어 줄 수 있는 것이다. jwt와 spring security를 이용해서 말이다.

# FilterChain?

_참고로 이 글에서는 코드는 다루지 않는다. 내가 다시 이걸 보고 개념을 떠올리기 위해서이기 때문 코드 보는 이 글 한 번 더 보는 게 나음_

security config를 코딩하다보면 항상 나오는 메소드 이름이 있다. filterchain이다.  
filterchain은 말 그대로 http 통신 간에 사용되는 filter들을 정의?설정? 하는 부분(엮여있어서 chain인 듯)이라고 생각하면 된다.

본디 springsecurity는 기본적인 filter를 제공해준다. UsernamePasswordAuthenticationFilter이라는 긴 이름을 가진 필터인데 사용자명이랑 비밀번호로 인한 인증을 처리해준다. 굳이 loginform을 만들어 놓지 않아도 /login으로 오는 mapping을 자동으로 만들어서 보여준다구!!

그런데 우리가 jwt 하는 이유가 매번 요청 발생할 때마다 로그인 안하려고 하는 거잖슴. 그래서 새로운 filter를 우리가 정의해서, UsernamePasswordAuthenticationFilter 전에 사전 처리를 해놓는 거다 이거임.

# token 발급?

그러면 토큰 발급은 어떻게 하는 건데? 첫 로그인 시에 token을 발급해주는 거임. 사용자가 로그인을 하면, 사용자의 아이디, 만료시간 등을 담아서 토큰을 만든다. (만들어주는 메서드나 객체는 io.jsonwebtoken.Jwts에 있음 의존성 추가하면 됨)

그렇게 만들어진 토큰을 로그인 post요청의 response로 주면, 클라이언트는 로컬 변수든 쿠키든 가지고 있다가 재접때마다 꺼내서 백에 api 날릴 때 마다 header 나 쿠키에 담아서 백한테 주면, 그걸 받아서, 위에서 설명한 jwttokenfilter 에서 확인하고 오케이 인증해줄게 하는 거임.

정확히는 UsernamePasswordAuthenticationFilter에 대한 인증토큰을 만들어줘서 filter 하이패스하게 해주는 거라고 생각하면 됨

# 정리

토큰은 로그인 시에 만들어진다.  
토큰은 프론트에서 저장하는 경우가 많다.  
필요할 때 백한테 내밀면 백이 보고 처리해준다.
