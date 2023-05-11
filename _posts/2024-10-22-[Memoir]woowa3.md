---
title: "[우테코프리코스] 2주차 미션 회고록"
date: 2024-10-22 00:00:00 +0900
category: Memoir
tags: []
original_url: https://velog.io/@9409velog/%EC%9A%B0%ED%85%8C%EC%BD%94%ED%94%84%EB%A6%AC%EC%BD%94%EC%8A%A4-2%EC%A3%BC%EC%B0%A8-%EB%AF%B8%EC%85%98-%ED%9A%8C%EA%B3%A0%EB%A1%9D
---

시험에 치이지만 미리미리 해놓고 싶은 마음에 요구사항이라도 분석해보겠다.

# 10/22

## 학습목표

![](/assets/9409velog/우테코프리코스-2주차-미션-회고록_image.png)

srp 와 테스트에 대한 내용이 목표인 듯 하다.  
제일 중요한 것은 피드백에서 나왔는데 개인적으로 기억해놓아야할 부분은 다음과 같다.  
![](/assets/9409velog/우테코프리코스-2주차-미션-회고록_image.png)

-   명세를 잘 해줘야 한다는 생각에 길게 많이 썻는데 줄일 수 있다면 줄이는 것도 방법이구나 싶다.
-   그리고 java에서 제공하는 api를 잘 쓰라는 피드백도 있었다. 뭔가 자바에서 주는 api들은 무거울 거라는 생각이 있어서 배열을 쓰곤 했는데 코드 가독성을 생각하면 적재적소에 사용하는 것은 좋은 것 같다.
-   추가적으로 주석을 남용하지 말라는 피드백도 있었다. 주석은 필요할 때만 충분히 코드로 충분히 의미를 전달하는 것이 중요하다!

## 기능 요구사항

대충 자동차 경주에 대한 기능 구현 요구사항이었다.

### 도메인 잘 이해했니?

-   자동차는 n개이다.
-   각 자동차는 이름이 있다.
-   사용자의 입력에 따른 이동 횟수가 주어진다.
-   이동 횟수 마다 이동을 할 수 있고 이동에는 조건이 있다.
-   모든 이동이 완료되면 가장 많이 이동한 자동차(들)이 승리한다.

### 어떤 예외가 있을 거 같아?

-   사용자가 `,`이 아닌 구분자를 쓴다
-   횟수를 입력 시 숫자가 아닌 다른 것이 들어온다.
-   근데 사용자가 `,`이 아닌 구분자를 쓰면 프로그램에서는 그냥 하나의 이름으로 인식하지 않을까? 생각해봐야할 주제다

### 왜 레이싱 게임일까?

사실 정확하진 않지만 레이싱 게임의 특성 상 객체의 상태와 행동이 잘 드러나는 코드가 필요하다고 생각이 들었다. 아마 객체의 책임과 의무를 잘 판단해보도록! 이라는 뜻이 담긴 과제지 않을까? 싶다.

## 프로그램 요구사항

![](/assets/9409velog/우테코프리코스-2주차-미션-회고록_image.png)  
새로운 유형의 프로그램 요구사항이다

### 왜 이런 요구사항이 있을까?

-   왜 `depth` 제한이 있을까? 가독성을 위해서일까?  
    가독성을 위해서 ealry return을 참 많이 쓴다. for문의 반복을 막기 위해 메서드를 분리 하기도 한다.
-   왜 삼항 연산자를 쓰면 안 될까??  
    아마 depth를 줄이기 위해서 쓰지 말라는 의미도 있는 거 같다. 뭔가 3항 연산자는 나 이렇게 짧게도 코드 짤 줄 안다~ 느낌이 들어서 쓸 때 기분이 좋았던 적도 있는데, 확실하게 찾아보고 싶어졌다. <https://kwaksh2319.tistory.com/627>  
    위 블로그에서 장단점을 찾아봤다. 확실히 가독성이 떨어질 수 있는 경우가 많은 문법이어서 웬만하면 지양하지만 적재적소에 쓰면 좋은 효과를 낼 수 있을 거 같다
-   단위 테스트! 드디어 나왔다. 사실 테스트 코드에 대한 지식이 많지 않다. 코스 시작하기 전에 배우고 오고 싶었지만 핑계인지 뭔지 미루어버린 부분이다. 이 기회에 제대로 공부해보려고 한다!

# 10/23

시험 기간이라 바쁘긴 하지만 모델과 기능 명세서 정도 짜보겠다는 마음으로 짜봤다.

## 기능 명세

![](/assets/9409velog/우테코프리코스-2주차-미션-회고록_image.png)  
리드미 파일이다.

이번 프로젝트에서 수행해야하는 기능은 다음으로 정리했다

-   입력을 잘 쪼개서 리스트로 컨트롤러에 넘겨주기
-   경기를 반복 수 만큰 실행하기
-   랜덤한 숫자 조건으로 자동차 움직이기
-   매 실행마다 결과 출력하기
-   우승자 찾아내기  
    ![](/assets/9409velog/우테코프리코스-2주차-미션-회고록_image.png)

