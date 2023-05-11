---
layout: post
title: "[Spring] request와 response dto에 getter가 있어야한다?"
date: 2024-07-16 00:00:00 +0900
category: Spring
tags: []
original_url: https://velog.io/@9409velog/spring-request%EC%99%80-response-dto%EC%97%90-getter%EA%B0%80-%EC%9E%88%EC%96%B4%EC%95%BC%ED%95%9C%EB%8B%A4
---

때는 jwt토큰 로그인 예제를 하던 중,, 자꾸 406에러가 뜨는 것!  
![](/assets/9409velog/spring-request와-response-dto에-getter가-있어야한다_image.png)  
대체 뭐가 문제인 건지 계속 찾아봤다. security를 쓰고 있어서 접근 이슈가 뜬건가 했었는데, 생각보다 단순한 문제였다.

responseentity에 wrapping된 dto에 get메서드가 없어서인 것!  
다르게 말하면 @Getter 어노테이션을 빠뜨려서라고도 설명할 수 있다.

이제껏 저 어노테이션이 코드에서 그냥 dto에 있는 필드에 접근할 때 필요한 건 줄 알았는데 json 형식의 데이터 폼으로 직렬화하고 역직렬화 할 때도 쓰이고 있던 것.

다르게 말하면 서버에서 받은 데이터를 봐야하는데 get이 없으니까 접근을 못해서 저런 오류가 뜨는 것이었다.
