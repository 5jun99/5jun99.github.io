---
layout: post
title: "[aws] ???: cors 오류는 config만 설정하면 되는 거 아니야?"
date: 2024-07-29 00:00:00 +0900
category: AWS
tags: []
original_url: https://velog.io/@9409velog/awsspring-cors-%EC%98%A4%EB%A5%98%EB%8A%94-config%EB%A7%8C-%EC%84%A4%EC%A0%95%ED%95%98%EB%A9%B4-%EB%90%98%EB%8A%94-%EA%B1%B0-%EC%95%84%EB%8B%88%EC%95%BC
---

아니다.

이제껏 수많은 cors 오류를 해결해보면서 처음보는 문제에 봉착했다.

분명 origin에 프론트의 도메인을 넣어주고 프론트에서도 백 url을 프록시 설정해줬는데 안되는 것이다.

답은 간단했다. aws 인스턴스가 소속된 보안 그룹에서 인바운드 규칙 설정을 안해준 것.  
분명 저쪽에서는 그들만의 port로 오는데 나는 그 해당 port 방화벽을 닫아놨으니 당연한 것.

앞으로 잘 확인하자
