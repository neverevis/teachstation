package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StudyAreaController {
	@GetMapping("/studyarea")
	public String studyarea() {
		return "studyarea";
	}
}
