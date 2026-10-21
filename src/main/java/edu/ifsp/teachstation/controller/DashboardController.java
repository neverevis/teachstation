package edu.ifsp.teachstation.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.Usuario;
import edu.ifsp.teachstation.persistence.AlunoRepository;

@Controller
public class DashboardController {

    @Autowired
    private AlunoRepository alunoRepository;

    @GetMapping("/dashboard")
    public String dashboard(@RequestParam(name = "busca", required = false) String busca, Model model, HttpSession session) 
    {
        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");

        if (usuarioLogado == null) {
            Object principal = SecurityContextHolder.getContext().getAuthentication() != null 
                    ? SecurityContextHolder.getContext().getAuthentication().getPrincipal() 
                    : null;
            if (principal instanceof Usuario) {
                usuarioLogado = (Usuario) principal;
                session.setAttribute("usuarioLogado", usuarioLogado);
            }
        }

        String perfil = usuarioLogado != null && usuarioLogado.getTipoUsuario() != null 
                ? usuarioLogado.getTipoUsuario().toLowerCase() 
                : "";

        model.addAttribute("perfil", perfil);
        model.addAttribute("usuarioLogado", usuarioLogado);

        List<Aluno> alunos;
        if (busca != null && !busca.trim().isEmpty()) {
            alunos = alunoRepository.pesquisar(busca.trim());
        } else {
            alunos = alunoRepository.findAll();
        }

        model.addAttribute("alunos", alunos);
        model.addAttribute("totalAlunos", alunoRepository.count());
        model.addAttribute("busca", busca);

        return "dashboard";
    }
}
