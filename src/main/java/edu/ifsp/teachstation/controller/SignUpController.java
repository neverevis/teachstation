
package edu.ifsp.teachstation.controller;

import edu.ifsp.teachstation.model.Aluno;
import edu.ifsp.teachstation.persistence.AlunoRepository;

import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.sql.Date;

@Controller
public class SignUpController {

    private final AlunoRepository alunoRepository;
    private final PasswordEncoder passwordEncoder;

    public SignUpController(AlunoRepository alunoRepository, PasswordEncoder passwordEncoder) 
    {
        this.alunoRepository = alunoRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/cadastro/aluno")
    public String signup(@RequestParam(value = "erro", required = false) String erro, @RequestParam(value = "sucesso", required = false) String sucesso, Model model) 
    {

        if (erro != null) 
        {
            if (erro.equals("senha")) 
            {
                model.addAttribute("mensagem", "As senhas não coincidem.");
            } 
            else 
            {
                model.addAttribute(
                    "mensagem",
                    "Não foi possível cadastrar o aluno. Verifique os dados."
                );
            }

            model.addAttribute("tipoMensagem", "erro");
        }

        if (sucesso != null) 
        {
            model.addAttribute(
                "mensagem",
                "Aluno cadastrado com sucesso!"
            );
            model.addAttribute("tipoMensagem", "sucesso");
        }

        return "cadastro-aluno";
    }

    @PostMapping("/signup")
    public String cadastrarAluno(
            @RequestParam("nome") String nome,
            @RequestParam("ra") String ra,
            @RequestParam("data-nascimento") String dataNascimento,
            @RequestParam("email") String email,
            @RequestParam("telefone-responsavel") String telefoneResponsavel,
            @RequestParam("genero") String genero,
            @RequestParam("nome-social") String nomeSocial,
            @RequestParam("senha") String senha,
            @RequestParam("confirmar-senha") String confirmarSenha) {

        if (!senha.equals(confirmarSenha)) 
        {
            return "redirect:/cadastro/aluno?erro=senha";
        }

        try 
        {
            Aluno aluno = new Aluno();

            aluno.setNomeCompleto(nome);
            aluno.setRa(ra);
            aluno.setDataNascimento(Date.valueOf(dataNascimento));
            aluno.setEmail(email);
            aluno.setTelefoneResponsavel(telefoneResponsavel);
            aluno.setGenero(genero);
            aluno.setNomeSocial(nomeSocial);
            aluno.setSenha(passwordEncoder.encode(senha));

            aluno.setTipoUsuario("ALUNO");
            aluno.setDataCadastro(new java.util.Date());

            alunoRepository.save(aluno);

            return "redirect:/cadastro/aluno?sucesso";

        } 
        catch (DataAccessException | IllegalArgumentException e) 
        {
            return "redirect:/cadastro/aluno?erro=cadastro";
        }
    }
}
