---
layout: post
title: "GDSC 게시판 프로젝트 2주차 (페이징 처리)"
date: 2023-11-07 00:00:00 +0900
category: Memoir
tags: []
original_url: https://velog.io/@9409velog/GDSC-%EA%B2%8C%EC%8B%9C%ED%8C%90-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-2%EC%A3%BC%EC%B0%A8-%ED%8E%98%EC%9D%B4%EC%A7%95-%EC%B2%98%EB%A6%AC
---

## 📖강의

---

[코딩레시피 CRUD 게시판](https://www.youtube.com/watch?v=Vanl4wcAPW0&list=PLV9zd3otBRt7jmXvwCkmvJ8dH5tR_20c0&index=9)

## 🖥️개발환경

---

> Intellij IDEA Community  
> mysql 8.0.34  
> Spring Data JPA  
> JDK 11  
> SpringBoot 2.6.13

## ✍️정리

### ❓페이징 처리란?

> 사용자에게 데이터를 제공할 때, 전체 데이터 중 일부의 데이터만 보여주는 것

### ❗목표

-   게시물 목록을 임의의 수만큼 한 페이지에 보여주기
-   게시물 조회하기
-   뒤로 돌아가면 다시 해당 게시물의 페이지로 돌아가기

### 👨‍💻과정

---

#### 1. index.html

```
<button onclick="pagingReq()">페이징목록</button>

...

const pagingReq = () => {
        location.href = "/board/paging";
    }
```

페이지 화면에 접근하는 메서드

#### 2. BoardController

```
@GetMapping("/paging")
    public String paging(@PageableDefault(page = 1) Pageable pageable, Model model) {
//        pageable.getPageNumber();
        Page<BoardDTO> boardList = boardService.paging(pageable);

        // page 수 20개 , 3페이지다
        // 밑에 보여지는 페이지 갯수를 3개로 설정
        int blockLimit = 3;
        int startPage = (((int)(Math.ceil((double)pageable.getPageNumber() / blockLimit))) - 1) * blockLimit + 1;
        int endPage = ((startPage + blockLimit - 1) < boardList.getTotalPages()) ? startPage + blockLimit - 1 : boardList.getTotalPages();
        // 나머지 페이지들 계산
        model.addAttribute("boardList", boardList);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);
        return "paging";
    }
```

paging 경로로의 get 요청에 대한 응답임  
Service의 페이지 메서드에서 DTO들을 담은 boardList를 선언  
Model을 이용해서 뷰로 데이터 전달

> -   @PageableDefault : 페이징 및 정렬 정보의 기본값을 설정하기 용이
> -   pageable : 페이지 처리에 도움을 주는 메서드를 가지는 인터페이스

> Page<> vs List<>  
> List<>에 비해 Page<> 객체에는 현재 페이지의 데이터, 페이지 크기, 총 항목 수 및 정렬 정보가 포함되어 있음

#### 3. BoardService

```
public Page<BoardDTO> paging(Pageable pageable) {
        int page= pageable.getPageNumber() - 1;
        int pageLimit = 3; //한 페이지에 보여줄 글 갯수
        // page 위치에 있는 값은 0부터 시작
        Page<BoardEntity> boardEntities = boardRepository.findAll(PageRequest.of(page, pageLimit, Sort.by(Sort.Direction.DESC, "id")));
        // 아이디 순으로 내림 차순 정렬해서 페이지 불러오기

        Page<BoardDTO> boardDTOS = boardEntities.map(board -> new BoardDTO(board.getId(),
        board.getBoardWriter(), board.getBoardTitle(),
        board.getBoardHits(), board.getCreatedTime()));
        return boardDTOS;
    }
```

boardEntities에 게시판 엔티티를 페이징하여 가져옴  
불러옴 Entities들을 DTO로 변환 후 반환

> PageRequest.of
>
> ---
>
> 페이징 및 정렬 옵션 설정  
> 조회하려는 페이지 번호, 한 페이지 당 표시할 게시물수, 정렬 방식들을 보여줌

> Map : 각 엔티티를 순회하면서 변환 작업을 수행, 여기선 람다 표현식을 사용함

#### 4. 뷰 (paging.html, detail.html)

_게시물 목록_

```

<table>
    <tr>
        <th>id</th>
        <th>title</th>
        <th>writer</th>
        <th>date</th>
        <th>hits</th>
    </tr>
    <tr th:each="board: ${boardList}">
        <td th:text="${board.id}"></td>
        <td><a th:href="@{|/board/${board.id}|(page=${boardList.number + 1})}" th:text="${board.boardTitle}"></a></td>
        <td th:text="${board.boardWriter}"></td>
        <td th:text="*{#temporals.format(board.boardCreatedTime, 'yyyy-MM-dd HH:mm:ss')}"></td>
        <td th:text="${board.boardHits}"></td>
    </tr>
</table>
```

\_페이지 선택 바\_

```
<!-- 첫번째 페이지로 이동 -->
<!-- /board/paging?page=1 -->
<a th:href="@{/board/paging(page=1)}">First</a>
<!-- 이전 링크 활성화 비활성화 -->
<!-- boardList.getNumber() 사용자:2페이지 getNumber()=1 -->
<a th:href="${boardList.first} ? '#' : @{/board/paging(page=${boardList.number})}">prev</a>

<!-- 페이지 번호 링크(현재 페이지는 숫자만)
        for(int page=startPage; page<=endPage; page++)-->
<span th:each="page: ${#numbers.sequence(startPage, endPage)}">
<!-- 현재페이지는 링크 없이 숫자만 -->
    <span th:if="${page == boardList.number + 1}" th:text="${page}"></span>
    <!-- 현재페이지 번호가 아닌 다른 페이지번호에는 링크를 보여줌 -->
    <span th:unless="${page == boardList.number + 1}">
        <a th:href="@{/board/paging(page=${page})}" th:text="${page}"></a>
    </span>
</span>
<!-- 다음 링크 활성화 비활성화
    사용자: 2페이지, getNumber: 1, 3페이지-->
<a th:href="${boardList.last} ? '#' : @{/board/paging(page=${boardList.number + 2})}">next</a>
<!-- 마지막 페이지로 이동 -->
<a th:href="@{/board/paging(page=${boardList.totalPages})}">Last</a>

```

타임리프 문법 공부하면 좋을듯...

_detail.html_

```
const listReq = () => {
        console.log("목록 요청");
        location.href = "/board/paging?page="+[[${page}]];
    }
```

## 😊고찰

1주차에 crud는 다 구현이 된 상태이고 추가기능 구현이라, 구현의 순서도 익혔고, java에 익숙해지기도 해서 오류도 덜 나고, 강의 듣는 속도도 빨라졌음. 신속히 1주차 공부 내용을 정리하는 게 필요할 거 같음

-   오류 내용 : 모델 어트리뷰트할 때 파라미터 이름 값을 잘못넣어가지고 오류났음 500 오류 : 타임리프 구문 오류
-   이번 주 한줄평: 항상 오탈자는 잘 확인하자!
