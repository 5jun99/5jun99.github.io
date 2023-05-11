---
layout: post
title: "GDSC 게시판 프로젝트 4주차 (댓글 작성)"
date: 2023-11-21 00:00:00 +0900
category: Memoir
tags: []
original_url: https://velog.io/@9409velog/GDSC-%EA%B2%8C%EC%8B%9C%ED%8C%90-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-4%EC%A3%BC%EC%B0%A8-%EB%8C%93%EA%B8%80-%EC%9E%91%EC%84%B1
---

## 📖강의

---

[코딩레시피 CRUD 게시판](https://www.youtube.com/watch?v=Vanl4wcAPW0&list=PLV9zd3otBRt7jmXvwCkmvJ8dH5tR_20c0&index=21)

## 🖥️개발환경

---

> Intellij IDEA Community  
> mysql 8.0.34  
> Spring Data JPA  
> JDK 11  
> SpringBoot 2.6.13

## ✍️정리

### ❓댓글 처리

> 게시물에 댓글을 다는 거

### ❗목표

-   댓글 작성 후 서버에 저장
-   작성한 댓글 다시 세부 페이지에 출력

### 👨‍💻과정

---

#### 순서

-   댓글 저장

1. detail html에서 댓글 작성 (post)
2. comment controller 에서 dto를 service로 넘김
3. comment service의 save method: boardRepository 에서 불러온 boardentity, CommentDto를 comment_table에 저장

-   댓글 출력

1. comment controller에서 save할 때에 저장에 성공하면 board_table의 id로 commentservice의 findall method 호출
2. commentservice의 findall method에서 해당 boardid를 가진board_table에 있는 entity를 불러옴 그 entity를 이용하여 jpa query로 commententitylist를 받아옴
3. commentDTO로 반환한 후, 모인 commentDTOList를 detail html에 반환

#### 1. detail.html

```
<!--댓글 작성 부분-->
<div id="comment-write">
    <input type = "text" id="commentWriter" placeholder="작성자">
    <input type = "text" id="commentContents" placeholder="내용">
    <button id="comment-write-btn" onclick="commentWrite()">댓글 작성</button>
```

작성자, 내용을 작성 받는 부분

```
const commentWrite = () => {
        const writer = document.getElementById("commentWriter").value;
        const contents = document.getElementById("commentContents").value;
        console.log("작성자: ", writer);
        console.log("내용: ", contents);
        const id = [[${board.id}]];
        $.ajax({
           // 요청방식: post, 요청주소: /comment/save, 요청데이터: 작성자, 작성내용, 게시글번호
           type: "post",
           url: "/comment/save",
           data: {
               "commentWriter": writer,
               "commentContents": contents,
               "boardId": id
           },
           success: function (res) {
               console.log("요청성공", res);
               let output = "<table>";
               output += "<tr><th>댓글번호</th>";
               output += "<th>작성자</th>";
               output += "<th>내용</th>";
               output += "<th>작성시간</th></tr>";
               for (let i in res) {
                   output += "<tr>";
                   output += "<td>" + res[i].id + "</td>";
                   output += "<td>" + res[i].commentWriter + "</td>";
                   output += "<td>" + res[i].commentContents + "</td>";
                   output += "<td>" + res[i].commentCreatedTime + "</td>";
                   output += "</tr>";
               }
               output += "</table>";
               document.getElementById('comment-list').innerHTML = output;
               document.getElementById('commentWriter').value = '';
               document.getElementById('commentContents').value = '';
           },
           error: function (err) {
               console.log("요청실패", err);
           }
        });

    }
```

Element에서 각 데이터들을 받아온 뒤 ajax를 이용하여 post request, 후 다시 받아서 서버의 응답에 따라 succes function error function 실행

```
<div id="comment-list">
    <table>
        <tr>
            <th>댓글번호</th>
            <th>작성자</th>
            <th>내용</th>
            <th>작성시간</th>
        </tr>
        <tr th:each="comment: ${commentList}">
            <td th:text="${comment.id}"></td>
            <td th:text="${comment.commentWriter}"></td>
            <td th:text="${comment.commentContents}"></td>
            <td th:text="${comment.commentCreatedTime}"></td>
        </tr>
    </table>
</div>
```

success 함수에서 생성한 테이블을 html 엘리먼트들로 출력함

2. boardController

```
@GetMapping("/{id}")
    public String findById(@PathVariable Long id, Model model, @PageableDefault(page = 1) Pageable pageable) {
        boardService.updateHits(id);
        BoardDTO boardDTO = boardService.findByid(id);
        List<CommentDTO> commentDTOList = commentService.findAll(id);
        model.addAttribute("commentList", commentDTOList);
```

게시물 조회했을 때도 commentservice에서 불러와서 model로 넘길 수 있게 해줌

3. commentController

```
@RequestMapping("/comment")
public class CommentController {
    private final CommentService commentService;

    @PostMapping("/save")
    public ResponseEntity save(@ModelAttribute CommentDTO commentDTO) {
        //System.out.println("commentDTO = " + commentDTO);
        //저장된 comment_table의 id 반환
        Long saveResult = commentService.save(commentDTO);
        if (saveResult != null) {
            // 작성 성공하면 댓글목록을 가져와서 리턴
//            댓글 목록 ==> 해당 게시글의 댓글 전체 ==> 가져올때 해당 게시글을 기준으로 가져와야함
            List<CommentDTO> commentDTOList = commentService.findAll(commentDTO.getBoardId()); //아이디 기준으로 찾기
            return new ResponseEntity<>(commentDTOList, HttpStatus.OK); // ok 사인 도 같이 보내줌
        }
        else {
            return new ResponseEntity<>("해당 게시물이 존재하지 않습니다", HttpStatus.NOT_FOUND); // ok 사인 도 같이 보내줌
        }
    }
}
```

Service의 save메서드 호출  
작성 성공하면 commentDTOList 받아서 반환

4. commentService

```
@RequiredArgsConstructor
public class CommentService {
    private final CommentRepository commentRepository;
    private final BoardRepository boardRepository;

    public Long save(CommentDTO commentDTO) {
//        부모엔티티 먼저 조회 조회를 못했을 수도 있으니까 optional 클래스로 선언한거임

        Optional<BoardEntity> optionalBoardEntity = boardRepository.findById(commentDTO.getBoardId());
        if (optionalBoardEntity.isPresent()) {
            BoardEntity boardEntity = optionalBoardEntity.get();
            CommentEntity commentEntity = CommentEntity.toSaveEntity(commentDTO, boardEntity);
            return commentRepository.save(commentEntity).getId(); //저장된 entity id 반환
        }
        else {
            return null;
        }
    }

    public List<CommentDTO> findAll(Long boardId) {
        // select * from comment_table where board_id=? order by id desc;
        BoardEntity boardEntity = boardRepository.findById(boardId).get();   //board_table에서 entity 받아옴
        List<CommentEntity> commentEntityList = commentRepository.findAllByBoardEntityOrderByIdDesc(boardEntity); // boardendtity에서 comment list 받아옴
        List<CommentDTO> commentDTOList = new ArrayList<>();
        for (CommentEntity commentEntity: commentEntityList) {
            CommentDTO commentDTO = CommentDTO.toCommentDTO(commentEntity, boardId);
            commentDTOList.add(commentDTO);
        }
        return commentDTOList;
    }
}
```

-   save : boardEntity를 감싸고 있는 Optional 클래서 선언, commentDTO의 참조테이블 아이디를 이용해서 boardtable 찾음  
    DTO를 entity class로, 성공 여부 반환
-   findall : 거의 save의 역순임

> Optional
>
> ---
>
> 자바의 java.util 패키지에 포함된 클래스로, 값이 있을 수도 있고 없을 수도 있는 상황을 다루기 위한 컨테이너임 ispresent 메서드 많이 씀

## 😊고찰

확실히 MVC 패턴을 이해하기 시작한 거 같음. service, controller, repository, dto, entity 의 개념도 체화되기 시작했음. 다만 아쉬운 점이 있다면

-   자바의 문법 키워드들의 정의, 객체의 개념들을 까먹은 채 만듬 다시 공부해야할 듯
-   jpa 많이 안 쓴 거 같아서 더 알아봐야겠음
-   기능 하나하나 구현하는데에 집중하다보니까 흐름을 보는 거에 시간을 많이 쓰는 듯 ➡️ 무작정 따라치는 건 안 될 듯 조금이라도 내방식으로 쳐보던가 안보고 치던가 해보는 습관이 중요할 듯

---

-   이번주 한줄평 : 1주차 정리 빨리 올리자...

> 새롭게 찾아본 것
>
> ---
>
> -   jquery?  
>     자바스크립트 라이브러리. 자주 사용되는 작업을 쉽게 처리할 수 있도록 도와줌, 이벤트 처리, 애니메이션 등
> -   jQuery CDN?  
>     jquery 라이브러리를 제공하는 주소라고 생각하면 됨. cdn은 전세계의 다양한 서버 컨텐츠를 분산하여 제공해주는 시스템임
