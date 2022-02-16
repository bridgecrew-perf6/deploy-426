package com.deploy;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.Arrays;

@Slf4j
@RestController
@RequiredArgsConstructor
public class HelloController {

    private final Environment environment;

    @GetMapping
    public String hello(HttpServletRequest request) {
        log.info("[{}] request", request.getHeader("X-Real-IP"));
        return "6차 버전";
    }

    @GetMapping("/profile")
    public String getProfile() {
        return Arrays.stream(environment.getActiveProfiles())
                .findFirst()
                .orElse("default");
    }

    @PostMapping("/done")
    public void done(HttpServletRequest request) {
        log.info("[{}] request done", request.getHeader("X-Real-IP"));
    }
}
