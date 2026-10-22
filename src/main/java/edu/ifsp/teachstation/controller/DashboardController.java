package edu.ifsp.teachstation.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import jakarta.servlet.http.HttpSession;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.Usuario;
import edu.ifsp.teachstation.persistence.AlunoRepository;

@Controller
public class DashboardController {

    private final AlunoRepository alunoRepository;

    public DashboardController(AlunoRepository alunoRepository) {
        this.alunoRepository = alunoRepository;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model, HttpSession session) 
    {
     
        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
        
        if (usuarioLogado == null) 
        {
            return "redirect:/login";
        }

        String perfil = usuarioLogado.getTipoUsuario().toLowerCase();

        List<Aluno> alunos = alunoRepository.findAll();

        model.addAttribute("perfil", perfil);
        model.addAttribute("alunos", alunos);

        return "dashboard";
    }
}
