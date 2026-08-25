package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PortugueseController {
	@GetMapping("/studyarea/portuguese")
	public String portuguese() {
		return "portuguese";
	}
}
