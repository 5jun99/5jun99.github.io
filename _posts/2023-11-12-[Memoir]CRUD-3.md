---
layout: post
title: "GDSC 게시판 프로젝트 3주차 (파일 첨부)"
date: 2023-11-12 00:00:00 +0900
category: Memoir
tags: []
original_url: https://velog.io/@9409velog/GDSC-%EA%B2%8C%EC%8B%9C%ED%8C%90-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-3%EC%A3%BC%EC%B0%A8-%ED%8C%8C%EC%9D%BC-%EC%B2%A8%EB%B6%80
---

## 📖강의

---

[코딩레시피 CRUD 게시판](https://www.youtube.com/watch?v=Vanl4wcAPW0&list=PLV9zd3otBRt7jmXvwCkmvJ8dH5tR_20c0&index=14)

## 🖥️개발환경

---

> Intellij IDEA Community  
> mysql 8.0.34  
> Spring Data JPA  
> JDK 11  
> SpringBoot 2.6.13

## ✍️정리

### ❓파일 첨부

> 게시물에 글 이외에 이미지 같은 파일을 첨부할 수 있는 기능

### ❗목표

-   파일 첨부해서 저장하기
-   파일 첨부된 게시물 조회하기
-   다중 파일 첨부 기능

### 👨‍💻과정

---

#### 0. 저장, 조회 순서

-   저장

1. save.html에서 파일 input 함
2. postmapping save: BoardController 에서 dto 받아서 service의 save 메서드 호출
3. 파일 있을 때를 구분해서 board table 과 board file table 나누어서 repository에 저장
    - board table : 기존 정보 + 파일 여부
    - board file table : boardtable_id, 파일 이름, 서퍼 파일 이름
    - 둘이 조인함

-   조회

1. detail.html 에서 파일 불러옴
2. BoardController id로 게시물 찾음
3. boardservice에서 entity 받아와서 Dto의 toBoardDTO 메서드 호출
4. 파일 있을 때 없을 때 나누어서 DTO로 변환

#### 1. save.html

```
<form action="/board/save" method="post" enctype="multipart/form-data">

    ...

    file: <input type="file" name="boardFile" multiple> <br>
    <input type="submit" value="글작성">
```

-   input type 을 file 로 지정한 엘리먼트 작성
-   boardFile 이라는 이름으로 파일의 속성 주고 받을 수 있음
-   multiple : 복수 첨부 기능

#### 2. BoardDTO

```
private List<MultipartFile> boardFile; // 파일 속성 값 받아오기 위함 이름, 파일 속성 등 여러 정보를 가지고 있음
private List<String> originalFileName;        //원본 파일 이름
private List<String> storedFileName;          //서버 저장용 파일 이름
private int fileAttached;               //파일 첨부 여부(첨부1, 미첨부 0)

```

파일 속성을 담은 필드 선언

#### 3. BoardFileEntity

```
public class BoardFileEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private  Long id;

    @Column
    private String originalFileName;

    @Column
    private String storedFileName;

    @ManyToOne(fetch = FetchType.LAZY) //
    @JoinColumn(name = "board_id") //joincol
    private BoardEntity boardEntity;


    public static BoardFileEntity toBoardFileEntity(BoardEntity boardEntity, String originalFileName, String storedFileName){
        BoardFileEntity boardFileEntity = new BoardFileEntity();
        boardFileEntity.setOriginalFileName(originalFileName);
        boardFileEntity.setStoredFileName(storedFileName);
        boardFileEntity.setBoardEntity(boardEntity);
        return boardFileEntity;
    }
}
```

파일의 정보를 담는 테이블(board_file_table)을 따로 설정, board_table의 id col값을 참조함  
기존 파일 이름과 저장된 서버 파일 이름이 속성에 있음

> originalFileName vs storedFileName
>
> ---
>
> 사용자의 파일 이름에 서버 시간이나 부수적인 것을 추가하여 구분을 하는 복적에 있음

#### 4. BoardService

```

 public void save(BoardDTO boardDTO) throws IOException {
        // 파일 첨부 여부에 따라 로직을 분리
        if (boardDTO.getBoardFile().isEmpty()) {
            BoardEntity boardEntity = BoardEntity.toSaveEntity(boardDTO); // 받아온 겂을 entitiy 객체에 저장
            boardRepository.save(boardEntity); //jpa 상속 메서드
        }
        else {
                //파일 첨부 있을때
            BoardEntity boardEntity = BoardEntity.toSaveFileEntity(boardDTO);   //파일 엔티티를 저장하는 메서드 새로 만들어서 entity에 저장
            Long savedId = boardRepository.save(boardEntity).getId();           //이 때 아이디를 사용함
            BoardEntity board = boardRepository.findById(savedId).get();    //save id 로 아이디를 다시 조회
            for (MultipartFile boardFile : boardDTO.getBoardFile()) {
                // 보드 파일 속상들을 받아옴
                String originalFilename = boardFile.getOriginalFilename();  //보드 파일에 있는 이름을 가져옴
                String storedFileName = System.currentTimeMillis() + "_" + originalFilename; //밀리초 단위 값임
                String savePath = "C:/springboot_img/" + storedFileName; // 저장 위치
                boardFile.transferTo(new File(savePath)); // 해당 경로에 파일 저장 //5번 까지임
                BoardFileEntity boardFileEntity = BoardFileEntity.toBoardFileEntity(board, originalFilename, storedFileName); // boardFileEntity에 다시 저장
                boardFileRepository.save(boardFileEntity);
            }
        }
```

파일 있을 때 없을 때를 DTO의 fileattached 필드 값으로 확인  
파일 있으면, 먼저 board_table에 저장  
저장한 table의 id 값으로 entity 다시 받아와서  
파일 이름 설정하고, 경로 설정하여서 board_file_table에 저장

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

#### 조회

-   BoardDTO

```
 if (boardEntity.getFileAttached() == 0) {
                        boardDTO.setFileAttached(boardEntity.getFileAttached());
                } else {
                        List<String> originalFileNameList = new ArrayList<>();        //원본 파일 이름
                        List<String> storedFileNameList = new ArrayList<>();
                        boardDTO.setFileAttached(boardEntity.getFileAttached());
                        // 파일 이름 가져오기
                        // filname들은 boardfileEntity에 들어있음 근데 가져온거는 endtitiy 에서 가져온거임
                        // 서로 다른 테이블에 있는 값을 가져오려면 join 을 써야함
                        for (BoardFileEntity boardFileEntity: boardEntity.getBoardFileEntityList()) {
                                originalFileNameList.add(boardFileEntity.getOriginalFileName()); //자식 테이블 참조
                                storedFileNameList.add(boardFileEntity.getStoredFileName());    //자식 테이블 참조
                        }
                        boardDTO.setOriginalFileName(originalFileNameList);
                        boardDTO.setStoredFileName(storedFileNameList);

```

파일 있을 때 반복문으로 list에 파일 이름들을 추가하고, boardDTO에 넣는다.

-   detail.html

```
<tr th:if="${board.fileAttached == 1}">
<!--        파일이 있을 때만 이미지 보이게-->
        <th>image</th>
        <td th:each="fileName: ${board.storedFileName}"><img th:src="@{|/upload/${fileName}|}" alt = ""></td>
    </tr>
```

파일이 있으면 똑같이 반복문을 돌리면서 해당 파일을 보여줌

## 😊고찰

1,2 주차를 하면서 controller와 dto entity service의 역할과 관계를 파악했다고 생각했는데, 막상 파일이 들어와서 table끼리 연결하고, 새로운 entity, repository 가 생기면서 헷갈리는 부분이 있었음. 주기적으로 한번씩 보면서 복습할 필요가 있을듯

-   오류 내용 : x
-   이번 주 한줄평: 점점 게시판 같아진다!
