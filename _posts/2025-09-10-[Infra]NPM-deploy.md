---
title: "Nginx Proxy Manager와 Jenkins를 활용한 롤링 배포 구축기"
date: 2025-09-10
categories: [Infra]
tags: []
---

## 1. 문제 상황: 무중단 배포를 어떻게 할 것인가?

Spring Boot 서버를 운영하면서, “서비스 중단 없이 새 버전을 배포”하고 싶다는 필요가 생겼다.
처음에는 **블루-그린 배포(Blue-Green Deployment)** 방식을 고려했다.

- 블루-그린의 원리: 두 개의 완전히 독립적인 환경(blue, green)을 준비해놓고, 새로운 버전을 green에 올린 뒤 트래픽을 전환한다.
- 장점: 전환 시점이 명확하고 빠르다.
- 단점: 두 세트를 동시에 유지해야 하므로 인프라 자원 부담이 크다.

Nginx Proxy Manager(NPM)로 블루-그린을 구현하려면 결국:

- NGINX API를 통해서 conf를 바꿔주거나,
- Jenkins 파이프라인에서 `sed` 명령어로 직접 프록시 conf를 교체해야 한다.

그런데 연구실 서버 환경에서는 conf 파일 직접 수정이 까다롭고, GUI를 벗어나면 관리 복잡도가 올라간다.
그래서 블루-그린 대신 **롤링 배포(Rolling Deployment)** 방식을 채택했다.

---

## 2. 해결 방법: 롤링 배포 설계

### (1) Docker Compose 구조

두 개의 동일한 서비스를 app1, app2로 정의해 각각 다른 포트를 사용하도록 했다.

```yaml
services:
  app1:
    image: asan-dp-api
    ports:
      - "23390:8080"
  app2:
    image: asan-dp-api
    ports:
      - "23391:8080"
```

### (2) Nginx Proxy Manager upstream 설정

NPM은 GUI만으로는 라운드로빈 설정이 안 된다.
이를 해결하기 위해 Advanced 설정 + custom conf를 조합했다.

Advanced 탭에 location 추가

NPM UI에서 Proxy Host → Advanced 설정에 다음 블록을 삽입한다.

```
location /api {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Scheme $scheme;
    proxy_set_header X-Forwarded-Proto  $scheme;
    proxy_set_header X-Forwarded-For    $remote_addr;
    proxy_set_header X-Real-IP          $remote_addr;
    proxy_pass       http://dp_annotation;

    # Force SSL
    include conf.d/include/force-ssl.conf;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_http_version 1.1;
}
```

#### custom conf에 upstream 정의

컨테이너 내부 /data/nginx/custom/http*top.conf 파일을 만들고 upstream 블록을 추가했다.
파일 이름에 http*가 들어가면 NPM이 자동으로 include하기 때문에 http_top.conf로 이름을 지었다.

```
upstream dp_annotation {
    server <SERVER_IP>:23390 max_fails=3 fail_timeout=10s;
    server <SERVER_IP>:23391 max_fails=3 fail_timeout=10s;
}
```

이렇게 하면 /api 요청이 자동으로 두 서버(app1, app2)로 라운드로빈 방식으로 분산된다.

### (3) Jenkins 파이프라인에서 롤링 배포

- 새 코드를 빌드해 Docker 이미지 태깅(`asan-dp-api:${BUILD_NUMBER}`)
- `app1`을 내리고 새 이미지로 교체 → `/api/health` 응답 확인
- 정상 동작 시 `app2`도 같은 절차 실행
- 실패하면 `.last_successful_tag` 기준으로 롤백

이렇게 해서 한쪽 컨테이너를 유지하면서 다른 쪽을 갱신해, 서비스 중단을 최소화했다.

---

## 3. 블루-그린 vs 롤링

| 구분          | 블루-그린 배포                       | 롤링 배포                           |
| ------------- | ------------------------------------ | ----------------------------------- |
| **원리**      | 두 세트를 준비해 한 번에 트래픽 전환 | 기존 인스턴스를 점진적으로 교체     |
| **장점**      | 빠른 전환, 롤백 용이                 | 인프라 절약, 점진적 업데이트        |
| **단점**      | 자원 두 배 필요, conf 교체 필요      | 교체 중 일부 인스턴스는 구버전 유지 |
| **적합 상황** | 대규모 서비스, 확실한 롤백 필요      | 소규모 서버, 리소스 제한 환경       |

연구실처럼 **서버 리소스가 제한적이고, conf 교체 관리가 부담스러운 환경**에서는 롤링 배포가 더 현실적이다.

---

## 4. 주의해야 할 점

1. **포트 충돌**
   기존 컨테이너를 내리기 전에 새 컨테이너를 올리면 “port already allocated” 에러가 발생한다.
   → Jenkins에서 반드시 `docker-compose rm -sf app1` 후 `up` 해야 한다.

2. **헬스체크 필수**
   단순히 컨테이너가 실행됐다고 끝이 아니라
   `/api/health`와 같은 헬스체크 API가 정상 응답해야만 다음 단계로 넘어가야 한다.

3. **롤백 전략**
   항상 `.last_successful_tag`와 같은 “마지막 정상 빌드 태그”를 저장해 두어야 한다.
   새 배포가 실패하면 즉시 이 태그로 컨테이너를 복구할 수 있어야 한다.

4. **NPM과 upstream 관리**
   NPM UI만으로는 라운드로빈이 불가능하다.
   반드시 custom conf를 써서 upstream을 선언해야 한다.
