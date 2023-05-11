---
layout: post
title: "[우테코프리코스] 1주차 미션 회고록 - 2"
date: 2024-10-21 00:00:00 +0900
category: Memoir
tags: []
original_url: https://velog.io/@9409velog/%EC%9A%B0%ED%85%8C%EC%BD%94%ED%94%84%EB%A6%AC%EC%BD%94%EC%8A%A4-1%EC%A3%BC%EC%B0%A8-%EB%AF%B8%EC%85%98-%ED%9A%8C%EA%B3%A0%EB%A1%9D-2
---

분량 조절 실패!! [1편으로](https://velog.io/@9409velog/%EC%9A%B0%ED%85%8C%EC%BD%94%ED%94%84%EB%A6%AC%EC%BD%94%EC%8A%A4-1%EC%A3%BC%EC%B0%A8-%EB%AF%B8%EC%85%98-%ED%9A%8C%EA%B3%A0%EB%A1%9D)

# 10/16

## README

기능 명세를 위해서 리드미를 먼저 작성해보았다.  
그 전에 간단하게 패드에 생각을 정리해보기도 했다. 결국엔 리드미에 그대로 오긴 했지만..  
![](/assets/9409velog/우테코프리코스-1주차-미션-회고록---2_image.png)

#### README.md

```
# java-calculator-precourse
# 기능
1. 사용자 입력부
2. 구분자로 나누어진 숫자들 배열에 저장 기능
3. 숫자 합한 후 반환 기능
4. 출력부
5. 커스텀 구분자 기능
6. 예외 처리
7. 테스트 코드 작성

```

테스트 코드를 제대로 배워본 적이 없어서 일단 뒤로 미루었다.

**커스텀 구분자 기능을 뒤로 미룬 이유**  
커스텀이어서 그런 지 나에겐 뭔가 추가 기능으로 느껴졌다. 그래서 먼저 주요 기능을 구현하고 추가해야겠다고 계획했다.

## 구현 시작!!

문득 든 생각인데, 이번 주 회고록은 처음이라 형식이 엄청 갖추어진 느낌은 아닐 것 같다. 뭐 이러면 어떻고 저러면 어떤가 나는 꼼꼼하게 코드를 짤 생각에 이미 행복하다!

그런 의미에서 무턱대고 질문을 쥐어짜냈다.

> 입력부 클래스를 구분할까?  
> 입력이 콘솔 말고 다른 거로 할 수도 있잖아 인터페이스로 관리해볼까?  
> 입력 핸들러는 의존성 주입을 어떻게 할까?  
> 추상화 수준은 어느정도로 맞출까?  
> 사실 계산기의 책임은 어느 정도까지일까?

저 마지막 질문이 제일 어려운데, 객체의 한 가지 책임을 바라보는 눈이 중요하다고 항상 이야기를 들어왔다.

### 🤨 1

오늘의 구현은 사용자의 입력을 받아서 배열에 저장하는 것까지인데, 배열에 저장하는 구현부를 작성할 때 메서드를 계산기 객체 안에 넣어둘지 아니면 다른 객체를 하나 더 만들어서 관리할 지가 고민이었다.

### 🤨 2

또 구분자에 대한 정규표현식을 메서드 안에 그냥 넣어둘 지 파라미터로 받게할까? 커스텀 구분자도 있으니, 파라미터로 받게 하기로 결정했다.

### 🤨 3

굳이 `consoleinputhandler` 와 `inputhandler`로 인터페이스와 구현체를 나누어야할까? 일단 나누어 관리하기로 결정! 다른 입력이 있을 것을 고려했다.

### 🤩 1

의존성 주입에 대해서 작성했던 글의 지식을 써먹을 수 있게 됐다!.

```
public class Calculator {
  private final InputHandler inputHandler;

  public Calculator(InputHandler inputHandler) {
      this.inputHandler = inputHandler;
  }
```

```
public static void main(String[] args) {
        // TODO: 프로그램 구현
        Calculator calculator = new Calculator(new ConsoleInputHandler());
        calculator.run();
```

`main` 에서 인터페이스 중에서 구현체를 정해준 채로 넘겨주어서 `calculator`는 내가 쓰는 구현 인풋핸들러가 무엇인지 신경 안써도 된다!

### 🤩 2

정규표현식을 오랜만에 봐서 다시 한 번 확인해보는 시간을 가졌다. 기본적으로 `[,;]`는 두 문자 중 하나라는 뜻! `[^xy]` 은 not 을 표현, `[x-z]` 은 x 부터 z 까지의 문자를 의미  
[참고](https://hamait.tistory.com/342)

깃허브 주소  
[미션 진행 중~~](https://github.com/rawfiremeat/java-calculator-7)

## 10/17

상큼하게 프리코스 커뮤니티를 보면서 시작한 3일차이다.  
사실 커뮤니티에서 마음껏 활동하는 분들을 보면서 열심히 해야겠다는 의지가 한풀 꺾여버린 어제였지만! 글을 쓰는 것은 아니어도 그 분들이 올리는 것이라도 보자! 라는 마음에 들여다봐봤다.

두가지 그제 내가 가졌던 의문점을 풀어주는 글이 있었다!  
![](/assets/9409velog/우테코프리코스-1주차-미션-회고록---2_image.png)  
왜 21일을 사용하는지! 에 대한 생각을 하고 있었는데 21의 새로운 기능을 먼저 봐보자라는 생각이 들었다. 예전에 [자바 버전에 대한 정리](https://velog.io/@9409velog/java-version)가 있긴 했는데 이번 기회에 다시 볼 수 있었다.  
[seol님의 엄청난 정리 블로그](https://blog.seol.pro/entry/Java-Java-21-%EC%83%88%EB%A1%9C%EC%9A%B4-LTS-%EB%B2%84%EC%A0%84%EC%9D%98-%EC%A3%BC%EC%9A%94-%EA%B8%B0%EB%8A%A5-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0)

다른 한 가지는 우테코 코드 스타일 적용에 대한 부분이다!  
java 코드 스타일을 준수하라고 했는데 그 많은 법칙을 어떻게 생각할까 라는 생각을 했는데 xml파일을 이용해서 ide에 스타일을 넣을 수 있었다!  
[코드 스타일 적용해보기](https://velog.io/@rorror1/%EC%9A%B0%ED%85%8C%EC%BD%94-7%EA%B8%B0-IntelliJ-%EC%BD%94%EB%93%9C-%EC%8A%A4%ED%83%80%EC%9D%BC-%EC%84%A4%EC%A0%95%ED%95%98%EA%B8%B0)

ide에 맨 설정만 많았지 코드 포매터가 있다는 것을 알지도 못했었다! 정말 신기한 개발 세계! 신기한 걸 참 많이 만들어놨다.

이런 것들을 시간들여서 작성하고 공유하시는 분들이 너무 멋져보였다. 학부 생활을 핑계로 코스를 조금씩 미루고 있는 나 자신이 부끄러웠지만! 나는 나대로 하면 되는 것이니 일단 오늘도! 벨로그를 적는다!

### 구현!!

오늘 구현해볼 내용은 리드미 파일에서 3, 4, 5 부분이다!

> 숫자 합한 후 반환 기능  
> 출력부  
> 커스텀 구분자 기능

생각나는대로 먼저 구현을 해보았다

```
public class Calculator {
    private final InputHandler inputHandler;

    public Calculator(InputHandler inputHandler) {
        this.inputHandler = inputHandler;
    }

    public void run() {
        String userInput = inputHandler.getUserInput();
        String[] inputStringNumbers = splitUserInput(userInput, "[,;]");
        int[] inputIntegerNumbers = changeStringArrayToIntegerArray(inputStringNumbers);
        int result = sumAllNumbers(inputIntegerNumbers);
    }

    private int sumAllNumbers(int[] inputIntegerNumbers) {
        return Arrays.stream(inputIntegerNumbers).sum();
    }

    private int[] changeStringArrayToIntegerArray(String[] StringNumbers) {
        return Arrays.stream(StringNumbers)
                .mapToInt(Integer::parseInt)
                .toArray();
    }

    private String[] splitUserInput(String userInput, String delimiter) {
        return userInput.split(delimiter);
    }
}

```

stream을 쓰게 되었는데 추상화 수준 유지를 위해서 메서드로 추출을 완료했다.  
내 눈에는 별 문제 없어보이는데 다시 한 번 꼼꼼히 봐봐야겠다  
`run` 이 주로 돌아가는 로직 메서드라고 생각하고 추상화 수준을 맞춰준다는 개념으로 접근했다.  
객체의 역할을 한개로 가져가는 것도 좋지만 메서드의 역할도 srp를 준수하는 것이 좋다고 생각해서 객체와 메서드의 책임이 무엇인가를 많이 고민했던 것 같다. 숫자 배열로 저장하는 것만 진행하고 커스텀 구분자 기능은 아직 완료하지 못했다.

### 생각해본 점

-   `handler`를 선언할 때 private final로 해야하는 이유?  
    첫번째는 캡슐화이다. private으로 handler를 다른 클래스의 접근으로부터 보호할 수 있다.  
    두번째는 불변성 유지, 객체의 일관성이다. final을 사용하면 inputHandler의 참조가 객체 생성 후 변경되지 않음을 보장하기 때문이다. 즉 의도치 않은 변경으로 인한 버그를 방지할 수 있다.
-   `inputHandler`를 따로 뺀 이유? 왜 interface로 구현했는 지?  
    첫째는 srp에 대한 내용이다. 계산기에 있어서 사용자에게 메세지를 띄워주는 것과 계산을 실제로 하는 것은 다른 책임이 있다고 생각했기 때문이다.  
    둘째는 isp에 대한 내용이다. 꼭 이 계산기가 콘솔로만 돌아갈까? 라는 생각을 했다. 혹시나 다른 입출력 방식에 대한 수정사항이 있다면 유지 보수에 편하게 만들고 싶다! 라는 생각을 하여서 따로 interface로 빼서 `Application`에서 의존성 주입해주도록 했다.

## 10/19, 10/20

오늘은 저번에 못 끝낸 커스텀 구분자 기능을 구현하고 mvc 패턴을 기반으로 한 리팩토링을 실시해보았다.

```
 private String extractCustomDelimiter(String userInput) {
        if (hasCustomDelimiterIn(userInput)) {
            delimiter = "" + userInput.charAt(2);
            return userInput.substring(5);
        }
        return userInput;
    }
    private boolean hasCustomDelimiterIn(String userInput) {
        return userInput.startsWith("//") && userInput.startsWith("/n", 3);
    }
```

단순하게 짜본 커스텀 구분자식이다. 이 때는 실수해서 개행 문자도 제대로 못쓰고 예외에 대한 상황도 대비가 덜 되어있었다. 한 메서드에서 구분자를 분리하고 `userinput`을 반환해주고 싶었는데 이것이 의무가 하나인 지 아닌 지 고민을 많이 했다. 메서드의 이름도 책임에 잘 맞지 않은 느낌이 있었다.

```
package calculator;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DelimiterParser {

    public String extractExpression(String userInput) {
        if (hasCustomDelimiterIn(userInput)) {
            return userInput.replaceAll("//.\\\\n", "");
        }
        return userInput;
    }

    public String extractDelimiter(String userInput) {
        if (hasCustomDelimiterIn(userInput)) {
            Matcher matcher = Pattern.compile("//(.)\\\\n").matcher(userInput);
            if (matcher.find()) {
                return matcher.group(1);
            }
        }
        return "[,;]";
    }

    public boolean hasCustomDelimiterIn(String userInput) {
        return userInput.matches("//.\\\\n.*");
    }
}
```

구분자에 대한 두번째 커밋 주요 내용이다.  
먼저 따로 클래스를 분리했고, 메서드의 책임을 나누어줬다. 추가적으로 정규식 표현으로 바꾸어주었다.

### 배운 점

-   정규식에 대한 다시 한 번 깊은 고찰을 겪었다. 역슬래시에 대한 역슬래시가 왜 3번이 더 들어가야하는 건지 !!!!!!!!!!!
-   `matcher`에 대한 지식을 얻었다! 패턴을 찾아내주는 함수이고 객체에 정보를 담아놨다가 group으로 묶어줄 수 있다. 여기서 find에 대한 내용을 알았는데 이건 좀 더 뒤에! 다루어 보겠다.

### 🤨 뭔가 맘에 안 드는데?

일단 `extract`에 대한 메서드가 두개인데 그 안에 `hasCustomDelimiterIn`에 대한 내용이 두 번 들어가는 것이 깔끔하지 않다고 생각한 것 같다.

### 생각해본 점

뭐가 나을까? 일단 calculator의 기능이 뭔지 계속 생각했다.  
![](/assets/9409velog/우테코프리코스-1주차-미션-회고록---2_image.jpg)  
써보면서 진행해 본 것이다. **우리가 지금 구현하고 있는 계산기는 무슨 일을 해야하나?** 가 주요 맹점이었다.  
그래서 크게 기능을 3가지로 나누어보기로 생각했다. **실제로 숫자를 다루는 계산부! 입출력부! 입력을 처리하는 기능부!** 이다.  
이렇게 나누고 보니 패키징이라든가 클래스들이 막 방치될 것 같은 느낌이 들을 찰나에 아는 형의 mvc 패턴에 대한 말이 있었고 영상을 추천해줬다.[제리 MVC 영상](https://www.youtube.com/watch?si=i11vXLups1uvOeUY&v=ogaXW6KPc8I&feature=youtu.be)

### MVC 패턴

이를 바탕으로 정리해본 나의 계산기 mvc 패턴 이다. ~~근데 이제 제출 하루 전에 만든,,,~~

![](/assets/9409velog/우테코프리코스-1주차-미션-회고록---2_image.png)

그렇게 해서 만들어진 controller 다!

```
package calculator.controller;

import calculator.controller.io.InputHandler;
import calculator.controller.io.OutputHandler;
import calculator.model.CalculatorModel;
import calculator.model.InputParser;

public class CalculatorController {
    private final InputHandler inputHandler; // 사용자 입력 처리 핸들러
    private final OutputHandler outputHandler; // 출력 처리 핸들러
    private final CalculatorModel calculatorModel; // 계산 로직을 처리 계산기 모델
    private final InputParser inputParser; // 입력 파싱 모델

    public CalculatorController(InputHandler inputHandler, OutputHandler outputHandler,
                                CalculatorModel calculatorModel, InputParser inputParser) {
        this.inputHandler = inputHandler;
        this.outputHandler = outputHandler;
        this.calculatorModel = calculatorModel;
        this.inputParser = inputParser;
    }

    public void run() {
        // 사용자로부터 입력을 받음
        String userInput = inputHandler.getUserInput();

        // 입력된 문자열을 숫자로 변환
        int[] operands = inputParser.extractOperands(userInput);

        // 변환된 숫자들로 계산을 수행
        int result = calculatorModel.calculate(operands);

        // 계산 결과를 출력
        outputHandler.displayResult(result);
    }
}

```

컨트롤러를 보면 도메인 지식이 없어도 대충 이해할 수 있어야하는 것 아닐까? 라는 생각을 많이 했다. 그를 위한 조건에는 크게 2가지가 있다.

-   기능에 대한 명시가 제대로 되어 있나?
-   객체들간 의존이 명확한가?

### 그럼에도 맘에 안 들어

사실 저 컨트롤러에도 맘에 안 드는 부분은 있다.  
**바로 저거 의존성 주입으로 저렇게 많이 받아도 되는 건가? 다른 방법이 있는 건가? 라는 생각이다.** ~~근데 너무 힘들어서 이번엔 못했,,,~~

마음에 안 들거나 애를 먹었던 부분은 더 있는데 바로 구분자 분리 부분이다.

```
package calculator.model;

import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class InputParser {
    //구분자
    private String delimiter;
    // 계산 수식
    private String expression;

    // 사용자 입력에서 피연산자를 추출
    public int[] extractOperands(String userInput) {
        if (userInput.isEmpty()) {
            return new int[]{0};
        }
        updateDelimiterAndExpression(userInput);
        return extractNumbersFromExpression(expression, delimiter);
    }

    //구분자와 수식을 업데이트
    private void updateDelimiterAndExpression(String userInput) {
        if (hasCustomDelimiterIn(userInput)) {
            expression = extractExpression(userInput);
            delimiter = "[.:" + extractDelimiter(userInput) + "]";
        } else {
            expression = userInput;
            delimiter = "[,:]";
        }
    }

    //수식을 추출하는 메서드
    public String extractExpression(String userInput) {
        return userInput.replaceAll("//.\\\\n", "");
    }

    //구분자를 추출하는 메서드
    public String extractDelimiter(String userInput) {
        Matcher matcher = Pattern.compile("//(.)\\\\n").matcher(userInput);
        matcher.find(); //??????
        return matcher.group(1);
    }

    // 사용자 입력에 커스텀 구분자가 포함되어 있는지 확인
    public boolean hasCustomDelimiterIn(String userInput) {
        return userInput.matches("//.\\\\n.*");
    }

    // 수식에서 구분자를 기준으로 숫자를 추출하는 메서드
    private int[] extractNumbersFromExpression(String expression, String delimiter) {
        String[] inputStringNumbers = parseUserInput(expression, delimiter);
        return changeStringArrayToIntegerArray(inputStringNumbers);
    }

    private String[] parseUserInput(String userInput, String delimiter) {
        return userInput.split(delimiter);
    }

    // 문자열 배열을 정수 배열로 변환하는 메서드
    private int[] changeStringArrayToIntegerArray(String[] stringNumbers) {
        return Arrays.stream(stringNumbers)
                .mapToInt(number -> {
                    int intValue = Integer.parseInt(number);
                    if (intValue < 0) {
                        throw new IllegalArgumentException("Negative numbers are not allowed: " + intValue);
                    }
                    return intValue;
                })
                .toArray();
    }
}

```

```
public class CalculatorModel {
    // 배열로 전달된 피연산자들을 모두 더하여 결과를 반환
    public int calculate(int[] operands) {
        return Arrays.stream(operands).sum();
    }
}
```

먼저 왜 굳이 calculate 만 따로 쓰는 모델 객체를 만든 거야? 라는 질문이 들 수 있다. 뭐 그럴리 없겠지만 나는 계산기란 덧셈만 하는 것은 아니라고 생각했기 때문이다. 유지 보수를 위해서는 이 쪽이 더 괜찮지 않을까 라는 생각이었다.  
그리고 대망의 `inputparser`인데, 저 친구 클래스 이름도 많이 바뀌었다. `delimiter parser` 였다가 다른 거였다가,,  
어찌됐든 가장 오류가 많이 떴던 부분은 바로

```
Matcher matcher = Pattern.compile("//(.)\\\\n").matcher(userInput);
        matcher.find(); //??????
        return matcher.group(1);
```

이 부분인데, 사실 원래는 `if(matcher.find())`가 group을 감싸고 있었다. 근데 `updateDelimiterAndExpression`부분에서 이미 커스텀여부를 확인을 한 터라 지워주었고 matcher에는 무조건 pattern이 탐지되는 것이 맞는데, group에서 자꾸 `null`을 반환하는 것이다. 귀신이 곡할 노릇! 무엇이 문제이지 하고 디버깅을 100번을 하다가 결국 `matcher.find()`의 부재에 문제가 있었다.  
![](/assets/9409velog/우테코프리코스-1주차-미션-회고록---2_image.png)  
`find`에 대한 부분인데 `find`가 선행되어야 `group`으로 접근할 수 있는 장치가 있었나부다,, 확인 창치를 없앴으니 그럴 수 밖에 없는 법 그래서 분기문을 만들면 `return`값이 꼬여버려서 `find()` 문을 따로 달아줬다.

### 쓰면서 맘에 안드네,,

```
// 사용자 입력에서 피연산자를 추출
    public int[] extractOperands(String userInput) {
        if (userInput.isEmpty()) {
            return new int[]{0};
        }
        updateDelimiterAndExpression(userInput);
        return extractNumbersFromExpression(expression, delimiter);
    }
```

이 메서드가 어떻게 보면 `inputparser`의 중심이 되는 메서드인데, 크게 두가지 기능이 있는 것이다. delimiter와 exprission을 분리 -> expression에서 delimiter를 이용한 split이다. 그런데 `userInput.isEmpty()` 예외처리할 때 급하게 쓴 이부분! 너무 추상화 수준에 안 맞지 않을까? 라는,,, 따로 boolean값을 반환하는 메서드를 빼주면 어땠을까.. 라는 생각이 있었다.

## 제출!

![](/assets/9409velog/우테코프리코스-1주차-미션-회고록---2_image.png)  
제출을 성공적으로 마쳤다. 테스트 코드가 더 있을 줄 알았는데 2개 뿐이어서 아쉽긴 했지만 배운 것이 많아서 저 두개의 테케 통과에 많은 것이 응축되어있지 않을까 싶다.

## 아쉬운 점

코드 한 줄 한 줄에 이유를 적어보겠다던 회고록이었지만 사실 한 줄 한 줄에는 담기지 못했다. mvc 패턴에 대한 이해도 부족했던 터라 설계도 부족했던 것이 사실이고. 다만 그래도 아직 1주차다! 내가 발전할 3주치가 더 남았다는 뜻! 다음 주도 화이팅이다.
