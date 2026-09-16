package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {
	@GetMapping("/dashboard")
	public String dashboard(Model model) {

	    String perfil = "secretaria"; // alternar de "professor" para "secretaria" para visualizar a opção de "cadastros" aparecer no Menu do dashboard

	    model.addAttribute("perfil", perfil);

	    return "dashboard";
	}
}
