package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RegistersController {
	@GetMapping("/cadastros")
    public String cadastros() {
        return "registers";
    }
}
