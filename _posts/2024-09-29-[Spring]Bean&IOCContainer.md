---
layout: post
title: "[Spring] Bean 과 IOC Container의 의존성 주입"
date: 2024-09-29 00:00:00 +0900
category: Spring
tags: []
original_url: https://velog.io/@9409velog/Spring-Bean-%EA%B3%BC-IOC-Container%EC%9D%98-%EC%9D%98%EC%A1%B4%EC%84%B1-%EC%A3%BC%EC%9E%85
---

# 🤨Bean?

spring 개발을 하다보면 코드에서 Bean을 많이 볼 수 있다.  
빈이란 추상적으로 말하자면 spring이 만들어주는 객체이다.

## ❓Spring이 객체를 만들어준다고?

우리가 보통 객체를 생성한다고 하면 어떻게 하는가?  
예시를 들어 생각해보자. 예시는 저번 포스트에서 이어진다. ==> [보고 오자!](https://velog.io/@9409velog/java-DI-%EC%9D%98%EC%A1%B4%EC%84%B1-%EC%A3%BC%EC%9E%85-%EC%9D%B4%EC%A0%A0-%EC%95%8C%EA%B3%A0-%EA%B0%80%EC%9E%90)

```
public interface Product {
	// void ~
}
```

```
public class Paper implements Product {
	//public void ~
}
```

```
public class Store{
	private Product product;

    public Store (Product product){
    	this.product = product;
    }

    //product 객체를 이용한 구현부
}
```

```
public class Main {
    public static void main(String[] args) {
        Product product = new Paper();  // product 객체를 주입
        Store store = new Store(product);
    }
}
```

보통 객체의 생성에 있어서는 사용자가 관리한다. 쉽게 new를 붙여서 객체 생성을 해야한다고 옛날의 java 수업을 기억해보자.

bean이 spring이 만든 객체라는 뜻은  
spring이 객체를 생성해주고 또 초기화해주고 소멸시키는 통상 객체의 생체주기를 관여하는 행동이라고 불리는 행위에서의 객체에 해당하는 것이 바로 bean이다.

## ❓클래스(객체)가 bean인 건 어떻게 아는데?

스프링으로 간단한 프로젝트를 클론코딩이라도 해봤던 사람이라면 알만한 방법이다.  
생각해보자. 우리는 서비스 객체, 컨트롤러 객체, 레포지토리 객체를 구현하고 실제로 웹이 돌아가는 걸 알면서도 의문을 품지 않았다. 혹은 품었더라고 넘어갔었다.  
나는 이런 질문이 떠오른다.

> 이 컨트롤러 클래스는 도대체 어디서 만들어졌고 호출되거나 주입됐길래 알아서 돌아가는 거지??

그렇다. 우리가 넣었던 @Service @Repository @ Controller 혹은 @Component 어노테이션이 붙은 클래스들ㅇ bean이 되는 것이다. 스프링은 이들을 찾아내서 bean으로 등록한다.

bean 으로 등록된 객체는 spring에서 만들어주고 초기화해주는 것이다. 정확히는 spring IoC 컨테이너에서 해주는 것이다.

## 빈 등록을 그렇게 하는 거였다고?

bean에 대해서 찾아볼 때 빈을 등록해왔던 방법이 많이 바뀌었다는 것을 알 수 있었다.  
본디 bean을 등록하려면 xml 설정 파일에 정의를 해야했었고 차츰 우리가 아는 어노테이션 기반 방법도 생겨났고 configuratoin 어노테이션을 활용해서 config 클래스 안에 bean을 등록하는 방법도 생겼다.

사실 이 부분에 대해서는 다음 포스트에서 자세히 다루려고 한다.  
~~더 찾아봐야하기 때문에,,,,나는 아무것도 모르고 스프링을 한다고 했었나😭.~~

# IoC 컨테이너가 말아주는 DI

그래서 bean 이야기를 왜 했냐?  
바로 spring을 사용하면 쉽게 할 수 있는 의존성 주입에 대해서 설명하기 위해서였다. 의존성 주입에 대해서는 간단하게 정리한 [포스트](https://velog.io/@9409velog/Spring-cannot-invoke-%EB%A9%94%EC%84%9C%EB%93%9C%EC%9D%B4%EB%A6%84-because-service%EC%9D%B4%EB%A6%84-is-null)가 있었는데 방법론만 설명한 것이고 뿌리를 제대로 이야기 안 한 것 같아서이다.

스프링의 IoC 컨테이너는 객체의 생체주기를 관리해준다고 위에서 설명했었다. 과연 그뿐일까?

당연히 아니다. spring은 bean 객체에서 의존하는 객체의 의존성 주입에 대한 사용자의 역할도 뺐어가버린다.

```
public interface Product {
	// void ~
}
```

```
public class Paper implements Product {
	//public void ~
}
```

```
@Component
public class Store {
    private Product product;

    @Autowired
    public Store(Product product) {
        this.product = product;
    }

    public void sellProduct() {
        product.sell();
    }
}
```

자 게시물 초반의 코드와 비교해서 바뀐 점을 찾아보자.  
어노테이션이 추가되지 않았는가? 또 무슨 변화가 있을까?  
바로 main 메서드 부분을 쓰지 않았다. 그냥 빠트린 것이 아니라 이제는 필요없어진 것이다.  
`@Component` 로 인해서 `Store store = new Store`가 필요 없어졌고 `@AutoWired` 덕분에 그 뒤에 `Product product = new Paper();`를 하고 생성자에 추가해주는 메서드도 필요없어진 것이다.

## ❓그러면 저 프로덕트가 종인지 펜인지 어떻게 알아?

좋은 질문이다!!`Product product = new Paper();` 이 코드가 없어져 버려 product의 구현체에서 무엇을 택할지가 모호해졌다. 인터페이스에 대한 구현체가 하나일 땐 알아서 단일의 구현체를 찾아 주입해준다. 하지만 구현체가 2개 이상이면? 이에 대한 방법으로 2가지가 있다.

### @Primary

`@Primary` 어노테이션을 활용할 수 있다. 이 어노테이션은 스프링에게 말한다.

"얘가 우선적인 구현체야!"

spring은 한 interface에 여러 구현체가 있다면 저 어노테이션이 붙은 구현체로 주입해준다.

### @Qualifier

```
@Component
public class Store {
   private Product product;

   @Autowired
   @Qualifier("paper")  // Bean 이름을 지정하여 Paper 객체 주입
   public Store(Product product) {
       this.product = product;
}

   public void sellProduct() {
       product.sell();
   }
}
```

`@Qualifier` 어노테이션은 구현체에 붙여주는 어노테이션이 아니라 해당 클래스(인터페이스)를 의존하는 객체(여기선 Store)의 의존성 주입부에 붙는다. 그리고 `@Qualifier`의 구현체의 이름인 인자를 보고 찾아서 의존성을 주입한다.

# 마치며

꽤 긴 시간동안 찾아보고 블로그를 작성해봤는데 모르고 쓰던 것을 이제서야 알 게 된 것이 부끄러웠다. 앞으로도 clean 한 코드를 위해서 물심양면의 노력을 하겠다.

# Reference

<https://velog.io/@seasame_oil/Spring-bean>  
<https://velog.io/@falling_star3/Spring-Boot-%EC%8A%A4%ED%94%84%EB%A7%81-%EB%B9%88bean%EA%B3%BC-%EC%9D%98%EC%A1%B4%EA%B4%80%EA%B3%84>  
<https://velog.io/@falling_star3/SpringBoot-%EC%8A%A4%ED%94%84%EB%A7%81%EA%B3%BC-%EC%8A%A4%ED%94%84%EB%A7%81-%EB%B6%80%ED%8A%B8>

그리고 Loving ChatGPT..
