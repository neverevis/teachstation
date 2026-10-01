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

  
        //String perfil = "secretaria"; alternar de "professor" para "secretaria" para visualizar a opção de "cadastros" aparecer no Menu do dashboard
     

        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");

        if (usuarioLogado == null) 
        {
            return "redirect:/login";
        }

        String perfil = usuarioLogado.getTipoUsuario().toLowerCase();

        model.addAttribute("perfil", perfil);

        return "dashboard";
    }
}
