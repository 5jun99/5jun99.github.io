---
layout: post
title: "정렬된 배열에서 특정 수의 개수 구하기"
date: 2023-11-20 00:00:00 +0900
category: Algorithm
tags: []
original_url: https://velog.io/@9409velog/%EC%A0%95%EB%A0%AC%EB%90%9C-%EB%B0%B0%EC%97%B4%EC%97%90%EC%84%9C-%ED%8A%B9%EC%A0%95-%EC%88%98%EC%9D%98-%EA%B0%9C%EC%88%98-%EA%B5%AC%ED%95%98%EA%B8%B0
---

## 문제

---

n개의 원소를 포함하고 있는 수열이 오름차순 으로 정렬되어 있습니다. 이때 이 수열에서 x가 등장하는 횟수를 계산하세요. 예를 들어 수열 [1, 1, 2, 2, 2, 2, 3]이 있을 때 x = 2라면, 현재 수열에서 값이 2인 원소가 4개 이므로 4를 출력합니다.  
단, 이문제는 시간 복잡도 O(logN)으로 알고리즘을 설계하지 않으면 '시간 초과' 판정을 받습니다.

#### 입력

-   첫째 줄에 N과 x가 정수 형태로 공백으로 구분되어 입력됩니다.  
    (1 <= N <= 1e6)), (-1e9 <= x <= 1e9)
-   둘째 줄에 n개의 원소가 정수 형태로 공백으로 구분되어 입력됩니다.  
    ((-1e9 <= 각 원소의 값 <= 1e9))

#### 출력

-   수열의 원소 중에서 값이 x인 원소의 개수를 출력합니다. 단 값이x인 원소가 하나도 없다면 -1을 출력합니다.

> #### 입력예시 1
>
> 7 2  
> 1 1 2 2 2 2 3
>
> #### 출력예시 1
>
> 4
>
> ---
>
> #### 입력예시 2
>
> 7 4  
> 1 1 2 2 2 2 3
>
> #### 출력예시 2
>
> -1

## 풀이

---

시간 복잡도를 O(logN)로 정하고 정렬된 리스트 안에서 특정 수를 찾는 문제이니 이진탐색을 이용하는 것이 좋다. 다만 이때, 첫번째와 마지막으로 해당 수가 나오는 인덱스를 구하는 함수를 작성하도록 한다.  
또 다른 풀이로 라이브러리를 이용하는 것인데 해당 수가 중복되어 나오면 가장 빠른 인덱스를 반환하는 bisect_left 가장 나중 인덱스를 반환하는 bisect_right 함수를 이용한다.

## 코드

---

### binary

```
def first(arr, target, start, end):
    if start > end:
        return None
    mid = (start + end) // 2
    # mid가 가장 앞에 있거나, 미드 앞 값이 target 보다 작을 때
    if (mid == 0 or target > arr[mid - 1]) and arr[mid] == target:
        return mid
    elif arr[mid] >= target:
        return first(arr, target, start, mid - 1)
    else:
        return first(arr, target, mid + 1, end)


def last(arr, target, start, end):
    if start > end:
        return None
    mid = (start + end) // 2
    # mid가 가장 뒤에 있거나, mid 뒤 값이 target 보다 클 때
    if (mid == n - 1 or target < arr[mid + 1]) and arr[mid] == target:
        return mid
    elif arr[mid] >= target:
        return first(arr, target, start, mid - 1)
    else:
        return first(arr, target, mid + 1, end)

n, x = map(int, input().split())
arr = list(map(int, input().split()))

a, b = first(arr, x, 0, n - 1), last(arr, x, 0, n - 1)
if a == None or b == None:
    print(-1)
else:
    print(b - a + 1)
```

### bisect

---

```
from bisect import bisect_left, bisect_right

def count_by_range(arr, left_value, right_value):
    right_index = bisect_right(arr, right_value)
    left_index = bisect_left(arr, left_value)
    return right_index - left_index


n, x = map(int, input().split())
arr = list(map(int, input().split()))

if count_by_range(arr, x, x) == 0: print(-1)
else:
    print(count_by_range(arr, x, x))

```
