package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.service.QuizGamificadoService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/studyarea/portuguese")
public class PortugueseController {
	
	@Autowired
	private QuizGamificadoService quizService;
	
	// Endereço antigo (sem o código do nível): leva ao endereço do aluno
	@GetMapping("/level{numero:[1-8]}")
	public String level(@PathVariable("numero") int numero, HttpSession session) {
		return "redirect:/studyarea/portuguese/level" + numero + "/" + varianteDe(session);
	}
	
	// Cada fase tem três endereços (a, b e c), um por nível de dificuldade. O aluno só abre o seu;
	// se tentar outro, é levado ao dele. O questionário em si é escolhido pelo servidor.
	@GetMapping("/level{numero:[1-8]}/{variante:[abc]}")
	public String levelComVariante(@PathVariable("numero") int numero,
			@PathVariable("variante") String variante, HttpSession session, Model model) {
		String correta = varianteDe(session);
		if (!correta.equals(variante)) {
			return "redirect:/studyarea/portuguese/level" + numero + "/" + correta;
		}
		model.addAttribute("fase", numero);
		return "quiz-gamificado";
	}
	
	@GetMapping("")
	public String portuguese(HttpSession session, Model model) {
		model.addAttribute("variante", varianteDe(session));
		return "portuguese";
	}
	
	// Código do endereço do aluno logado; sem aluno na sessão usa o nível padrão
	private String varianteDe(HttpSession session) {
		Aluno aluno = (Aluno) session.getAttribute("alunoLogado");
		return aluno == null ? QuizGamificadoService.codigoDoNivel(null) : quizService.variante(aluno);
	}
}
