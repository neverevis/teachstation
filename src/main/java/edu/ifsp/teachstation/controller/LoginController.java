package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.persistence.AlunoRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    @Autowired
    private AlunoRepository alunoRepository; // Repositório para buscar o aluno no banco

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/")
    public String home() {
        return "login";
    }

    @PostMapping("/login")
    public String realizarLogin(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            HttpSession session) {

        // Busca o aluno no banco de dados pelo e-mail
        Aluno aluno = alunoRepository.findByEmail(username);

        // Se encontrou o aluno 
        if (aluno != null) {
            // Guarda o aluno na sessão para ser lido no FirstTestController
            session.setAttribute("alunoLogado", aluno);
            
            // Redireciona para o teste inicial
            return "redirect:/first-test";
        }

        // Se o usuário não existir ou falhar o login, volta para a tela de login
        return "redirect:/login?error";
    }
}