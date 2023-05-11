---
layout: post
title: "GDSC 게시판 프로젝트 1주차 (CRUD)"
date: 2023-11-29 00:00:00 +0900
category: Memoir
tags: []
original_url: https://velog.io/@9409velog/GDSC-%EA%B2%8C%EC%8B%9C%ED%8C%90-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-1%EC%A3%BC%EC%B0%A8-CRUD
---

## 📖강의

---

[코딩레시피 CRUD 게시판](https://www.youtube.com/watch?v=Vanl4wcAPW0&list=PLV9zd3otBRt7jmXvwCkmvJ8dH5tR_20c0&index=1)

## 🖥️개발환경

---

> Intellij IDEA Community  
> mysql 8.0.34  
> Spring Data JPA  
> JDK 11  
> SpringBoot 2.6.13

## ✍️정리

### ❓CRUD란?

> create, research, update, delete 의 약자로 기본적인 게시판 기능을 말하는 것

### ❗목표

-   게시물 생성, 조회, 갱신, 삭제
-   기본적인 springboot 구조 파악

### 👨‍💻과정

---

#### 0. 기초 지식

-   Service : 특정 기능을 로직을 이용하여서 구현하는 부분
-   Entity: 레코드들을 묶은 테이블 개체
-   DTO: 소프트웨어 응용 프로그램의 프로세스 간에 데이터를 전송하는 데 사용되는 객체
-   Controller: MCV 아키텍쳐에서 모델과 뷰간의 매개체
-   Repository: 기본적인 CRUD 기능 지원

#### 1. 기본적인 개발 순서

1. templete(html)을 작성, href= "주소" 버튼 생성
2. Controller에서 해당 주소를 type에 맏게 mapping 받아서 service 메서드 호출
3. Service에서 각 기능 구현  
   3.1. 그 과정에서 Entity, DTO, Repository 사용
4. Controller가 service method의 반환값을 model attribute를 이용하여 뷰로 전송
5. 타임리프 구문을 이용해서 받은 데이터를 뷰에 표시

-   저장 순서: 뷰 -> DTO -> Entity -> Repository

#### 2. boardapplication

```
@SpringBootApplication
public class BoardApplication {

	public static void main(String[] args) {
		SpringApplication.run(BoardApplication.class, args);
	}

}

```

스프링 부트를 초기화시키고, 스프링 부트 어플리케이션을 선정함.

#### 3. Homecontroller

```
@Controller

public class HomeController {
    @GetMapping("/")
    public String index() {
        return "index";
    }
}
```

<http://localhost:8080/> 경로에 대한 메핑을 받아서 index 실행

#### 4. boardcontroller

```
@Controller
@RequiredArgsConstructor
@RequestMapping("/board")
public class BoardController {
    private final BoardService boardService;

    @GetMapping("/save") //작성 화면
    public String saveForm(){
        return "save";
    }

    @PostMapping("/save") //게시글 저장
    public String save(@ModelAttribute BoardDTO boardDTO){
        boardService.save(boardDTO);
        return "index";
    }

    @GetMapping("/") //모든 게시글 목록
    public String findAll(Model model){
        List<BoardDTO> boardDTOList = boardService.findAll();
        model.addAttribute("boardList",boardDTOList);
        return "list";
    }

    @GetMapping("/{id}") // 상세조회
    public String findById(@PathVariable Long id, Model model){
        boardService.updateHits(id); //조회수 +1
        BoardDTO boardDTO = boardService.findById(id); //실제 찾아오기
        model.addAttribute("board",boardDTO);
        return "detail";
    }

    @GetMapping("/update/{id}") //수정된 부분 수정후 화면 출력
    public String updateForm(@PathVariable Long id, Model model){
        BoardDTO boardDTO = boardService.findById(id);
        model.addAttribute("boardUpdate",boardDTO);
        return "update";
    }

    @PostMapping("/update") //게시물 수정
    public String update(@ModelAttribute BoardDTO boardDTO, Model model){
        BoardDTO board =  boardService.update(boardDTO);
        model.addAttribute("board",board);
        return "detail"; //수정이 완료된 상세 페이지
    }

    @GetMapping("/delete/{id}") //게시글 삭제
    public String delete(@PathVariable Long id){
        boardService.delete(id);
        return "redirect:/board/";
    }
}

```

requestmapping("/board")을 이용해서 각 url, 다른 type의 매핑들 경우에서의 메서드들을 호출

-   @ModelAttribute : HTML 폼에서 사용자가 입력한 데이터를 받아와서 모델에 추가할 때 활용
-   @PathVariable: URI에 있는 {} 부분 안에 있는 변수를 받아옴

#### 5. Service

```
@Service
@RequiredArgsConstructor
public class BoardService {
    private final BoardRepository boardRepository;
    public void save(BoardDTO boardDTO) {
        BoardEntity boardEntity = BoardEntity.toSaveEntity(boardDTO);
        boardRepository.save(boardEntity);
    }

    public List<BoardDTO> findAll() {
    // 레포지토리에서 entity 가져오기
        List<BoardEntity> boardEntityList = boardRepository.findAll();
        List<BoardDTO> boardDTOList = new ArrayList<>();
        for(BoardEntity boardEntity : boardEntityList){
            boardDTOList.add(BoardDTO.toBoardDTO(boardEntity));
        }
        return boardDTOList;
    }

    @Transactional
    public void updateHits(Long id) {
        boardRepository.updateHits(id);
    }

    public BoardDTO findById(Long id) {
        Optional<BoardEntity> optionalBoardEntity = boardRepository.findById(id);
        if (optionalBoardEntity.isPresent()){
            BoardEntity boardEntity = optionalBoardEntity.get();
            return BoardDTO.toBoardDTO(boardEntity);
        }else{
            return null;
        }
    }

    public BoardDTO update(BoardDTO boardDTO) { //update용 엔티티
        BoardEntity boardEntity = BoardEntity.toUpdateEntity(boardDTO);
        boardRepository.save(boardEntity);
        return findById(boardDTO.getId());
    }

    public void delete(Long id) {
        boardRepository.deleteById(id);
    }
}
```

각종 기능을 구현하는 부분  
findall 할 때는 레포지토리에서 엔티티를 받아와서 Dto로 바꾸고 dto 바환  
save는 반대로 dto를 entity로 바꾼 뒤 레포지토리에 저장  
상세조회는 optional 개체로 entity를 받아와서, 해당 dto를 반환

#### 6. DTO

```
@Getter
@Setter //get set method 자동으로 해줌
@ToString
@NoArgsConstructor	//기본 생성자
@AllArgsConstructor	//모든 필드 매개변수 생성자
public class BoardDTO {
    private Long id;
    private String boardWriter;
    private String boardPass;
    private String boardTitle;
    private String boardContents;
    private int boardHits; //조회수
    private LocalDateTime boardCreatedTime; //작성 시간
    private LocalDateTime boardUpdatedTime; //수정 시간

    public static BoardDTO toBoardDTO(BoardEntity boardEntity) {
        BoardDTO boardDTO = new BoardDTO();
        boardDTO.setId(boardEntity.getId());
        boardDTO.setBoardWriter(boardEntity.getBoardWriter());
        boardDTO.setBoardPass(boardEntity.getBoardPass());
        boardDTO.setBoardTitle(boardEntity.getBoardTitle());
        boardDTO.setBoardContents(boardEntity.getBoardContents());
        boardDTO.setBoardHits(boardEntity.getBoardHits());
        boardDTO.setBoardCreatedTime(boardEntity.getCreatedTime());
        boardDTO.setBoardUpdatedTime(boardEntity.getUpdatedTime());
        return boardDTO;
    }
}
```

entity 개체의 get 해 와서, dto 필드에 set 해줌

-   @Getter,@Setter : getter, setter 메서드 자동으로 만들어줌

모델 어트리뷰트로 받아올 때 dto로 받아오는데, 이때 뷰의 필드 네임과 dto의 필드 네임이 같아야한다.  
ex) BoardWriter은 save html에서 input의 네임태그도 BoardWriterd임

