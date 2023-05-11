---
layout: post
title: "[Java] OOP - Q"
date: 2023-12-27 00:00:00 +0900
category: Java
tags: []
original_url: https://velog.io/@9409velog/%EA%B0%9D%EC%B2%B4%EC%A7%80%ED%96%A5-%ED%80%B4%EC%A6%88
---

# 정리

코드가 길어서 선정리 후 문제 좀 하겠다.  
처음에 풀 때는 뛰거나, 수영여부를 추상클래스로 하여서 할까도 생각하다가, 가능한 클래스에만 메서드를 정의하는 것으로 했었다.  
내가 듣는 강의 선생님의 코드를 보니, interface로 가능 여부를 명세하여 코드를 짰다.

# 퀴즈

1. 사람은 자식, 부모님, 조부모님이 있다.
2. 모든 사람은 이름, 나이, 현재 장소정보(x,y좌표)가 있다.
3. 모든 사람은 걸을 수 있다. 장소(x, y좌표)로 이동한다.
4. 자식과 부모님은 뛸 수 있다. 장소(x, y좌표)로 이동한다.
5. 조부모님의 기본속도는 1이다. 부모의 기본속도는 3, 자식의 기본속도는 5이다.
6. 뛸때는 속도가 기본속도대비 +2 빠르다.
7. 수영할때는 속도가 기본속도대비 +1 빠르다.
8. 자식만 수영을 할 수 있다. 장소(x, y좌표)로 이동한다.

---

위 요구사항을 만족하는 클래스들을 바탕으로, Main 함수를 다음 동작을 출력( System.out.println )하며 실행하도록 작성하시오. 이동하는  
동작은 각자 순서가 맞아야 합니다.

---

1. 모든 종류의 사람의 인스턴스는 1개씩 생성한다.  
   P02-C04 Java 기초 39
2. 모든 사람의 처음 위치는 x,y 좌표가 (0,0)이다.
3. 모든 사람의 이름, 나이, 속도, 현재위치를 확인한다.
4. 걸을 수 있는 모든 사람이 (1, 1) 위치로 걷는다.
5. 뛸 수 있는 모든 사람은 (2,2) 위치로 뛰어간다.
6. 수영할 수 있는 모든 사람은 (3, -1)위치로 수영해서 간다.

## 첫번째 코드

### person.java

```
public class Person {
    String name;
    int age, x, y, speed;

    public Person(String name, int age, int x, int y, int speed){
        this.name = name;
        this.age = age;
        this.x = x;
        this.y = y;
        this.speed = speed;
    }

    public void walk(int x, int y){
        this.x = x;
        this.y = y;
        getLocation();
    }
    public void getLocation() {
        System.out.println(name + ": (" + x + ", " + y + ")");
    }
    public void getInformation(){
        System.out.println(name);
        System.out.println(age);
        System.out.println(speed);
        System.out.println("(" + x + ", " +  y + ")");
    }
}
```

### GrandParent.java

```
public class GrandParent extends Person{

    public GrandParent(String name, int age, int x, int y, int speed) {
        super(name, age, x, y, speed);
    }

}
```

### Parent.java

```
public class Parent extends Person{
    public Parent(String name, int age, int x, int y, int speed) {
        super(name, age, x, y, speed);
    }
    public void run(int x, int y){
        this.speed += 2;
        this.x = x;
        this.y = y;
        getLocation();
    }
}
```

### Child.java

```
public class Person {
    String name;
    int age, x, y, speed;

    public Person(String name, int age, int x, int y, int speed){
        this.name = name;
        this.age = age;
        this.x = x;
        this.y = y;
        this.speed = speed;
    }

    public void walk(int x, int y){
        this.x = x;
        this.y = y;
        getLocation();
    }
    public void getLocation() {
        System.out.println(name + ": (" + x + ", " + y + ")");
    }
    public void getInformation(){
        System.out.println(name);
        System.out.println(age);
        System.out.println(speed);
        System.out.println("(" + x + ", " +  y + ")");
    }
}
```

