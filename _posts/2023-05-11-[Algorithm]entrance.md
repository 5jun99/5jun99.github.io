---
title: "탑승구"
date: 2023-05-11 00:00:00 +0900
category: Algorithm
tags: []
original_url: https://velog.io/@9409velog/%ED%83%91%EC%8A%B9%EA%B5%AC
---

이코테 p. 395에 있는 탑승구 문제이다.  
처음에는 탑승구 마다의 리스트를 만들어서 비행기가 들어올 때마다  
해당 탑승구부터 마지막 탑승구까지의 리스트 값에 1을 더해주어 만약 탑승구의 리스트 값이 인덱스 값보다 커지면 넘치는 것으로 판단하고 코드를 작성하였다

# 합으로 확인을 하는 코드 작성

g = int(input())  
p = int(input())  
gate = [0] \* (g + 1)  
result = 0

for i in range(p):  
a = int(input())  
gate[a] += 1  
for j in range(a + 1, g + 1):  
gate[j] += 1  
if gate[a] > a:  
break  
else:  
result += 1

print(result)

# 노드의 루트가 0이면 그만두는 것으로 하기

해당 탑승구가 입력되면 그 탑승구의 루트를 확인하고 그 루트가 0이면 그만 두고 아니면 루트와 1 작은 수와 union 연산은 진행하는 코드를 작성하였다.

```python
def find\_parent(parent, x):
if parent[x] != x:
parent[x] = find\_parent(parent, parent[x])
return parent[x]

def union\_parent(parent, a, b):
a = find\_parent(parent, a)
b = find\_parent(parent, b)
if a < b:
parent[b] = a
else:
parent[a] = b

g = int(input())
p = int(input())
parent = [0] \* (g + 1)
count = 0
for i in range(g + 1):
parent[i] = i

for i in range(p):
gate = int(input())
gp = find\_parent(parent, gate)
if gp != 0:
union\_parent(parent, gp - 1, gp)
else:
break
count += 1

print(count)
```
