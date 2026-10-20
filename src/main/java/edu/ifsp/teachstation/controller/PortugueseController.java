package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/studyarea/portuguese")
public class PortugueseController {
	
	@GetMapping("/level{numero:[1-8]}")
	public String level(@PathVariable("numero") int numero, Model model) {
		model.addAttribute("fase", numero);
		return "quiz-gamificado";
	}
	
	
	@GetMapping("")
	public String portuguese() {
		return "portuguese";
	}
}
