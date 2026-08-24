package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FirstTestController {
    
    @GetMapping("/first-test")
    public String firstTest() {
        return "first-test";
    }
}
