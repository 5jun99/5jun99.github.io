---
layout: post
title: "GDSC 백 엔드 스터디 2주차"
date: 2024-07-11 00:00:00 +0900
category: Memoir
tags: []
original_url: https://velog.io/@9409velog/GDSC-%EB%B0%B1-%EC%97%94%EB%93%9C-%EC%8A%A4%ED%84%B0%EB%94%94-2%EC%A3%BC%EC%B0%A8
---

7/11 오늘 저번 주에 이어서 essential 프로젝트가 무산되면서 기본적인 기능 구현 스터디를 하게되었고, api 명세서를 작성한 것을 바탕으로 api 구현이 이번주 과제였다.

계층구조로 개발을 해갔고, 기존에 해왔던 거처럼 코딩을 해갔다.

내 코드에 대한 피드백은 이것이다

-   entity나 dto에 setter를 사용하게 됨으로써 다른이가 setter를 사용하게 되어, 의도치 않게 정보가 바뀔 수 있는 가능성이 있다. entity에는 setter를 쓰기보단 객체를 선언할 때에 생성자로 넣어주면 어떨까?
-   @Autowired 대신 final 넣어줬으면 lombok의 RequiredArgsConstructor를 써봐도 좋다.
    > @RequiredArgsConstructor란?  
    > Lombok 라이브러리에서 제공하는 어노테이션 중 하나로, 필드에 초기값이 지정되지 않은 final 또는 @NonNull이 지정된 모든 필드에 대해 생성자를 자동으로 생성해주는 역할을 합니다. 이를 사용하면 반복적인 생성자 코드를 작성하지 않아도 되어 코드의 가독성을 높이고 유지보수를 용이하게 합니다.
-   date관련해서 굳이 entity 만들 필요 있었나? db 를 쪼개는 것은 좋지만, 불필요한 db는 불안정성을 야기한다(보안) - db 안쓰고 서버 시작할 때 넣어주거나 이런 식이 맞나? - 효준님 코드 보고 참고해야할 듯

## 다음주 요구사항

-   객체 지향적인 (solid한) 코드로 리팩토링 해볼 것
-   db 쓰지 않고 저번주 요구사항에 맞춰서 다시 코딩해볼 것

### 찾아보기!

dto란?  
계층구조  
entity는 어떤 계층인가?  
record란?  
ResponseEntity?  
GET, POST 차이?  
spring을 왜 쓰냐?  
gradle이 뭐냐? 이거 왜씀? - maven의 발전  
equals and hashcode : <https://mangkyu.tistory.com/101>  
자바 solid, 객체지향의 특성 : 캡상추다
