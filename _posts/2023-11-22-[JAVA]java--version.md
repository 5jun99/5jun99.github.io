---
layout: post
title: "[Java] java -version"
date: 2023-11-22 00:00:00 +0900
category: Java
tags: []
original_url: https://velog.io/@9409velog/java-version
---

# 시작

---

자바를 많이 써오면서 여러 JDK 를 쓰게 되고 이럴 때 JDK의 버전도 다르고 배포하는 사이트도 다르고 또 이들끼리 차이점이 뭔지도 모르겠고 해가지고 정리할겸 이 글을 쓴다  
[[Reference]](https://www.marcobehler.com/guides/a-guide-to-java-versions-and-features)  
[Wiki](https://ko.wikipedia.org/wiki/%EC%9E%90%EB%B0%94_%EB%B2%84%EC%A0%84_%EC%97%AD%EC%82%AC)  
with [chatGPT](https://chat.openai.com/)

# JDK

---

그래도 java에 대한 얘기니까 가장 기본적인 JDK에 대해서 알아보자

## JDK란?

Java Development Kit"의 약자로, 자바 프로그래밍 언어로 소프트웨어를 개발하고 실행하기 위한 개발 도구 모음이다. 자바 언어의 컴파일, 디버깅, 실행, 문서화 등을 지원하는 핵심 도구와 라이브러리로 구성되어 있다.

<구성요소>

-   자바 컴파일러 (javac): 소스 코드를 바이트 코드로 변환하는 컴파일러

-   Java Runtime Environment (JRE): 자바 애플리케이션을 실행하는 데 필요한 런타임 환경을 제공함. JRE는 자바 가상 머신 (JVM) 및 필수 라이브러리 등을 포함함.
-   자바 가상 머신 (JVM): 자바 바이트 코드를 기계어로 변환하여 실행하는 역할을 함. 각 플랫폼에 특화된 JVM이 제공되어 Java 애플리케이션이 여러 운영 체제에서 실행됨.
-   자바 API 라이브러리: 표준 Java 클래스 라이브러리와 다양한 API를 포함하여 프로그래머가 자바 애플리케이션을 개발할 때 사용할 수 있는 기본적인 도구와 자원.

# Java Distribution

---

JDK의 다운로드를 지원하는 사이트가 여러가지이다.  
자바는 원래 썬 마이크로시스템즈에서 개발 되었지만, 실제로 지금은 여러 기업과 커뮤니티에서 자바 개발 환경을 배포한다. 이렇게 여러 기업에서 배포하는 jdk는 다른 특징과 기능을 제공한다. 라이선스 및 이용약관이 일단 많이 다르고, 유지보수에 대한 정책도 다르다.

-   OpenJDK
-   OracleJDK
-   Oracle JDK vs OpenJDK

    -   Oracle JDK는 상용(유료)이지만, OpenJDK는 오픈소스기반(무료)
    -   Oracle JDK의 라이선스는 Oracle BCL(Binary Code License) Agreement이지만, OpenJDK의 라이선스는 Oracle GPL v2
    -   Oracle JDK는 LTS(장기 지원) 업데이트 지원을 받을 수 있지만, OpenJDK는 LTS 없이 6개월마다 새로운 버전이 배포된다.
    -   Oracle JDK는 Oracle이 인수한 Sun Microsystems 플러그인을 제공하지만, OpenJDK는 제공하지 않는다.
    -   Oracle JDK는 OpenJDK 보다 CPU 사용량과 메모리 사용량이 적고, 응답시간이 높다.

-   Adoptium
-   Azul Zulu, Amazon Corretto, SAPMachine

## The OpenJDK project

# Java 1 ~ 17 특징

---

버전 별 특징을 알아보기 전에 버전의 이름이 헷갈리는 부분이 있어서 좀 찾아봤다. 자바 8이 꽤 대규모 릴리즈였는데, zulu의 자바 8의 릴리즈 버전은 1.8이라는 이름이 붙는다. 이는 초기 jdk의 버전 이름이 1.x 형식으로 붙여졌기 때문이고 결국 1.x는 java x 와 똑같은 버전이다. (java x형식의 이름은 5버전부터 사용됨)

-   패치노트를 전부 다 가져올 순 없어서 주요 사항만 정리해봤다.

## JDK 1

1996년 출시되었고 안정화 버전인 JDK 1.0.2를 자바 1이라고 한다

## JDK 1.1

이너 클래스, javabean, RMI, JDBC 추가

> 이너 클래스
>
> ---
>
> 다른 클래스 내부에 정의된 클래스

> javabeans
>
> ---
>
> 컴포넌트 기반 sw 개발을 위한 규약이라고 생각하면 좋음.
>
> -   자바 클래스로 구현
> -   기본 생성자
> -   getter setter
> -   이벤트 처리
> -   기타 등등

> RMI
>
> ---
>
> java Remote Method Invocation)는 자바에서 원격 객체 간에 통신하기 위한 기술, 객체 지향성 특성을 그대로 활용할 수 있도록 지원함

## J2SE 1.2

Swing GUI, JIT, Collection Framework 등의 굵직한 기능이 추가됨. 2부터 약칭을 J2SE(Java 2 Standard Edition)로 표기하기 시작했으며, 이 표기는 5까지 사용됨

> JIT
>
> ---
>
> Java 언어는 일반적으로 소스 코드를 바이트 코드로 컴파일하고, 이를 JVM에서 해석하여 실행하지만, JIT 컴파일러는 프로그램을 실행하는 동안 바이트 코드를 네이티브 코드로 컴파일하여 직접 실행한다.

## J2SE 1.3

JPDA가 추가 됨

> JPDA (Java Platform Debugger Architecture)
>
> ---
>
> JPDA는 자바 애플리케이션의 디버깅 및 프로파일링을 가능하게 하며, 이는 주로 통합 개발 환경(IDE)에서 사용됨. IDE에서 제공되는 디버거는 JPDA를 기반으로 하여 자바 애플리케이션의 실행 흐름을 추적하고, 변수의 값을 검사하며, 중단점에서 프로그램의 실행을 일시 중지시키는 등의 기능을 수행함.

## J2SE 1.4

정규 표현식 추가, IPv6 지원, xml 파서

> 정규표현식
>
> ---
>
> 문자열을 다룰 때 일정한 패턴을 표현하는 언어 방식  
> ex) 개별 숫자 - /[0-9]/g : 0~9 사이 아무 숫자 에서 '하나' 찾음

## Java SE 5

처음 릴리즈 번호는 1.5 였지만 새로운 번호 체계 5를 쓰기 시작함

-   제네릭 : 타입 정보를 명시하여서 안정성을 높임 <> 안에 타입 써주기
-   annotation : 소스코드에 메타데이터를 추가해서 컴파일러에게 특정 작업을 수행시킴 or 런타임시 프로그램의 동작으로 조정함 ex) @override @controller @setter
-   auto boxing: 기본 데이터 타입(int, double)와 래퍼 클래스(Integer,Double)간의 자동변환