## Model

모델은 보자마자 주요 역할을 하는 두 객체로 나누어야겠다고 생각했다. 자동차와 경기는 다른 책임을 가지고 있고 협력을 해야하는 사이라고 생각했기 때문이다.

### 자동차

-   자동차는 이름을 가지고 있다.
-   자동차는 이동한 거리 정보를 가지고 있다.  
    이부분에서 고민을 많이 했다. 거리 이동 정보를 경기가 가지고 있는 게 맞나? 자동차에서 불러올까? 하다가 어쩌피 이름도 경기에서 모르는데 거리 이동도 몰라도 된다고 생각했고, 경기는 자동차한테 움직이라고 물어보고 최종 우승자를 뽑아내는 것이 주 의무라고 생각하고 자동차의 필드에 넣었다.
-   자동차는 특정 조건으로 움직일 줄 알아야한다.

### 경기

-   자동차에게 정보를 물어본다
-   컨트롤러까지 자동차를 안 보여준다 경기가 감싸주도록 했다.
-   경기는 우승자들을 찾고 뷰에 넘겨준다.

## Controller

이번에도 주요 컨트롤러와 세부 컨트롤러로 나누었다. 저번 계산기에서는 입력을 처리하는 부분이 중요해서 모델로 뺐지만 이번엔 파싱 정도만 하면 되기에 inputcontroller로 뺐다.  
주요 컨트롤러와 뷰와 직접적인 데이터 통신을 막고 싶어서 outinput handler를 따로 두었다.

## View

입출력에 관련된 로직을 담고 있다. 이번엔 따로 까다로운 출력이 없어서 간단하게 작성될 거 같다.

# 10/26

핑계겠지만, 맞다 매일 꼼꼼히 질문하겠다는 목표를 잘 못했다. 시험에 조금 시간을 많이 뺐겼었나보다. 그래도 오늘은 전체적인 구현을 완료했다.  
전체적인 코드를 설명하기보다 느꼈던 점을 위주로 설명을 해보겠다.

## Stream

이번에는 Stream과 foreach를 많이 쓰게 되었다. 전체적으로 객체를 돌아봐야하는 부분이 있어서 그랬던 것 같다.

```
public Race(List<String> racingCarsName){
        this.racingCarList = racingCarsName.stream()
                .map(RacingCar::new).toList();
    }

```

```
public HashMap<String, Integer> retrieveRaceResults(){
        executeRace();
        HashMap<String, Integer> executedResult = new HashMap<>();
        racingCarList.forEach(racingCar ->
                executedResult.put(racingCar.getName(), racingCar.getMoveCount()));
        return executedResult;
    }

```

```
public void printRaceResult(HashMap<String, Integer> raceResults){
        raceResults.forEach(consoleView::printRaceDetails);
        System.out.println();
    }
```

```
public List<String> findWinners() {
        Integer winnerMoveCount = racingCarList.stream().mapToInt(RacingCar::getMoveCount).max().orElse(0);
        List<RacingCar> winners = racingCarList.stream().filter(car -> car.getMoveCount().equals(winnerMoveCount))
                .toList();
        return winners.stream().map(RacingCar::getName).toList();
    }
```

중요 코드에 들어있던 부분들이다.

스트림에는 종류가 있다.  
여러가지가 있지만 여기서는 배열 스트림과 컬렉션 스트림 정도만 소개 하겠다.

```
//배열
String[] arr = new String[]{"a", "b", "c"};
Stream<String> stream = Arrays.stream(arr);
//컬렉션
List<String> list = Arrays.asList("a","b","c");
Stream<String> stream = list.stream();
```

`for`문과 `iterator`를 항상 사용하면 코드도 길어지고 가독성도 떨어지는 단점이 있는데 이를 극복하게 해주는 기능이라고 생각하면 좋다. ~~(파이썬에서는 다되는데)~~  
메서드의 이름들이 생각보다 직관적이어서 스트림에 대한 기본 지식만 있으면 쉽게 이해할 수 있으니 알아두자!

실질적인 연산과 가공이 이루어지는 중간 과정에서의 연산 중 이번에 `map`과 `fiter`를 많이 쓰게 되었다.  
`map`은 다른 파생 연산이 많은 만큼 알아두면 좋다. `map`은 스트림 내에 요소들을 하나씩 변환하는 역할을 하고 인자의 이름을 임의로 지정해서 사용하게 된다

```
this.racingCarList = racingCarsName.stream()
                .map(RacingCar::new).toList();
```

여기에서는 `List<String>` 형태의 `racingCarsName`을 스트림화 하고 그 인자로 하여금 `RacingCar` 객체의 인자로 넣어주었다.

