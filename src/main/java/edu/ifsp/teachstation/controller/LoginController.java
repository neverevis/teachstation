
package edu.ifsp.teachstation.controller;

import java.util.List;
import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.model.Usuario;
import edu.ifsp.teachstation.persistence.UserRepository;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.ui.Model;

@Controller
public class LoginController {


    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/login")
    public String login(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "redefinida", required = false) String redefinida,
            @RequestParam(value = "logout", required = false) String logout,
            Model model) {

        if (error != null) {
            model.addAttribute(
                "mensagem",
                "E-mail ou senha incorretos. Verifique seus dados e tente novamente."
            );
            model.addAttribute("tipoMensagem", "erro");
        }

        if (redefinida != null) {
            model.addAttribute(
                "mensagem",
                "Senha redefinida com sucesso! Faça login com sua nova senha."
            );
            model.addAttribute("tipoMensagem", "sucesso");
        }

        if (logout != null) {
            model.addAttribute(
                "mensagem",
                "Você saiu da sua conta com sucesso!"
            );
            model.addAttribute("tipoMensagem", "sucesso");
        }

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
            HttpSession session,
            HttpServletRequest request,
            HttpServletResponse response) {


        Usuario usuario = userRepository.findByEmail(username);

        if (usuario == null || !passwordEncoder.matches(password, usuario.getSenha()))
        {
            return "redirect:/login?error";
        }

        String tipoUsuario = usuario.getTipoUsuario();

        if (!List.of("ALUNO", "PROFESSOR", "SECRETARIA").contains(tipoUsuario))
        {
            return "redirect:/login?error";
        }

        SimpleGrantedAuthority autoridade =
                new SimpleGrantedAuthority("ROLE_" + tipoUsuario);

        UsernamePasswordAuthenticationToken autenticacao =
                new UsernamePasswordAuthenticationToken(
                        usuario,
                        null,
                        List.of(autoridade));

        SecurityContext contexto =
                SecurityContextHolder.createEmptyContext();

        contexto.setAuthentication(autenticacao);

        SecurityContextHolder.setContext(contexto);

        HttpSessionSecurityContextRepository repositorio =
                new HttpSessionSecurityContextRepository();

        repositorio.saveContext(contexto, request, response);

        session.setAttribute("usuarioLogado", usuario);

        if (tipoUsuario.equals("ALUNO"))
        {

            Aluno aluno = (Aluno) usuario;

            session.setAttribute("alunoLogado", aluno);

            if (aluno.getNivelAtual() == null)
            {
                return "redirect:/first-test";
            }

            return "redirect:/studyarea";
        }

        return "redirect:/dashboard";
    }
}
