package edu.ifsp.teachstation.controller;

import java.text.SimpleDateFormat;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import edu.ifsp.teachstation.model.Usuario;
import edu.ifsp.teachstation.persistence.UserRepository;

@Controller
public class RedefinirSenhaController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public RedefinirSenhaController(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/redefinir-senha")
    public String exibirFormulario(
            @RequestParam(value = "erro", required = false) String erro,
            @RequestParam(value = "sucesso", required = false) String sucesso,
            Model model) {

        if (erro != null) {
            if (erro.equals("senha")) {
                model.addAttribute("mensagem", "As senhas não coincidem.");
            } else {
                model.addAttribute(
                    "mensagem",
                    "E-mail ou data de nascimento não correspondem a nenhum usuário cadastrado."
                );
            }
            model.addAttribute("tipoMensagem", "erro");
        }

        if (sucesso != null) {
            model.addAttribute("mensagem", "Senha redefinida com sucesso!");
            model.addAttribute("tipoMensagem", "sucesso");
        }

        return "redefinir-senha";
    }

    @PostMapping("/redefinir-senha")
    public String redefinirSenha(
            @RequestParam("email") String email,
            @RequestParam("data-nascimento") String dataNascimento,
            @RequestParam("senha") String senha,
            @RequestParam("confirmar-senha") String confirmarSenha) {

        if (!senha.equals(confirmarSenha)) {
            return "redirect:/redefinir-senha?erro=senha";
        }

        Usuario usuario = userRepository.findByEmail(email != null ? email.trim() : "");
        if (usuario == null || usuario.getDataNascimento() == null) {
            return "redirect:/redefinir-senha?erro=dados";
        }

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String dataCadastrada = sdf.format(usuario.getDataNascimento());

        if (!dataCadastrada.equals(dataNascimento)) {
            return "redirect:/redefinir-senha?erro=dados";
        }

        usuario.setSenha(passwordEncoder.encode(senha));
        userRepository.save(usuario);

        return "redirect:/login?redefinida";
    }
}
