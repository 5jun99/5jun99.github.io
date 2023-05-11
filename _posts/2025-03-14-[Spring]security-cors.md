---
layout: post
title: "Spring Security, CORS"
date: 2025-03-14 00:00:00 +0900
category: Spring
tags: []
original_url: https://velog.io/@9409velog/Spring-Security-CORS
---

# cors?

cors는 “Cross-Origin Resource Sharing”의 약자입니다. 다른 오리진, 즉 다른 출처에서 오는 리소스에 대한 프로토콜이라고 할 수 있습니다.  
다른 출처의 리소스는 믿을 수 없기에 이것에 대한 통제를 하는 것이 cors 오류인 것이죠. 남들 한 번씩 다 얘기하는 cors를 짚고 넘어가는 이유는 이번에 security와 cors를 같이 사용하니 조금 개념이 꼬인 부분이 있다고 생각해서였습니다.

# 난 분명 cors 설정을 했는데?

```
@Configuration
public class CorsConfig {
    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration corsConfiguration = new CorsConfiguration();

        corsConfiguration.addAllowedOriginPattern("*");

        corsConfiguration.addAllowedMethod("*"); // 모든 HTTP 메서드 허용
        corsConfiguration.addAllowedHeader("*"); // 모든 헤더 허용

        // 쿠키 허용
        corsConfiguration.setAllowCredentials(true);
        corsConfiguration.addExposedHeader("*");

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfiguration);

        return new CorsFilter(source);
    }
}
```

이렇게 생긴 코드를 항상 넣어줬었습니다.  
corsConfiguration 객체에 옵션들을 추가하여 필터를 등록했던 것이죠. 해당 필터는 서버로 오는 요청을 가로채어 요청을 뜯어보면서 확인합니다. 기준에 적합한 요청이면 요청을 받아들이고 다시 응답이 갈 때도 cors 헤더를 추가해 보내줍니다. 클라이언트에서도 리소스를 받을 수 있게 말이죠

## 근데 왜 안 막혔지?

그 이유는 security에게 있습니다. CorsFilter가 추가한 헤더를 Spring Security가 덮어쓸 수 있기 때문입니다.  
그렇기 때문에 시큐리티에서도 cors 설정을 해줌으로써 이런 오류가 발생하는 것을 막을 수 있습니다.