#### 7. Entity

```
@Entity
@Getter
@Setter
@Table(name = "board_table")
public class BoardEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 20, nullable = false)
    private String boardWriter;

    @Column // 기본 길이는 255
    private String boardPass;

    @Column
    private String boardTitle;

    @Column(length = 500)
    private String boardContents;

    @Column
    private int boardHits;

    public static BoardEntity toSaveEntity(BoardDTO boardDTO){
        BoardEntity boardEntity = new BoardEntity();
        boardEntity.setBoardWriter(boardDTO.getBoardPass());
        boardEntity.setBoardContents(boardDTO.getBoardContents());
        boardEntity.setBoardTitle(boardDTO.getBoardTitle());
        boardEntity.setBoardPass(boardDTO.getBoardPass());
        boardEntity.setBoardHits(0); //초기 조회수는 0으로 시작
        return boardEntity;
    }

    public static BoardEntity toUpdateEntity(BoardDTO boardDTO){
        BoardEntity boardEntity = new BoardEntity();
        boardEntity.setId(boardDTO.getId());
        boardEntity.setBoardWriter(boardDTO.getBoardPass());
        boardEntity.setBoardContents(boardDTO.getBoardContents());
        boardEntity.setBoardTitle(boardDTO.getBoardTitle());
        boardEntity.setBoardPass(boardDTO.getBoardPass());
        boardEntity.setBoardHits(boardDTO.getBoardHits()); //조회수는 기존 조회수에서 이어져야 함
        return boardEntity;
    }
}
```

Jpa가 제공하는 어노테이션을 이용해서 @Table, @Column 등의 어노테이션을 객체와 데이터베이스간의 매핑을 자동으로 처리해줌

@ID는 기본 키이다. join 참조를 할 때 주로 사용된다. @GeneratedValue 애너테이션은 주요 키의 값을 자동으로 생성한다.  
strategy = GenerationType.IDENTITY는 데이터베이스의 identity 컬럼을 사용하여 자동으로 값을 생성하도록 지정함.

#### 8. Repository

```
 public interface BoardRepository extends JpaRepository<BoardEntity, Long> {
        @Modifying
        @Query(value = "update BoardEntity b set b.boardHits=b.boardHits+1 where b.id=:id")
        void updateHits(@Param("id") Long id);
    }
```

JpaRepository에서 제공하는 기본적인 CRUD 작업 외에도 사용자 정의 쿼리를 정의하여 데이터베이스와 상호 작용한다. updateHits 메서드는 게시글의 조회수를 증가시키는 간단한 사용자 정의 쿼리를 실행하는데 사용된다.

-   @Modifying : 메서드가 데이터베이스 변경 쿼리임을 나타낸다
-   @Query: 사용자 정의 쿼리를 정의할 때 사용된다. 여기서는 BoardEntity 엔티티의 boardHits 필드를 1 증가시키는 업데이트 쿼리를 사용한다.

## 😊고찰

5주차에 1주차 얘기를 쓰는 상황이 생기긴했지만 처음에 뭐 했었는지 차근차근 다시 보는 느낌이어서 오히려 좋았던 거 같다. 회원 서비스 기능도 넣어보고 싶고, 대댓글 기능도 넣어봤으면 좋겠다. 게시물 검색기능도 목표다. 타임리프 템플릿 공부도 좀 하려고 한다.

-   이번 주 한줄평: 꼭 더 개발해보자