`filter`는 항상 쓰이는 구석이 정해져있다  
아 이거 하려면 코드 길어질 거 같은데 깔쌈한 방법 없을까 하면 filter 사용할 때라고 생각하면 좋다.  
`filter`는 기본적으로 검증을 시켜주고 만족하는 스트림 요소만을 선택할 수 있게 해주기 때문에 라인을 많이 쓰지 않아도 되게 해준다.

```
List<RacingCar> winners = racingCarList.stream().filter(car -> car.getMoveCount().equals(winnerMoveCount))
                .toList();
```

여기서는 winnerCount에 해당하는 car들을 선택하는 즉 우승자를 찾아내기 위한 코드이다.

결과를 만들어주는 최종 연산에는 collecting이 많이 쓰인다.  
스트림의 장점 중 하나인데 스트림의 요소들을 다른 자료형으로 바꿔주는 연산도 가능하기 때문이다.  
`toList()` 나 `joining`을 이용해서 리스트나 문자열 형태로 바꿔주는 것이 가능하다.

## Service 계층

![](/assets/9409velog/우테코프리코스-2주차-미션-회고록_image.png)  
지금 내 mvc 패턴이 이런식으로 작성이 되고 있는 상황인데, 컨트롤러 계층에서도 중앙 컨트롤러가 있고, model 계층에서도 race라는 중앙 모델이 있어서 세부적인 클래스들은 숨겨주고 있다. 데이터 전송이 같은 계층 안에서 일어나는 것이 맞는 것인가? 라는 의문이 계속 있는 것 같다.  
같이 하는 다른 형은 domain의 계념으로 나누어서 controller를 나누곤 하는 것 같다. 근데 이러면 전체적인 run 메서드에서 객체들의 책임 흐름을 보는 데에 단점이 있을 거라고 생각이 들어서 그렇지 않고 있는 것인데, 그래서 그런지 로직을 담당하는 service 계층을 컨트롤러와 모델 사이에 하나 두면 어떨까라는 생각도 들었다. 근데 그런다면 실제 세계를 본따 만든다는 객체지향의 의미가 퇴색될까 걱정이 되기도 했다. 더 고민하고 찾아봐야하는 주제인 것 같다.

# 10/27

오늘은 버그 수정과 테스트 코드 수정을 주목적으로 작업을 했다. 덕분에 테스트 코드 작성법을 잘 알게 된 것 같은데 재밌거나 오래 걸렸던 부분을 소개해보겠다.

## test

테스트는 given, when, then 패턴으로 진행된다.  
given - 어떠한 input이 있을때,  
when - 어떠한 method를 실행하면,  
then - 이러한 결과가 나와야해!

```
@Test
    @DisplayName("자동차 이름을 입력받고 올바르게 파싱한다.")
    void testGetCarInput() {
        // given
        String input = "pobi,woni,jun";

        // when
        List<String> carNames = consoleInputHandler.parseCarInput(input);

        // then
        assertEquals(List.of("pobi", "woni", "jun"), carNames);
    }
```

이러한 패턴을 꽤 잘 나타내주는 코드이다.  
저러한 input이 있을때 consoleInputHandler에서 parseCarInput이라는 메서드를 실행하면?  
이러한 리스트와, carnames라는 메서드의 결과가 같아야 한다! 라는 것이다.

assert라는 메서드가 나오게 되는데 assert는 이런 종류가 있다.

-   `assertEquals(a, b)`: a와 b가 같은가
-   `assertSame(a, b)`: a와 b가 같은 객체인가
-   `assertTrue(a)`: a 명제가 참인가

메서드의 특성에 맞게 설정하면 된다.

```
// 테스트용으로 랜덤 숫자를 고정시키는 클래스
    private static class TestableRacingCar extends RacingCar {
        private final int fixedRandomValue;

        public TestableRacingCar(String carName, int fixedRandomValue) {
            super(carName);
            this.fixedRandomValue = fixedRandomValue;
        }

        @Override
        protected int getRandomInteger() {
            return fixedRandomValue;
        }
    }
```

앞서 말했듯이 나는 car에게 move라는 행위를 구현해줬다. 근데 그 move를 테스트하려고 하는데, move는 랜덤한 수가 뽑혔을 때 4이상일 때 실행되는 메서드이다. 그렇기에 테스트를 할 때는 이를 제어할 필요가 있었다. 찾아보던 중에 알게 된 방법은 상속받는 클래스를 만들어, move 메서드 중 random한 부분을 overide하는 것이었다. 이 부분에서 메서드의 분리가 일어났었는데 원레 move에는 랜덤 함수와 이를 판단하는 조건문이 같이 있었다. 근데 overide를 편하게 하기 위해서는 랜덤 함수를 따로 분리해줘야했다. 덕분에 메서드도 분리되고 테스트도 수월하게 할 수 있었다.

![](/assets/9409velog/우테코프리코스-2주차-미션-회고록_image.png)

이번 주차도 얼레벌레 제출했다. 바빠도 남은 2주도 열심히 해보자.
