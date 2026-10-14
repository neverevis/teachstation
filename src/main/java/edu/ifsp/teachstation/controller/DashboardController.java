package edu.ifsp.teachstation.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import jakarta.servlet.http.HttpSession;

import edu.ifsp.teachstation.model.Usuario;

@Controller
public class DashboardController {

    @GetMapping("/dashboard")
    public String dashboard(Model model, HttpSession session) 
    {
     
        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");

        String perfil = usuarioLogado.getTipoUsuario().toLowerCase();

        model.addAttribute("perfil", perfil);

        return "dashboard";
    }
}
