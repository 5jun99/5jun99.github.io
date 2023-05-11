---
title: "화성 탐사 (파이썬)"
date: 2023-05-11 00:00:00 +0900
category: Algorithm
tags: []
original_url: https://velog.io/@9409velog/%ED%99%94%EC%84%B1-%ED%83%90%EC%82%AC
---

![](/assets/9409velog/화성-탐사-파이썬_image.png)

![](/assets/9409velog/화성-탐사-파이썬_image.png)

다은은 화성탐사를 진행하면서 에너지 소모량의 최소를 구하는 문제이다. n x n 의 2차원 공간이 주어지고 각 칸에는 칸에 갈 때에 에너지 소모량이 있다.  
보편적인 최단 거리 문제는 1차원 graph 가 주어지고 다익스트라 알고리즘을 이용하여 문제를 푸는 것이지만 해당 문제에서 주어진 것은 2차원 리스트이기 때문에 조금 응용하는 능력이 필요하다  
상하좌우가 모두 연결된 노드라고 생각하고 힙큐를 이용하여 다음 노드 저장하고 최단 거리를 비교하여 저장하는 방식으로 문제를 풀 수 있다.

```python
import heapq

INF = int(1e9)
n = int(input())
machine = [] #2차원 공간
distance = [[INF] \* (n) for \_ in range(n)] # 거리 리스트
#상 하 좌 우
dx = [0, 0, 1, -1]
dy = [1, -1, 0, 0]

for \_ in range(n):
machine.append(list(map(int, input().split()))) #입력

def dijkstra(start):
q = []
x, y = start
distance[x][y] = machine[x][y]
heapq.heappush(q, (machine[x][y], x, y)) #힙큐에 처음 값 저장
while q:
dist, x, y = heapq.heappop(q)
#이미 다녀왔으면 넘어가기
if dist > distance[x][y]:
continue

    # 4방향 조사
    for i in range(4):
        nx = x + dx[i]
        ny = y + dy[i]
        if nx < 0 or nx >= n or ny < 0 or ny >= n:
            continue
        cost = dist + machine[nx][ny]
        if cost < distance[nx][ny]: # 저장된 최단 거리보다 cost가 작으면
            distance[nx][ny] = cost # 바꿔주고
            heapq.heappush(q, (cost, nx, ny)) #힙큐에 저장
print(distance[n - 1][n - 1])
print(distance)

dijkstra((0, 0))
```
