package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.Usuario;
import edu.ifsp.teachstation.persistence.UserRepository;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/login")
    public String login() 
    {
        return "login";
    }

    @GetMapping("/")
    public String home() 
    {
        return "login";
    }

    @PostMapping("/login")
    public String realizarLogin(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            HttpSession session) 
    {

        Usuario usuario = userRepository.findByEmail(username);

        if (usuario == null) {
            return "redirect:/login?error";
        }

        if (!usuario.getSenha().equals(password)) {
            return "redirect:/login?error";
        }

        session.setAttribute("usuarioLogado", usuario);
        
        //ALUNO
        if (usuario.getTipoUsuario().equals("ALUNO")) 
        {

            Aluno aluno = (Aluno) usuario;

            session.setAttribute("alunoLogado", aluno);

            if (aluno.getNivelAtual() == null) 
            {
            	//Não está sendo direcionado pq não existem questões ainda
                return "redirect:/first-test";
            }

            return "redirect:/studyarea";
        }
        
        //PROFESSOR
        if (usuario.getTipoUsuario().equals("PROFESSOR")) 
        {
            return "redirect:/dashboard";
        }

        return "redirect:/login?error";
    }
}