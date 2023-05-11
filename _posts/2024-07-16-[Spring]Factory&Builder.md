---
layout: post
title: "[Spring] 객체 생성 어떻게 할 거야? (feat. builder, constructor)"
date: 2024-07-16 00:00:00 +0900
category: Spring
tags: []
original_url: https://velog.io/@9409velog/Spring-%EA%B0%9D%EC%B2%B4-%EC%83%9D%EC%84%B1-%EC%96%B4%EB%96%BB%EA%B2%8C-%ED%95%A0-%EA%B1%B0%EC%95%BC-feat.-builder-constructor
---

자바를 하면서 항시 드는 생각인데, dto에서 entity 왔다갔다 하는 일이 필요할 때, builer를 써주는 게 맞는지 아님 dto를 인자로 받는 생성자를 entity에서 생성해주는 것이 맞는지 항상 고민이었다.

## builder

```
Seminar seminar = Seminar.builder()
                         .seminarDate(localDate)
                         .presentorList(new ArrayList<>())
                         .build();

```

말그대로 클래스 안에 buider 어노테이션이 들어간 메서드(생성자)를 만들어서 다음과 같이 생성할 수 있게 해주는 코드이다.

### 장점

-   가독성이 좋다
-   유연성 - 필드 순서 상관없이 매개변수 개수 상관없이 활용하기 좋다
-   확장성이 좋다

## 생성자

```
Seminar seminar = new Seminar(dto);
```

dto를 넘기면 생성자에서 dto에서 getter로 필드들을 빼내서 entity의 필드에 설정해주는 방식이다.

### 장점

-   여러 레이어를 오가면서 데이터가 이동될 때 편함
-   객체 생성과 관련된 로직을 구분하기 좋음