### Main.java

```
public class Main {
    public static void main(String[] args) {
        GrandParent grandParent = new GrandParent("aa", 72, 0, 0, 1);
        Parent parent = new Parent("bb", 50, 0, 0, 3);
        Child child = new Child("cc", 23, 0, 0, 5);

        grandParent.getInformation();
        parent.getInformation();
        child.getInformation();

        grandParent.walk(1,1);
        parent.walk(1,1);
        child.walk(1,1);

        parent.run(2, 2);
        child.run(2, 2);

        child.swim(3, -1);

    }
}
```

## 수정 코드

### Human.java

```
public class Human {
    String name;
    int x, y;
    int age;
    int speed;

    public Human(String name, int x, int y, int age, int speed) {
        this.name = name;
        this.x = x;
        this.y = y;
        this.age = age;
        this.speed = speed;
    }

    public Human(String name, int age, int speed){
        this(name, 0, 0, age, speed);
    }

    public void printWhoAmI(){
        System.out.println("1)" + name + " 2)" + age + " 3)" + getLocation() + " 4)" + speed);
    }
    public String getLocation() {
        return "(" + x + ", " + y + ")";
    }

}

```

### GrandParent.java

```
public class GrandParent extends Human implements Walkable{
    public GrandParent(String name, int age) {
        super(name, age, 1);
    }

    @Override
    public void walk(int x, int y) {
        printWhoAmI();
        System.out.println("walk speed: " + speed);
        this.x = x;
        this.y = y;
        System.out.println(getLocation());
    }
}

```

### Parent.java

```
public class Parent extends Human implements Walkable, Runnable{
    public Parent(String name, int age) {
        super(name, age, 3);
    }

    @Override
    public void run(int x, int y) {
        printWhoAmI();
        System.out.println("run speed: " + (speed + 2));
        this.x = x;
        this.y = y;
        System.out.println(getLocation());
    }

    @Override
    public void walk(int x, int y) {
        printWhoAmI();
        System.out.println("walk speed: " + speed);
        this.x = x;
        this.y = y;
        System.out.println(getLocation());
    }
}

```

### Child.java

```
public class Child extends Human implements Walkable, Runnable, Swimmable{
    public Child(String name, int age) {
        super(name, age, 5);
    }

    @Override
    public void swim(int x, int y) {
        printWhoAmI();
        System.out.println("swim speed: " + (speed + 1));
        this.x = x;
        this.y = y;
        System.out.println(getLocation());
    }

    @Override
    public void run(int x, int y) {
        printWhoAmI();
        System.out.println("run speed: " + (speed + 2));
        this.x = x;
        this.y = y;
        System.out.println(getLocation());
    }

    @Override
    public void walk(int x, int y) {
        printWhoAmI();
        System.out.println("walk speed: " + speed);
        this.x = x;
        this.y = y;
        System.out.println(getLocation());
    }
}
```

### Walkable.java

```
public interface Walkable {
    void walk(int x, int y);
}
```

### Runnable.java

```
public interface Runnable {
    void run(int x, int y);
}
```

### Swimmable.java

```
public interface Swimmable {
    void swim(int x, int y);
}
```

### Main.java

```
public class Main {
    public static void main(String[] args) {
        Human grandParent = new GrandParent("aa", 77);
        Human parent = new Parent("bb", 49);
        Human child = new Child("cc", 24);

        Human[] humans = {grandParent, parent, child};

        for(Human human:humans){
            human.printWhoAmI();
        }

        System.out.println("시작");

        for(Human human:humans){
            if (human instanceof Walkable){
                ((Walkable) human).walk(1, 1);
            }
            if (human instanceof Runnable){
                ((Runnable) human).run(2,2);
            }
            if (human instanceof Swimmable){
                ((Swimmable) human).swim(3,-1);
            }
        }
    }
}
```
