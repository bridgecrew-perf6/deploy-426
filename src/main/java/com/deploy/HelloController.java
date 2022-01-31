package com.deploy;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
public class HelloController {

    @GetMapping
    public String hello(HttpServletRequest request) {
        log.info("[{}] request", request.getRemoteAddr());
        return "hello";
    }
}
