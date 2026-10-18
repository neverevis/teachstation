package edu.ifsp.teachstation.controller;

import org.springframework.ui.Model;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/studyarea/portuguese")
public class PortugueseController {

    @GetMapping("/level1")
	public String level1(Model model) {
		model.addAttribute("fase", 1);
		return "quiz-gamificado";
	}

	@GetMapping("/level2")
	public String level2() {
		return "level2";
	}


	@GetMapping("")
	public String portuguese() {
		return "portuguese";
	}
}
