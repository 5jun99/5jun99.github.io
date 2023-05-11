---
layout: post
title: '[Spring] cannot invoke "~" because "~" is null'
date: 2024-07-14 00:00:00 +0900
category: Spring
tags: []
original_url: https://velog.io/@9409velog/Spring-cannot-invoke-%EB%A9%94%EC%84%9C%EB%93%9C%EC%9D%B4%EB%A6%84-because-service%EC%9D%B4%EB%A6%84-is-null
---

다른 클래스에 의존성을 주입하다보면 이런 에러가 심심찮게 보인다.  
결국에 주입한 클래스가 null 이란 뜻.

왜 null이지?

빈 주입을 하지 않아서이다.

**빈 주입이란 무엇이지?** 의존성 주입의 일종이다.

스프링에서는 객체의 생성과 소멸 등에 대한 제어를 컨테이너가 관리하고 필요할 때 주입을 받아 사용하게 된다. 즉 위 에러는 의존성 주입(di 내지 빈 주입)이 제대로 되지 않아서 생긴 것인데,

의존성을 주입할 수 있는 방법은 다음과 같다.

1. 생성자 주입
2. 필드(@Autowired) 주입
3. setter(수정자) 주입

생성자 주입에 있어서 많이 쓰는 방법은 @RequiredArgsConstructor을 사용하는 것인데,  
이 어노테이션은 final이 붙은 선언에 한해 모든 필드를 인자값으로 하는 생성자를 만들어준다.  
그래서 의존성 문제가 뜨면 private final 에 @RequiredArgsConstructor을 넣어주면  
된다.

그럼 왜 @Autowired를 쓰는 것을 지양할까?

대표적으로 순환참조를 방지할 수 있어서이다.  
예를 들어 객체 a와 b가 있다고 생각해보자. 클래스 a를 생성될 때 b 객체가 필요하다면, 스프링 컨테이너는 a객체를 생성한다음에 b객체를 찾아서 자동으로 주입한다. 이때 필드 주입방법은 객체가 이미 생성된 후에 주입되기 때문에 초기화 순서나 순환 참조 문제가 발생할 수 있는 것이다. 반면에 생성자 주입은 명시적으로 a 객체를 생성할 때 b객체가 필요하다는 것을 표현해준다.

사실 나도 완벽히 이해는 안됐다. bean이 무엇이고, final 과 생성자의 관계가 직관적으로 와닿지 않는다.

![](/assets/9409velog/spring-cannot-invoke-because-is-null_image.png)