## Java SE 6

표기가 J2SE 에서 Java SE로 바뀜

## Java SE 7

-   클래스 초기화 시 Type iterface를 지원하게 됨  
    new ArrayList(); => new ArrayList<>();
-   switch 문에서 string 사용 가능

## Java SE 8

오라클 인수 후에 첫 번째 버전임 많은 기능이 추가됨

-   람다 표현식

```
  (parameters) -> expression
```

기본 구조임

```
  //기존 방식
  MyFunctionalInterface square1 = new MyFunctionalInterface() {
      @Override
      public int square(int x) {
          return x * x;
      }
  };

  MyFunctionalInterface square2 = (x) -> x * x;

  // 인터페이스 정의
  interface MyFunctionalInterface {
      int square(int x);
  }
```

다르게 표현할 수 있게 됐음

-   Interface의 Default Methods : 메소드 구현이 안되는 interface에서 default methods로 구현을 할 수 있게됨
-   Optional 구조체 추가
-   새로운 날짜 api

## Java SE 9

-   Jigsaw
-   Jshell

## Java SE 10

-   Local-Variable Type Interface

## Java SE 11

-   HTTP 클라이언트(JEP 321)
-   새로운 String 메서드 추가
-   Lambda 파라미터로 var 사용

## Java SE 12

-   switch 구문 확장

## Java SE 13

-   switch문에 yield라는 예약어 추가
-   Text Block : 줄 바꿈 문자가 자동으로 포함됨 (preview)

## Java SE 14

-   record 클래스 추가 : 생성자, 접근자, equals, hashCode, toString 메서드 포함 (preview)
-   instanceof의 패턴 매칭 (preview)

## Java SE 15

-   Text-Blocks 및 Multiline Strings 추가 (standard)
-   sealed classe (preview) 상속되는 클래스들을 따로 지정
-   instanceof의 패턴 매칭 (2nd preview)

## Java SE 16

-   open jdk github으로 마이그레이션

## Java SE 17

-   현재 LTS(장기 지원) 릴리스
-   spring boot 3.0 부터는 자바 se 17 이상만 지원
-   Record Data class 추가 (standard)
