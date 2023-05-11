---
layout: post
title: "[Java] Collections, Generics, Lambda, Stream"
date: 2023-12-29 00:00:00 +0900
category: Java
tags: []
original_url: https://velog.io/@9409velog/Collections-Generics-Lambda-Stream-%EC%A0%95%EB%A6%AC-with-Java
---

# Collections

콜렉션 프레임 워크는 데이터를 다루는 자료구조를 사용하는 클래스의 집합이라고 생각하면 좋다. 기존에 사용이 불편했던 Array 보다 더 많은 기능을 활용함으로서 쉽게 개발할 수 있다.  
collections 프레임워크의 클래스는 Collection을 implement하는 클래스나, interface이다.

## List

순서가 있는 집합, 중복을 허용한다. ex) ArrayList

```
public static void main(String[] args) {
        List<Integer> list = new ArrayList<>();
        list.add(1);
       	list.get(2); //인덱싱


```

## Set

순서를 유지하지 않는 데이터 집합, 중복 허용하지 않음 ex)HashSet

```
public static void main(String[] args) {
Set<Integer> integerSet = new HashSet<>();
integerSet.add(1);
integerSet.add(3);
integerSet.add(2);
integerSet.add(9);
integerSet.add(9);

Set<String> stringSet = new HashSet<>();
stringSet.add("LA");
stringSet.add("New York");
stringSet.add("LasVegas");
stringSet.add("San Francisco");

stringSet.add("LA") // ==> 실제로는 추가 안됨
```

## Map

키와 value로 구성되는 데이터 특징 인덱싱이 아님 키값으로 vaule를 찾아냄 python의 dictionary와 유사

키는 distinct함 키에 대해서 value를 넣으면 마지막 값만 남음

```
Map<Integer, String> map = new HashMap<>();
map.put(1, "apple");
map.put(2, "berry");
map.put(3, "cherry");
map.put(100, "pineapple");


```

-   containsKey(key): key를 가지고 있는 지에 대한 true/false 값 반환
-   get, remove (key): 해당 key 값에 대한 value를 가져오거나 제거

## Stack

LIFO 방식의 데이터 자료구조임. 제일 마지막에 들어온 것이 첫번째로 나감

```
Stack<Integer> stack = new Stack<>();
stack.push(1);
stack.pop();
```

push로 제일 뒤에 넣고, pop 으로 제일 마지막 값을 반환함

## Queue

FIFO 형식의 데이터 자료구조. 파이프 형태로 먼저 들어온게 먼저 나간다.

```
Queue<Integer> queue = new LinkedList<>();
queue.add(1);
queue.add(3);

System.out.println(queue.poll()); // Queue에서 객체를 꺼내서 반환
```

add, poll로 삽입과 제거를 진행함. add가 맨 뒤에 넣기, poll이 가장 앞값 반환하기

## Deque

queue와 stack의 성질을 모두 가지고 잇는 자료 구조.

```
ArrayDeque<Integer> deque = new ArrayDeque<>();
        deque.addLast(1);
        deque.addFirst(2);
        deque.offerLast(3);
        deque.offerFirst(4);
        System.out.println(deque);
        deque.pollFirst();
        deque.pollLast();
        System.out.println(deque);
```

addFirst/Last , pollFirst/Last로 삽입 제거 진행함. remove와 peek도 지원함

# +Generics

객체를 생성할 때 동작은 같은데, 타입만 다른 경우 따로 타입을 지정할 수 있는 기능  
같은 List 지만 int용 String 용이 따로 있지 않고 인스턴스 생성시에 선언하는 것임.

```
public class Main {
public static void main(String[] args) {
List<String> list = new ArrayList();
Collection<String> collection = list;
}
}

```

제네릭스는 꺽쇠(<>)안에 타입을 지정해주는 방식으로 사용함

# Lambda

람다식은 식별자 없이 실행 가능한 함수라고 생각하면 됨. 함수 이름이나, 식별자를 따로 정의하지 않아도 간결하게 사용할 수 있는 것

```
public class Main {
public static void main(String[] args) {
ArrayList<String> strList = new ArrayList<>(Arrays.asList("korea", "japan", "china", "france", "england"));
Stream<String> stream = strList.stream();
stream.map(str -> str.toUpperCase()).forEach(System.out::println);
}
}

```

> 이중 콜론 (::)  
> 호출하고자 하는 함수의 파라미터 갯수와 각각의 타입이 lambda식에 전해지는 인자와 일치할 때 파라미터 값 입력을 생략하고 클래스의 함수만을 입력해서 사용할 수 있게 해준다.  
> 위의 예제를 봤을 때 println의 파라미터 갯수와 foreach에서 전달되는 인자의 갯수가 같으므로 class::메서드 이런 식으로 사용이 가능하다.

-   람다식의 단점

1. 람다를 사용하여서 만든 익명 함수는 재사용이 불가능.
2. 람다만을 사용할 경우 비슷한 메소드를 중복되게 생성할 가능성이 있으므로 지저분해질 수 있음.
3. 로그를 보거나 디버깅을 하기 어려울 수 있음. 함수의 정확한 이름과 위치가 나타나지 않기 때문.

# Stream

fucntional 한 프로그래밍을 가능하게 해주는 도구임. 컬렉션의 저장요소를 하나씩 참조해서 람다식으로 처리할 수 있도록 해줌.  
스트림은 원래 데이터 소스를 변경하지 않음. 작업을 내부적으로 반복 처리함. 컬렉션의 요소를 모두 읽고 끝나면 재사용이 불가능함. 재생성해야함

## 스트림의 구조

1. 스트림 생성 -> 2. 중간 연산 -> 3. 최종 연산
2. 스트림 생성  
   말그대로 스트림을 생성하는 것임. Collection.stream으로 생성함
3. 중간 연산  
   람다식을 이용해서 map, sort, filter 등의 가공을 하는 것임
4. 최종 연산  
   요소를 모두 가공하고 그것을 최종적으로 반환하는 단계 컬렉션으로 반환 할 수 있음

```
public static void main(String[] args) {
        List<String> names = Arrays.asList("김정우", "김호정", "이하늘", "이정희", "박정우", "박지현", "정우석", "이지수");
        Stream<String> namestream = names.stream();

        long count = namestream.filter(name -> name.startsWith("이"))
                .count();
        System.out.println(count);
    }
```
