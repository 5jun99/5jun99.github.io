---
title: "Kubernetes 실습"
date: 2025-09-15
categories: [Infra]
tags: []
---

## 1. 실습 계획

새로운 개인 프로젝트를 시작하기에 앞서서 여러가지 툴을 사용해보고 싶어서 이번에 kubernetes 배포를 공부해보기로 했다.

kubernetes는 배포 모듈화 툴이었다. 여러 서비스를 올리고 같은 클러스터에 묶고 하나의 서비스 안에 여러 컨테이너를 올리면서 그 안에서 로드 밸런싱도 가능하고 서비스 간 통신도 용이하게 할 수 있다.

총 2가지 실습을 했다.

1. 서비스 하나 만들어서 kubernetes 파이프 라인 만들고 github actionis를 통해 서버에 배포하기
2. 여러 서비스를 만들어서 통신하는 구조 확인해보기

## 2. 개념 설명

kubernetes는 다음과 같은 구성 요소가 있다.

1. Pod: 실행되는 컨테이너 단위
2. Deployment: Pod가 몇 개 떠있고 서비스의 이름은 무엇이고 어떤 이미지를 실행할 것인지, 헬스체킹과 컨테이너 안에서 어떤 포트를 쓸 것인 지에 대한 전반적인 정보의 집합
3. Service: Pod는 내부 Cluster IP 를 사용하기에 재가동 시 주소가 변경된다. 이를 관리하기 위해서 클러스터 내부에서 다른 서비스들이 DNS로 접근 가능 시켜줌

kubernetes를 실행하기 위해선 다음과 같은 요소가 필요하다.

1. 소스 코드
2. 1을 기반으로 빌드한 이미지 (이번엔 Hub에 저장하는 식으로 진행)
3. Deployment와 Service를 정의한 yaml 파일

## 3. 실습

### 1

첫번째 실습은 구현된 프로젝트를 GitHub Actions를 통해 서버의 kubernetes 배포를 진행하는 것이다.

프로젝트 구현은 간단히 Flask 기반 어플리케이션으로 했다.

Dockerfile 까지 내용은 생략하겠다.

깃허브 액션의 파이프라인은 다음과 같다.

1. 도커 허브 로그인
2. 도커 빌드 및 푸시
3. 서버의 kubernetes 연결
4. manifest 적용 및 이미지 설정

다음 과정을 위해서는 깃허브 시크릿이 필요하다.

1. 도커 유저 이름
2. 도커 로그인을 위한 토큰
3. kube 연결을 위한 config base 문자열

```yml
name: Build and Deploy

on:
  push:
    branches: [main]

env:
  IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/sample-app:${{ github.sha }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push image
        uses: docker/build-push-action@v4
        with:
          push: true
          tags: ${{ env.IMAGE }}

      - name: Configure kubeconfig
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBE_CONFIG }}" | base64 --decode > $HOME/.kube/config
          chmod 600 $HOME/.kube/config

      - name: Apply Kubernetes manifests
        run: |
          kubectl apply -f k8s/deployment.yaml

      - name: Update deployment image
        run: |
          kubectl set image deployment/sample-app sample-app=${{ env.IMAGE }} --record
```

apply 를 통해서 설정을 적용시키고 이미지를 찾아서 pods 들의 이미지에 심어주는 것이다.

완료가 되었다면 다음은 kubernetes 파일 설정이다.
정의할 파일은 두 가지가 있다. 앞서 말한대로 Deployment와 Service다.

```yml
spec:
  containers:
    - name: sample-app
      image: 5jun99/sample-app:initial
      ports:
        - containerPort: 8080
      readinessProbe:
        httpGet:
          path: /
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
```

이 부분을 보자면, containerPort: 8080가 컨테이너의 안쪽에서 보는 포트고

```yml
ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

서비스의 하단을 보면 nodePort가 kubernetes proxy가 받는 포트 번호이다. 중간에 service에서 80 포트로 받고 8080 컨테이너로 주소가 연결되는 것이다.

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
        - name: sample-app
          image: 5jun99/sample-app:initial
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-svc
spec:
  type: NodePort # 간단히 노드포트로 노출 (테스트용)
  selector:
    app: sample-app
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080
```

### 2

삽질을 많이 하게 된 부분은 두번째 실습이었는데

서비스 A, B, C를 만들고 A에선 B에 요청, B에선 C에 요청을 하는 구조였다.

삽질한 곳은 다음과 같다.

#### 1) 헬스체크(`/`)가 서비스 체인 의존 때문에 타임아웃

**문제**

- A의 `/`가 B를 호출하고, B의 `/`가 C를 호출하는 구조에서 `/`를 `readinessProbe`로 쓰면 A는 B가 준비되어야 Ready가 된다.
- B 또는 C가 조금만 늦어도 A의 probe가 반복 실패 → A가 `NotReady` 상태로 남음.

**원인**

- `readinessProbe`는 "이 Pod가 트래픽 받을 준비가 되었나"만 검사해야 하는데, 다른 서비스 의존 로직이 들어가서 실패.
- 특히 Flask dev 서버처럼 응답성이 약하면 probe 요청이 timeout 되기 쉽다.

**해결 방법**

1. 헬스 전용 엔드포인트 추가

```python
@app.route("/health")
def health():
      return "ok", 200
```

2. Probe 설정을 /health로 변경

```yml
readinessProbe:
httpGet:
  path: /health
  port: 8080
initialDelaySeconds: 15
timeoutSeconds: 5
periodSeconds: 10
failureThreshold: 6
```

3. 서비스 간 호출 로직은 / 등 비즈니스 경로에서만 사용.

#### 2) Deployment와 Service를 한 파일에 넣었더니 apply 문제

문제
• Deployment와 Service를 같은 YAML에 썼는데 들여쓰기·구분자 문제 때문에 일부만 반영되거나, immutable 필드(port 등) 수정이 안됨.

원인
• kubectl apply는 immutable 필드 수정 불가.
• --- 구분자 없이 리소스를 섞으면 적용 시 꼬임

해결 방법

1. 파일 분리 → deployment.yaml, service.yaml 관리.

2. immutable 필드 바꿀 땐 Service 삭제 후 재생성:

```shell
kubectl delete svc a-service
kubectl apply -f service.yaml
```

3. 적용 순서: 보통 kubectl apply -f deployment.yaml → kubectl apply -f service.yaml.

#### 3) 이미지 이름/태그 불일치로 배포 실패

문제
• CI에서 빌드한 태그와 kube manifest 태그가 다르면 Pod가 예전 이미지로 뜨거나 pull error 발생.

원인
• image: latest 같은 고정 태그 사용 시 추적 불가.
• CI/CD에서 태그 관리가 안되면 이전 빌드와 충돌.

해결 방법

1. 고유 태그 사용 (예: GitHub SHA)

```yml
image: myuser/a-service:${GITHUB_SHA}
```

2. 배포 시 CI에서 직접 업데이트

```
IMAGE=myuser/a-service:${GITHUB_SHA}
kubectl set image deployment/a-service a-service=$IMAGE --record
kubectl rollout status deployment/a-service
```
